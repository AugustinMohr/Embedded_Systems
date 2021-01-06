library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LT24_controller is

	port(
	
		clk		: in std_logic;
		nReset	: in std_logic;
		
		
		-- Avalon Slave
		AS_address 			: in std_logic_vector(3 downto 0);
		AS_CS					: in std_logic;
		AS_write				: in std_logic;
		AS_writedata		: in std_logic_vector(31 downto 0);
		AS_read				: in std_logic;
		AS_readdata			: out std_logic_vector(31 downto 0);
		AS_irq				: out std_logic;
		
		-- Avalon Master
		AM_address			: out std_logic_vector(31 downto 0);
		AM_read				: out std_logic;
		AM_readdata			: in std_logic_vector(31 downto 0);
		AM_waitRQ			: in std_logic;
		AM_Rddatavalid		: in std_logic;
		AM_BurstCount		: out std_logic_vector(7 downto 0);
		
		-- Lcd Output
		LCD_ON				: out std_logic;
		CS_N					: out std_logic;
		RESET_N     		: out std_logic;
		DATA       		 	: out std_logic_vector(15 downto 0);
		RD_N        		: out std_logic;
		WR_N        		: out std_logic;
		D_C_N					: out std_logic -- low : Command, high : Data
		
		
	);
end LT24_controller;

architecture comp of LT24_controller is


--Internal Registers


signal buffer_address 	: unsigned(31 downto 0);
signal buffer_length  	: unsigned(31 downto 0);
signal LCD_command		: std_logic_vector(7 downto 0);
signal LCD_data			: std_logic_vector(15 downto 0);

signal DataAck				: std_logic;	-- TODO: is this useful?
signal CntAddress			: unsigned(31 downto 0);
signal CntLength			: unsigned(31 downto 0);
signal bursts_left		: unsigned(7 downto 0);
signal newdata_interrupt: std_logic; 

signal finished 			: std_logic;
signal irq_buffer			: std_logic;
signal wait_LCD 			: integer;

--Constants

constant BURST_COUNT			: unsigned(7 downto 0) := X"24"; -- 36
constant ALMOST_FULL 		: std_logic_vector(7 downto 0) := X"D8"; -- 216

--States of FSM

type LCD_states is (idle, write_command, write_data, write_pixel);
signal LCD_state	: LCD_states;

type AM_states is(AM_idle, AM_wait_data, AM_acq_data, AM_finished, AM_wait_FIFO);
signal AM_state : AM_states := AM_idle;



-- FIFO signals

signal FIFO_write				: std_logic;
signal FIFO_writedata		: std_logic_vector(31 downto 0);
signal FIFO_read				: std_logic;
signal FIFO_readdata			: std_logic_vector(15 downto 0);
signal FIFO_write_flag 		: std_logic;
signal FIFO_empty				: std_logic;
signal FIFO_full 				: std_logic;
signal FIFO_usedw				: STD_LOGIC_VECTOR (7 DOWNTO 0);


component FIFO
	PORT
	(
		data			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdclk			: IN STD_LOGIC ;
		rdreq			: IN STD_LOGIC ;
		wrclk			: IN STD_LOGIC ;
		wrreq			: IN STD_LOGIC ;
		q				: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;

begin

FIFO_inst : FIFO PORT MAP (
		data	 	=> FIFO_writedata,
		rdclk	 	=> clk,
		rdreq	 	=> FIFO_read,
		wrclk	 	=> clk,
		wrreq	 	=> FIFO_write,
		q	 		=> FIFO_readdata,
		rdempty	=> FIFO_empty,
		wrfull	=> FIFO_full,
		wrusedw	=> FIFO_usedw
	);



-- Avalon Slave write to registers

Avalon_slave_write : process(clk, nReset)
begin

	if nReset = '0' then
		buffer_address <= (others => '0');
		buffer_length  <= (others => '0');
		LCD_command  <= (others => '0');
		LCD_data  <= (others => '0');		
		irq_buffer <= '0';
	elsif rising_edge(clk) then			
		if AS_CS = '1' and AS_write = '1' then 
			case AS_address is
				when "0000" => buffer_address <= unsigned(AS_writedata);
				when "0001" => buffer_length  <= unsigned(AS_writedata);
				when "0010" => LCD_command		<= AS_writedata(7 downto 0);
				when "0011" => LCD_data			<= AS_writedata(15 downto 0);
				when "0100" => irq_buffer		<= '0'; -- Set this to 0 after giving new buffer address and length
				when "0101" =>
				when "0110" =>
				when "0111" =>
				when "1000" =>
				when others => null;
			end case;
			
			-- Avalon Slave Interrupt Update
			if finished = '1' then
				irq_buffer <= '1';
			end if;
		end if;
	end if;	

end process Avalon_slave_write;

AS_irq <= irq_buffer; -- AS_irq is connected to irq_buffer


-- Avalon Slave read from registers

Avalon_slave_read : process(clk)
begin

	if rising_edge(clk) then
		if AS_CS  = '1' and AS_read = '1' then
			case AS_address is
				when "0000" => AS_readdata <= std_logic_vector(buffer_address);
				when "0001" => AS_readdata <= std_logic_vector(buffer_length);
				when "0010" => AS_readdata(7 downto 0) <= std_logic_vector(LCD_command);
				when "0011" => AS_readdata(15 downto 0) <= std_logic_vector(LCD_data);
				when "0100" => 
				when "0101" =>
				when "0110" =>
				when "0111" =>
				when "1000" =>
				when others => null;
			end case;
		end if;
	end if;

end process Avalon_slave_read;

-- Avalon Master FSM

Avalon_master : process(clk, nReset)
begin
	if nReset = '0' then -- Reset to default values
		DataAck <= '0';
		AM_state <= AM_idle;
		AM_read <= '0';
		CntAddress <= (others => '0');
		CntLength <= (others => '0');
		AM_BurstCount <= (others => '0');
		bursts_left <= (others => '0');
		
	elsif rising_edge(clk) then
	
		FIFO_write <= '0';
		FIFO_writedata <= (others => '0');
		case AM_state is
	
		when AM_idle =>
		
			if buffer_length /= X"0000_0000" then -- if length /= 0
				AM_state <= AM_wait_data;
				CntAddress <= buffer_address; 
				CntLength <= buffer_length; 
			end if;
			
		when AM_wait_data =>	-- read on avalon bus
			
			if buffer_length = X"0000_0000" then -- go back to idle if buffer length = 0
				AM_state <= AM_idle;
			elsif FIFO_usedw >= ALMOST_FULL then 
				AM_state <= AM_wait_FIFO;
			else
				AM_read <= '1';
				AM_Address <= std_logic_vector(CntAddress);
				AM_BurstCount <= std_logic_vector(BURST_COUNT);
				if AM_waitRQ = '0' then
					AM_state <= AM_acq_data;
					bursts_left <= BURST_COUNT;
				end if;
			end if;
		
		when AM_acq_data =>	-- wait end of request
		
			if AM_Rddatavalid = '1' then 
				AM_read <= '0';
				FIFO_write <= '1';
				FIFO_writedata <= AM_readdata;
				
				if CntLength /= 1 then	-- not end of buffer, increment address
					CntAddress <= CntAddress + 4; 
					bursts_left <= bursts_left - 1;
					CntLength <= CntLength - 1;
					if bursts_left <= "00000001" then -- end of burst
						AM_state <= AM_wait_data; 
					end if;
				else -- end of buffer, return to idle
					finished <= '1';
					AM_state <= AM_finished;
				end if;
			end if;
			
		when AM_wait_FIFO => -- Wait for the FIFO to have enough space to be written in
			AM_read <= '0';
			if FIFO_usedw < ALMOST_FULL then
				AM_state <= AM_wait_data;
			end if;
			
		when AM_finished => -- wait for AS_irq to be set to 1 for interruption
			if irq_buffer = '1' then
				finished <= '0';
				AM_state <= AM_idle;
			end if;
		
		end case;
	end if;
		
end process Avalon_master;

--LCD controller FSM

LCD_controller : process(clk, nReset)
begin
	if nReset = '0' then
		RESET_N <= '0';	
		CS_N <= '1';
		D_C_N <= '1';
		WR_N <= '1';						--Reset routine
		RD_N <= '1';
		DATA <= (others => 'Z');
		LCD_state <= idle;
		wait_LCD <= 0;	
	elsif rising_edge(clk) then
		case LCD_state is
			when idle =>
				RESET_N <= '1';	
				CS_N <= '1';
				D_C_N <= '1';				--Idle default state
				WR_N <= '1';
				RD_N <= '1';
				wait_LCD <= 0;	
				DATA <= (others => 'Z');
			
			if AS_CS = '1' and AS_write = '1' and AS_address = "0010" then --If a command has been sent to the AS by the processor

				LCD_state <= write_command;
			elsif AS_CS = '1' and AS_write
			= '1' and AS_address = "0011" then
				LCD_state <= write_data;
			elsif FIFO_empty = '0' then
				LCD_state <= write_pixel;  --If there is no command and there are pixels to display
				
			end if;
			
			when write_command =>
				wait_LCD <= wait_LCD + 1;
				
				case wait_LCD is
				
				when 0 =>
					CS_N <= '0';
					WR_N <= '0';
					D_C_N <= '0';
					DATA(15 downto 8) <= (others => '0');	--Set the data port with the command
					DATA(7 downto 0) <= LCD_command;
				
				when 1 =>
					WR_N <= '1';									--Write command to LCD
				
				when 2 =>
					D_C_N <= '1';
					DATA <= (others => 'Z');					--Negate the command on the data port
					
				when others =>
					LCD_state <= idle;
				end case;
				
			when write_data =>
				wait_LCD <= wait_LCD + 1;
				
				case wait_LCD is
				
				when 0 =>
					CS_N <= '0';
					WR_N <= '0';
					D_C_N <= '1';
					DATA <= LCD_data;
				
				when 1 =>
					WR_N <= '1';									--Write parameter to LCD
					
				when 2 =>
					DATA <= (others => 'Z');					--Negate the data port
							
				when others =>
					LCD_state <= idle;
				end case;
				
			when write_pixel =>
				wait_LCD <= wait_LCD + 1;
				case wait_LCD is
				
				when 0 => 
					FIFO_read <= '1'; --Request read from the FIFO
				when 1 =>
					CS_N <= '0';
					WR_N <= '0';
					D_C_N <= '1';
					DATA <= FIFO_readdata; --Read from FIFO
					FIFO_read <= '0';
				when 2 =>
					WR_N <= '1';				-- Write to LCD
				when 3 =>
					DATA <= (others => 'Z');
					LCD_state <= idle;
				when others =>
					LCD_state <= idle;
				end case;
								
			when others =>		
				null;
		
		end case;
	end if;


end process LCD_controller;

LCD_ON <= '1';  --Keep the LCD on
	
end comp;	
					
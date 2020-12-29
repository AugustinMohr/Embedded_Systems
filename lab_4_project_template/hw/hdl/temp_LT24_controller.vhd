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
		
		-- Avalon Master
		AM_address			: out std_logic_vector(31 downto 0);
		AM_ByteEnable		: out std_logic_vector(31 downto 0);
		AM_read				: out std_logic;
		AM_readdata			: in std_logic_vector(31 downto 0);
		AM_waitRQ			: in std_logic;
		
		-- Lcd Output
		LCD_ON				: out std_logic;
		CS_N					: out std_logic;
		RESET_N     		: out std_logic;
		DATA       		 	: out std_logic_vector(15 downto 0);
		RD_N        		: out std_logic;
		WR_N        		: out std_logic;
		D_C_N					: out std_logic; -- low : Command, high : Data
		

		
	);
end LT24_controller;

architecture comp of LT24_controller is


--Internal Registers


signal buffer_address 	: unsigned(31 downto 0);
signal buffer_length  	: unsigned(31 downto 0);
signal LCD_command		: unsigned(7 downto 0);
signal LCD_data			: unsigned(15 downto 0);

signal command_mode		: std_logic;
signal DataAck				: std_logic;
signal CntAddress			: unsigned(31 downto 0);
signal CntLength			: unsigned(31 downto 0);
signal NewData 			: std_logic;

		-- FIFO
signal FIFO_write			: std_logic;
signal FIFO_writedata	: std_logic_vector(31 downto 0);
signal FIFO_read			: std_logic;
signal FIFO_readdata		: std_logic_vector(15 downto 0);
signal almost_empty		: std_logic;
signal almost_full		: std_logic
signal FIFO_write_flag 	: std_logic;
signal FIFO_empty			: std_logic;
signal FIFO_full 			: std_logic;

variable wait_LCD 			: integer;
variable Indice				: integer;
variable num_pixels			: integer := 0;

--Constants

constant MAX_PIXELS 			: integer := 76800; --320x240 pixels
constant almost_empy_val	: integer := 160;
constant almost_full_val	: integer := 160;



--States of FSM

type LCD_states is (idle, begin_transfer, write_command, write_data, read_data, wait_acq, wait_command, frame_finished, read_fifo);
signal LCD_state	: LCD_states;

type AM_states is(AM_idle, AM_wait_data, AM_read_data, AM_acq_data);
signal AM_state : AM_states;


begin

-- FIFO
FIFO : process(clk, nReset)
begin
	if nReset = '0' then
		FIFO_write <= '0';
		FIFO_writedata <= '0';
		FIFO_read <= '0';
		FIFO_readdata <= '0';
		almost_empty <= '0';
		almost_full <= '0';
		FIFO_empty <= '1';
		FIFO_full <= '0';
		FIFO_write_flag <= '0';
	elsif rising_edge(clk) then
		
	end if;
end process FIFO;


-- FIFO write
FIFO_write_process : process(clk, nReset)
begin
	if nReset = '0' then
		FIFO_write <= '0';
		FIFO_write_flag <= '0';
		FIFO_read <= '0';
	elsif rising_edge(clk) then
		if FIFO_write_flag = '1' then
			FIFO_write <= '0';		-- maybe add signal as buffer? 
		end if;
	end if;
end process FIFO_write_process;


-- Avalon Slave write to registers

Avalon_slave_write : process(clk, nReset)
begin

	if nReset = '0' then
		buffer_address <= (others => '0');
		buffer_length  <= (others => '0');
		LCD_command  <= (others => '0');
		LCD_data  <= (others => '0');
	elsif rising_edge(clk) then			
		if AS_CS = '1' and AS_write = '1' then --GUGU IMPLEMENTATION
			case AS_address is
			when "0000" => buffer_address <= unsigned(AS_writedata);
			when "0001" => buffer_length  <= unsigned(AS_writedata);
			when "0010" => LCD_command		<= unsigned(AS_writedata);
			when "0011" => LCD_data			<= unsigned(AS_writedata);
			when "0100" =>
			when "0101" =>
			when "0110" =>
			when "0111" =>
			when "1000" =>
			when others => null;
			end case;
		end if;
	end if;	

end process Avalon_slave_write;



-- Avalon Slave read from registers

Avalon_slave_read : process(clk)
begin

	if rising_edge(clk) then
		if AS_CS  = '1' and AS_read = '1' then
			case AS_address is
				when "0000" => AS_readdata <= std_logic_vector(buffer_address);
				when "0001" => AS_readdata <= std_logic_vector(buffer_length);
				when "0010" => AS_readdata <= std_logic_vector(LCD_command);
				when "0011" => AS_readdata <= std_logic_vector(LCD_data);
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
		AM_ByteEnable <= "0000";
		CntAddress <= (others => '0');
		CntLength <= (others => '0');
		
	elsif rising_edge(clk) then
	
		case AM_state is
	
		when AM_idle =>
		
			if buffer_length /= X"0000_0000" then -- if length /= 0
				AM_state <= AM_wait_data;
				CntAddress <= buffer_address; 
				CntLength <= buffer_length; 
			end if;
			
		when AM_wait_data =>
			
			if buffer_length = X"0000_0000" then -- go back to idle once buffer length = 0
				AM_state <= AM_idle;
			elsif NewData = '1' then -- Loop here until buffer length = 0
				AM_state <= AM_read_data;
				AM_Address <= std_logic_vector(CntAddress);
				AM_read <= '1';
				FIFO_writedata(7 downto 0) 	<= AM_readdata(7 downto 0);
				FIFO_writedata(15 downto 8) 	<= AM_readdata(15 downto 8);
				FIFO_writedata(23 downto 16) <= AM_readdata(23 downto 16);
				FIFO_writedata(31 downto 24) <= AM_readdata(31 downto 24);
				AM_ByteEnable <= "0000";
				Indice := To_integer(CntAddress(1 downto 0)); -- 2 low addresses bit as offset activation
				AM_ByteEnable(Indice) <= '1';
				FIFO_write <= '1';
				FIFO_write_flag <= '1';
			end if;
			
		when AM_read_data =>	-- read on avalon bus
		
			if AM_waitRQ = '0' then
				AM_state <= AM_acq_data;
				AM_read <= '0';
				AM_ByteEnable <= "0000";
				DataAck <= '1';
			end if;
		
		when AM_acq_data =>	-- wait end of request
			
			if NewData = '0' then
				AM_state <= AM_wait_data;
				DataAck <= '0';
				if CntLength /= 1 then	-- not end of buffer, increment address
					CntAddress <= CntAddress + 1;
					CntLength <= CntLength - 1;
				else 							-- end of buffer, roll over
					CntAddress <= buffer_address;
					CntLength <= buffer_length;
				end if;
			end if;
		end case;
	end if;
		
end process Avalon_master;

--LCD controller FSM

LCD_controller : process(clk, nReset)
begin
	if nReset = '0' then 
		CS_N <= '1';
		D_C_N <= '1';
		WR_N <= '1';
		RD_N <= '1';
		DATA <= (others => 'Z');
		LCD_state <= idle;
	elsif rising_edge(clk) then
		CS_N <= '1';
		D_C_N <= '1';
		WR_N <= '1';
		RD_N <= '1';
		DATA <= (others => 'Z');
		case LCD_state is
		
		when idle =>
			if command_mode = '1' then
				LCD_state <= wait_command;
			else
				LCD_state <= wait_acq;
			end if;
		when wait_command =>
			CS_N <= '0';
			if command_mode = '0' then
				LCD_state <= wait_acq;
				CS_N <= '1';
			elsif AS_CS ='1' and AS_write = '1' then
				case AS_address is
				when "0010" => 
					LCD_state <= write_command;
				when"0011" =>
					LCD_state <= write_data;
				when others =>
					null;
				end case;
			end if;	
		
		when write_command =>
			CS_N <= '0';
			WR_N <= '0';
			D_C_N <= '0';
			DATA <= x"00" & LCD_command;
			wait_LCD := wait_LCD + 1;
			if wait_LCD = 3 then
				WR_N <= '1';
				LCD_state <= idle;
			end if;
		when write_data =>
			CS_N <= '0';
			WR_N <= '0';
			D_C_N <= '1';
			DATA <= LCD_data;
			wait_LCD := wait_LCD + 1;
			if wait_LCD = 3 then
				WR_N <= '1';
				LCD_state <= idle;
			end if;
		when wait_acq =>
			if num_pixels = MAX_PIXELS then
				LCD_state <= frame_finished;
			elsif almost_empty = '0' then
				FIFO_read <= '1';
				D_C_N <= '1';
				wait_LCD := 0;
				LCD_state <= read_fifo;
			end if;
		when read_fifo =>
			CS_N <= '0';
			WR_N <= '0';
			D_C_N <= '1';
			DATA <= FIFO_readdata;
			if wait_LCD = 3 then
				WR_N <= '1';
				LCD_state <= idle;
				num_pixels := num_pixels + 1;
			end if;
			
		when frame_finished =>
				num_pixels := 0;															--TODO : Interrupt when the frame is finished ?
															
			
		end case;
	end if;


end process LCD_controller;

	
end comp;	
					
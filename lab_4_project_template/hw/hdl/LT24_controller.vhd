library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LT24_controller is

	port(
	
		clk		: in std_logic;
		nReset	: in std_logic;
		
		-- Acquisition (?)
		DataAcquisition	: in std_logic_vector(7 downto 0);
		NewData				: in std_logic;
		DataAck				: out std_logic;
		
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
		AM_write				: out std_logic;
		AM_writedata		: out std_logic_vector(31 downto 0);
		AM_waitRQ			: in std_logic;
		
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

signal wait_LCD 			: unsigned(3 DOWNTO 0);
signal buffer_address 	: unsigned(31 DOWNTO 0);
signal buffer_length  	: unsigned(31 DOWNTO 0);
signal LCD_command		: unsigned(7 DOWNTO 0);
signal LCD_data			: unsigned(15 DOWNTO 0);

signal AcqAddress			: unsigned(31 DOWNTO 0);
signal AcqLength 			: unsigned(31 DOWNTO 0); 
signal CntAddress			: unsigned(31 DOWNTO 0);
signal CntLength			: unsigned(31 DOWNTO 0);
signal NewData 			: std_logic;

--States of FSM

type LCD_states is (idle, write_command, write_data, read_data);
signal LCD_state	: LCD_states;

type AM_states is(idle, wait_data, write_data, acq_data)
signal AM_state : AM_states;


begin


-- Avalon Slave write to registers

Avalon_slave_write : process(clk, nReset)
begin

	if nReset = '0' then
		buffer_address <= (others => '0');
		buffer_length  <= (others => '0');
		LCD_command  <= (others => '0');
		LDC_data  <= (others => '0');
	elsif rising_edge(clk) then
		if AS_CS  = '1' and AS_write = '1' then
			
			case AS_address is 
				when '0' => AcqAddress 	<= unsigned(AS_writedata); -- register the address
				when '1' => AcqLength 	<= unsigned(AS_writedata);	--	register the length
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
				when '0' => AS_readdata <= std_logic_vector(AcqAddress); -- Read back Acq start address
				when '1' => AS_readdata <= std_logic_vector(AcqLength); -- Read back Acq length
				when others => null;
		end if;
	end if;

end process Avalon_slave_read;

-- Avalon Master FSM

Avalon_master : process(clk, nReset)
begin
	if nReset = '0' then -- Reset to default values
		DataAck <= '0'
		AM_state <= idle;
		AM_write <= '0';
		AM_ByteEnable <= "0000";
		CntAddress <= (others => '0');
		CntLength <= (others => '0');
		
	elsif rising_edge(clk) then
	
		case AM_state is
	
		when idle =>
		
			if AcqLength /= X"0000_0000" then -- if length /= 0
				AM_state <= wait_data;
				CntAddress <= AcqAddress;
				CntLength <= AcqLength;
			end if;
			
		when wait_data =>
			
			if AcqLength = X"0000_0000" then -- go back to idle once acqlength = 0
				AM_state = idle;
			elsif NewData = '1' then -- Loop here until acqlength = 0
				AM_state = write_data;
				AM_Address <= CntAddress;
				AM_write <= '1';
				AM_writedata(7 downto 0) 	<= DataAcquisition;
				AM_writedata(15 downto 8) 	<= DataAcquisition;
				AM_writedata(23 downto 16) <= DataAcquisition;
				AM_writedata(31 downto 24) <= DataAcquisition;
				AM_ByteEnable <= "0000";
				Indice := To_integer(CntAddress(1 downto 0)); -- 2 low addresses bit as offset activation
				AM_ByteEnable(Indice) <= '1';
			end if;
			
		when write_data =>	-- write on avalon bus
		
			if AM_waitRQ = '0' then
				AM_state = acq_data;
				AM_write = '0';
				AM_ByteEnable <= "0000";
				DataAck <= '1';
			end if;
		
		when acq_data =>	-- wait end of request
			
			if NewData = '0' then
				AM_state = wait_data;
				DataAck <= '0';
				if CntLength /= 1 then	-- not end of buffer, increment address
					CntAddress <= CntAddress + 1;
					CntLength <= CntLength - 1;
				else 							-- end of buffer, roll over
					CntAddress <= AcqAddress;
					CntLength <= AcqLength;
				end if;
			end if;
		end case;
	end if;
		
end process Avalon_master



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
		
		when write_command =>
		
		when write_data =>
		
		when read_data =>
			
		end case;
	end if;


end process LCD_controller

	
end comp;	
					
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LT24_controller is

	port(
	
		clk		: in std_logic;
		nReset	: in std_logic;
		
		
		
		-- Avalon Slave
		AS_address 		: in std_logic_vector(3 downto 0);
		AS_CS				: in std_logic;
		AS_write			: in std_logic;
		AS_writedata	: in std_logic_vector(31 downto 0);
		AS_read			: in std_logic;
		AS_readdata		: out std_logic_vector(31 downto 0);
		
		
		-- Lcd Output
		LCD_ON		: out std_logic;
		CS_N			: out std_logic;
		RESET_N     : out std_logic;
		DATA        : out std_logic_vector(15 downto 0);
		RD_N        : out std_logic;
		WR_N        : out std_logic;
		D_C_N			: out std_logic -- low : Command, high : Data
		
	);
end LT24_controller;

architecture comp of LT24_controller is


--Internal Registers

signal wait_LCD 			: unsigned(3 DOWNTO 0);
signal buffer_address 	: unsigned(31 DOWNTO 0);
signal buffer_length  	: unsigned(31 DOWNTO 0);
signal LCD_command		: unsigned(7 DOWNTO 0);
signal LCD_data			: unsigned(15 DOWNTO 0);


--States of FSM

type LCD_states is (idle, write_command, write_data, read_data);
signal LCD_state	: LCD_states;





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
		if AS_CS = '1' and AS_write = '1' then
			case AS_address is
			when "0000" => buffer_address <= AS_writedata;
			when "0001" => buffer_length  <= AS_writedata;
			when "0010" => LCD_command		<= AS_writedata;
			when "0011" => LCD_data			<= AS_writedata;
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



end process Avalon_slave_read;



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


end process LCD_controller;

	
end comp;	
					

-- #############################################################################
-- clock_divider.vhd
--
-- BOARD         : DE0-Nano-SoC from Terasic
-- Author        : Augustin Mohr
--               : 
-- Revision      : 1.0
-- Creation date : 06.11.2020
--
-- Syntax Rule : GROUP_NAME_N[bit]
--
-- GROUP : specify a particular interface (ex: SDR_)
-- NAME  : signal name (ex: CONFIG, D, ...)
-- bit   : signal index
-- _N    : to specify an active-low signal
-- #############################################################################

library ieee;
use ieee.std_logic_1164.all;

entity clock_divider is
    port(
       
		 clk		: in std_logic;
		Reset		: in std_logic;
		enable   : out std_logic
		 
    );
end entity clock_divider;

architecture rtl of clock_divider is

signal count	: integer := 0;
signal tmp 		: std_logic := '0';
	
begin
	
	process(clk, Reset)
	begin
	
		if(Reset='1') then
			count <= 1;
			tmp <= '0';
		
		elsif rising_edge(clk) then	
			count <= count + 1;
			if(count = 8333) then
				tmp <='1';
				count <= 0;
			else
				tmp <='0';
			end if;
		end if;
	end process;
	enable <= tmp;
	
end;

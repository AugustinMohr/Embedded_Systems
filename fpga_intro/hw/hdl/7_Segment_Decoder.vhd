
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Segment_7 is

	port(
	
		clk		: in std_logic;
		nReset	: in std_logic;
		enable	: in std_logic;
		
		
		--Internal interface (i.e. Avalon slave).
		write			: in std_logic;
		--read			: in std_logic;
		writedata	: in std_logic_vector(23 downto 0);
		--readdata		: out std_logic_vector(7 downto 0);
		
		--External interface (i.e. conduit)
		SelSeg           : out   std_logic_vector(7 downto 0);
	   Reset_Led        : out   std_logic;
      nSelDig          : out   std_logic_vector(5 downto 0);
      --SwLed            : in    std_logic_vector(7 downto 0);
      nButton          : in    std_logic_vector(3 downto 0);
      LedButton        : out   std_logic_vector(3 downto 0)
	);
end Segment_7;

architecture comp of Segment_7 is


	signal hex_num 	: std_logic_vector(23 downto 0);
	signal count		: integer range 0 to 5 := 0;
	signal hex_led  	: std_logic_vector(3 downto 0);
	
	
begin
	
	-- Avalon slave write to registers.
	process(clk, nReset)
	begin
		if nReset = '0' then
			hex_num <= (others => '0');
			count <= 0;
		elsif rising_edge(clk) then
			if write = '1' then
				hex_num <= writedata;
			end if;
		end if;
	end process;
	
	-- Refresh each of the 6 displays
	process(clk)
	begin
		if rising_edge(clk) then
			if enable = '1' then
				Reset_Led <= '0';
				nSelDig <= (others => '1');
				case count is
					when 0 => 
						nSelDig(0) <= '0';
						hex_led <= 	hex_num(3 downto 0);					
					when 1 =>
						nSelDig(1) <= '0';
						hex_led <= 	hex_num(7 downto 4);	
					when 2 =>
						nSelDig(2) <= '0';
						hex_led <= 	hex_num(11 downto 8);	
					when 3 =>
						nSelDig(3) <= '0';
						hex_led <= 	hex_num(15 downto 12);
					when 4 =>
						nSelDig(4) <= '0';
						hex_led <= 	hex_num(19 downto 16);
					when 5 =>
						nSelDig(5) <= '0';
						hex_led <= 	hex_num(23 downto 20);
					if count = 5 then
						count <= 0;
					else
						count <= count + 1;
					end if;
				end case;	
			end if;
		end if;
	end process;
	
	
	-- Decoding : hex -> 7 Segments
	
	process(hex_led)
	begin
		 case hex_led is
			 when "0000" => SelSeg <= "00000011"; -- "0"     
			 when "0001" => SelSeg <= "10011111"; -- "1" 
			 when "0010" => SelSeg <= "00100101"; -- "2" 
			 when "0011" => SelSeg <= "00001101"; -- "3" 
			 when "0100" => SelSeg <= "10011001"; -- "4" 
			 when "0101" => SelSeg <= "01001001"; -- "5" 
			 when "0110" => SelSeg <= "01000001"; -- "6" 
			 when "0111" => SelSeg <= "00011111"; -- "7" 
			 when "1000" => SelSeg <= "00000001"; -- "8"     
			 when "1001" => SelSeg <= "00001001"; -- "9" 
			 when "1010" => SelSeg <= "00010001"; -- A
			 when "1011" => SelSeg <= "11000001"; -- b
			 when "1100" => SelSeg <= "01100011"; -- C
			 when "1101" => SelSeg <= "10000101"; -- d
			 when "1110" => SelSeg <= "01100001"; -- E
			 when "1111" => SelSeg <= "01110001"; -- F
		 end case;
	end process;

	
end comp;	
					
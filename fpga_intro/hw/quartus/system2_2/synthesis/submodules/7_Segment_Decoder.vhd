
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Segment_7 is

	port(
	
		clk		: in std_logic;
		nReset	: in std_logic;
		
		
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


	signal hex_num 		: std_logic_vector(23 downto 0);
	signal count_dig		: integer range 0 to 5 := 0;
	signal count_6kHz		: integer range 0 to 8333 := 0;
	signal count_100Hz	: integer range 0 to 499999999 := 0;
	signal hex_led  		: std_logic_vector(3 downto 0);
	signal enable_6kHz	: std_logic;
	signal enable_100Hz	: std_logic;
	signal centi_u       : std_logic_vector(3 downto 0) := x"0000";
	signal centi_d       : std_logic_vector(3 downto 0) := x"0000";
	signal seconds_u     : std_logic_vector(3 downto 0) := x"0000";
	signal seconds_d     : std_logic_vector(3 downto 0) := x"0000";
	signal minutes_u     : std_logic_vector(3 downto 0) := x"0000";
	signal minutes_d     : std_logic_vector(3 downto 0) := x"0000";
	
	
begin
	
	-- 6kHz clock divider
	
	process(clk, nReset)
	begin
	
		if nReset='0' then
			count_6kHz <= 1;
			enable_6kHz <= '0';
		
		elsif rising_edge(clk) then	
			count_6kHz <= count_6kHz + 1;
			if count_6kHz = 8333 then
				enable_6kHz <='1';
				count_6kHz <= 0;
			else
				enable_6kHz <='0';
			end if;
		end if;
	end process;
	
	-- 100Hz clock divider
	
	process(clk, nReset)
	begin
	
		if nReset='0' then
			count_100Hz <= 1;
			enable_100Hz <= '0';
		
		elsif rising_edge(clk) then	
			count_100Hz <= count_100Hz + 1;
			if count_100Hz = 499999999 then
				enable_100Hz <='1';
				count_100Hz <= 0;
			else
				enable_100Hz <='0';
			end if;
		end if;
	end process;
	

	-- RTC
    process(clk, nReset)
    begin
        if nReset = '0' then
            centi_u <= x"0000";
            centi_d <= x"0000";
            seconds_u <= x"0000";
            seconds_d <= x"0000";
            minutes_u <= x"0000";
            minutes_d <= x"0000";
        elsif rising_edge(clk) then
             if enable_100Hz = '1' then
                 -- Centiseconds
                 centi_u <= centi_u + x"0001";
                 if centi_u = x"1010" then
                     centi_u <= x"0000";
                     centi_d <= centi_d + x"0001";
                     if centi_d = x"1010" then
                         centi_d <= x"0000";
                         seconds_u <= seconds_u + x"0001";
                         if seconds_u = x"1010" then
                             seconds_u <= x"0000";
                             seconds_d <= seconds_d + x"0001";
                             if seconds_d = x"0110" then
                                 seconds_d <= x"0000";
                                 minutes_u <= minutes_u + x"0001";
                                 if minutes_u = x"1010" then
                                     minutes_u <= x"0000";
                                     minutes_d <= minutes_d + x"0001";
                                     if minutes_d = x"0110" then
                                         minutes_d <= x"0000";
                                     end if;
                                 end if;
                             end if;
                         end if;
                     end if;
                 end if;
             end if;
         end if;
    end process;
	
	
	
	
	
	-- Decoding min/sec/centi to the displayed hex_num
	
	process(clk, nReset)
	begin
	
		if nReset = '0' then
			hex_num <= (others => '0');
		
		elsif rising_edge(clk) then	
			hex_num(3 downto 0) <= centi_u;
			hex_num(7 downto 4) <= centi_d;
			hex_num(11 downto 8) <= seconds_u;
			hex_num(15 downto 12) <= seconds_d;
			hex_num(19 downto 16) <= minutes_u;
			hex_num(23 downto 17) <= minutes_d;
		end if;
	end process;
	
	-- Refresh each of the 6 displays
	process(clk)
	begin
		if rising_edge(clk) then
			if enable_6kHz = '1' then
				Reset_Led <= '0';
				nSelDig <= (others => '1');
				case count_dig is
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
					if count_dig = 5 then
						count_dig <= 0;
					else
						count_dig <= count_dig + 1;
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
					
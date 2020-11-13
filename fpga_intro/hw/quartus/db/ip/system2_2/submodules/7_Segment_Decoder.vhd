
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


	signal hex_num 		: std_logic_vector(23 downto 0):= x"000000";
	signal count_dig		: integer range 0 to 5;
	signal count_6kHz		: integer range 0 to 8333;
	signal count_100Hz	: integer range 0 to 499999;
	signal hex_led  		: std_logic_vector(3 downto 0);
	signal enable_6kHz	: std_logic;
	signal enable_100Hz	: std_logic;
	signal centi_u       : std_logic_vector(3 downto 0) := "0000";
	signal centi_d       : std_logic_vector(3 downto 0) := "0000";
	signal seconds_u     : std_logic_vector(3 downto 0) := "0000";
	signal seconds_d     : std_logic_vector(3 downto 0) := "0000";
	signal minutes_u     : std_logic_vector(3 downto 0) := "0000";
	signal minutes_d     : std_logic_vector(3 downto 0) := "0000";
	signal play        	: std_logic;
	signal redge     		: std_logic;
	
begin
	
	-- 6kHz clock divider
	
	process(clk, nReset)
	begin
	
		if nReset='0' then
			count_6kHz <= 0;
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
			count_100Hz <= 0;
			enable_100Hz <= '0';
		
		elsif rising_edge(clk) then	
			count_100Hz <= count_100Hz + 1;
			if count_100Hz = 499999 then
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
            centi_u <= "0000";
            centi_d <= "0000";
            seconds_u <= "0000";
            seconds_d <= "0000";
            minutes_u <= "0000";
            minutes_d <= "0000";
        elsif rising_edge(clk) then
             if enable_100Hz = '1' then
                 if play = '1' then
                     -- Centiseconds
                     centi_u <= centi_u + "0001";
                     if centi_u = "1001" then
                         centi_u <= "0000";
                         centi_d <= centi_d + "0001";
                         if centi_d = "1001" then
                             centi_d <= "0000";
                             -- Seconds
                             seconds_u <= seconds_u + "0001";
                             if seconds_u = "1001" then
                                 seconds_u <= "0000";
                                 seconds_d <= seconds_d + "0001";
                                 if seconds_d = "0101" then
                                     seconds_d <= "0000";
                                     -- Minutes
                                     minutes_u <= minutes_u + "0001";
                                     if minutes_u = "1001" then
                                         minutes_u <= "0000";
                                         minutes_d <= minutes_d + "0001";
                                         if minutes_d = "0101" then
                                             minutes_d <= "0000";
                                         end if;
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
			hex_num(23 downto 20) <= minutes_d;
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
					when others => count_dig <= 0;
				end case;
				if count_dig = 5 then
					count_dig <= 0;
				else
					count_dig <= count_dig + 1;
				end if;
					
			end if;
		end if;
	end process;
	
	
	-- Decoding : hex -> 7 Segments
	
	process(hex_led)
	begin
		 case hex_led is
			 when "0000" => SelSeg <= "00111111"; -- "0"     
			 when "0001" => SelSeg <= "00000110"; -- "1" 
			 when "0010" => SelSeg <= "01011011"; -- "2" 
			 when "0011" => SelSeg <= "01001111"; -- "3" 
			 when "0100" => SelSeg <= "01100110"; -- "4" 
			 when "0101" => SelSeg <= "01101101"; -- "5" 
			 when "0110" => SelSeg <= "01111101"; -- "6" 
			 when "0111" => SelSeg <= "00000111"; -- "7" 
			 when "1000" => SelSeg <= "01111111"; -- "8"     
			 when "1001" => SelSeg <= "01101111"; -- "9" 
			 when "1010" => SelSeg <= "01110111"; -- A
			 when "1011" => SelSeg <= "01111100"; -- b
			 when "1100" => SelSeg <= "00111001"; -- C
			 when "1101" => SelSeg <= "01011110"; -- d
			 when "1110" => SelSeg <= "01111001"; -- E
			 when "1111" => SelSeg <= "01110001"; -- F
		 end case;
	end process;

	
	-- Pause/play button
    process(clk, nButton)
    begin
		if rising_edge(clk) then
        if nButton(1) = '0' then
            if redge = '0' then
                play <= not play;
                redge <= '1';
            end if;
				
        else
            redge <= '0';
        end if;
		 end if;
    end process;
	
end comp;	
					
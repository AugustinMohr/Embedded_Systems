-- Camera reciever module
-- Author: Iacopo Sprenger

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity camera is 
	port
	(  
		--misc
		reset_n					: in std_logic;
		clock 					: in std_logic;

		-- Camera
		C_pixdata				: in	std_logic_vector(11 downto 0);
		C_pixclk				: in	std_logic;
		C_fval					: in	std_logic;
		C_lval					: in	std_logic;
		C_trigger				: out	std_logic;

		-- Avalon slave
		S_address				: in	std_logic_vector(1 downto 0);
		S_write					: in	std_logic;
		S_read					: in	std_logic;
		S_writedata				: in	std_logic_vector(31 downto 0);
		S_readdata				: out	std_logic_vector(31 downto 0);
		S_irq					: out	std_logic;

		-- Avalon master
		M_address				: out	std_logic_vector(31 downto 0);
		M_byteenable			: out	std_logic_vector(1 downto 0);
		M_write					: out	std_logic;
		M_writedata				: out	std_logic_vector(15 downto 0);
		M_waitrequest			: in	std_logic;
		M_burstcount			: out	std_logic_vector(7 downto 0)

	);
end camera;


architecture arch of camera is

signal reset 				: std_logic;

-- individual color signals after fifos
signal	color_r				: std_logic_vector(11 downto 0);
signal	color_g1			: std_logic_vector(11 downto 0);
signal	color_b				: std_logic_vector(11 downto 0);
signal	color_g2			: std_logic_vector(11 downto 0);

-- one of each color is available
signal	color_available		: std_logic;

-- individual fifos empty signals
signal	r_empty				: std_logic;
signal	g1_empty			: std_logic;
signal	b_empty				: std_logic;
signal	g2_empty			: std_logic;

-- individual fifos write signals
signal	r_write				: std_logic;
signal	g1_write			: std_logic;
signal	b_write				: std_logic;
signal	g2_write			: std_logic;

-- multi color signals
signal color_rgb			: std_logic_vector(15 downto 0);
signal color_g 				: std_logic_vector(12 downto 0);

-- pixel valid from lval and fval
signal pix_valid			: std_logic;

-- pixel sorting multiplexer input
signal mux_input			: std_logic_vector(1 downto 0);

-- pixel sorting counters
signal pix_counter 			: unsigned(11 downto 0);
signal line_counter			: unsigned(11 downto 0);

-- exposure time computation signals
signal exposure_counter		: unsigned(23 downto 0);
signal exposure_number		: unsigned(23 downto 0);
signal exposure_active		: std_logic;

--registers
signal control_reg 			: std_logic_vector(31 downto 0);
signal settings_reg 		: std_logic_vector(31 downto 0);
signal address_reg 			: std_logic_vector(31 downto 0);

-- master state machine type
type state_type is (WAIT_FIRST, WAIT_NEXT, WRITE_NEXT);
signal master_state			: state_type;

-- rgb pixels ready for transfer
signal pixel_available		: std_logic;

-- read from rgb fifo
signal read_pix				: std_logic;

-- send counetr and total
signal send_number 			: unsigned(23 downto 0);
signal send_counter 		: unsigned(23 downto 0);

-- ready for transmission signal
signal transmit_ok			: std_logic;

-- full transmission finished
signal finished 			: std_logic;

-- flush fifos and reset counters signal
signal restart				: std_logic;

-- avalon master output buffering
signal rgb_out				: std_logic_vector(15 downto 0);
signal out_bfr				: std_logic_vector(15 downto 0);

-- rgb fifo fill count
signal rgb_usedw			: std_logic_vector(11 downto 0);

-- send counter for bursts
signal burst_counter		: unsigned(7 downto 0);

-- address of current memory access
signal address_bfr			: unsigned(31 downto 0);


begin
--rgb fifo buffer
fifo_rgb : entity work.fifo_16 PORT MAP (
		aclr	 => reset,
		clock	 => clock,
		data	 => color_rgb,
		rdreq	 => read_pix,
		wrreq	 => color_available,
		empty	 => open,
		full	 => open,
		q	 	 => rgb_out,
		usedw	 => rgb_usedw
	);

--individual colors fifo buffers
fifo_r : entity work.fifo_12 PORT MAP (
		aclr	 => reset,
		data	 => C_pixdata,
		rdclk	 => clock,
		rdreq	 => color_available,
		wrclk	 => C_pixclk,
		wrreq	 => r_write,
		q		 => color_r,
		rdempty	 => r_empty,
		wrfull	 => open
	);
fifo_g1 : entity work.fifo_12 PORT MAP (
		aclr	 => reset,
		data	 => C_pixdata,
		rdclk	 => clock,
		rdreq	 => color_available,
		wrclk	 => C_pixclk,
		wrreq	 => g1_write,
		q		 => color_g1,
		rdempty	 => g1_empty,
		wrfull	 => open
	);
fifo_b : entity work.fifo_12 PORT MAP (
		aclr	 => reset,
		data	 => C_pixdata,
		rdclk	 => clock,
		rdreq	 => color_available,
		wrclk	 => C_pixclk,
		wrreq	 => b_write,
		q		 => color_b,
		rdempty	 => b_empty,
		wrfull	 => open
	);
fifo_g2 : entity work.fifo_12 PORT MAP (
		aclr	 => reset,
		data	 => C_pixdata,
		rdclk	 => clock,
		rdreq	 => color_available,
		wrclk	 => C_pixclk,
		wrreq	 => g2_write,
		q	 => color_g2,
		rdempty	 => g2_empty,
		wrfull	 => open
	);

-- combinational logic
reset <= (not reset_n) or restart;

--pixel sorting combinational part
pix_valid <= C_fval and C_lval;

mux_input(1) <= pix_counter(0);
mux_input(0) <= line_counter(0);

g1_write <= '1' when mux_input = "00" and pix_valid = '1' else '0';
r_write <= '1' when mux_input = "10" and pix_valid = '1' else '0';
b_write <= '1' when mux_input = "01" and pix_valid = '1' else '0';
g2_write <= '1' when mux_input = "11" and pix_valid = '1' else '0';

-- pixel sorting sequencial part
process(reset_n, C_pixclk)
begin
	if reset = '1' then
		
		pix_counter <= (others => '0');
		line_counter <= (others => '0');


	elsif rising_edge(C_pixclk) then
		-- sort and store pixels in fifos
		if pix_valid = '1' then
			pix_counter <= pix_counter + 1;
			if pix_counter = unsigned(settings_reg(11 downto 0))-1 then
				line_counter <= line_counter + 1;
				pix_counter <= (others => '0');
				if line_counter = unsigned(settings_reg(23 downto 12))-1 then
					line_counter <= (others => '0');
				end if;
			end if;	
		end if;
	end if;
end process;

-- avalon slave and exposure time combinationnal part
S_irq <= control_reg(31) and control_reg(30);

C_trigger <= not exposure_active;

exposure_number <= unsigned(control_reg(17 downto 2) & "00000000");

-- avalon slave and exposure time sequencial part
process(reset_n, clock)
begin
	if reset_n = '0' then
		-- async reset
		control_reg <= (others => '0');
		settings_reg <= x"201E0280"; -- 640x480
		address_reg <= (others => '0');

		exposure_active <= '0';
		exposure_counter <= (others => '0');
		restart <= '0';

	elsif rising_edge(clock) then
		if S_write = '1' then
			case S_address is
				when "00" =>
					control_reg <= S_writedata;
					if S_writedata(0) = '1' then
						restart <= '1';
						exposure_active <= '1';
					end if;
				when "01" => 
					settings_reg <= S_writedata;
					if unsigned(S_writedata(31 downto 24)) = 0 then
						settings_reg(24) <= '1';  -- minimum burst length is 1
					end if;
				when "10" => 
					address_reg <= S_writedata;
				when others => null;
			end case;
		elsif S_read = '1' then
			case S_address is
				when "00" =>
					S_readdata <= control_reg;
				when "01" => 
					S_readdata <= settings_reg;
				when "10" => 
					S_readdata <= address_reg;
				when others => null;
			end case;
		end if;

		if exposure_active = '1' then
			exposure_counter <= exposure_counter + 1;
			restart <= '0';
			if exposure_counter = exposure_number then
				exposure_active <= '0';
				exposure_counter <= (others => '0');
			end if;
		end if;

		if finished = '1' then
			control_reg(31) <= '1';
		end if;

	end if;


end process;


-- pixel rgb565 encoding combinational logic
color_available <= ((not r_empty) and (not g1_empty) and (not b_empty) and (not g2_empty));

color_g <= std_logic_vector(unsigned('0' & color_g1)+unsigned('0' & color_g2));

color_rgb(15 downto 11) <= color_r(11 downto 7);
color_rgb(10 downto 5) <= color_g(12 downto 7);
color_rgb(4 downto 0) <= color_b(11 downto 7);


--avalon master combinational logic
send_number <= "00" & unsigned(settings_reg(11 downto 1)) * unsigned(settings_reg(23 downto 13)); 

pixel_available <= '1' when unsigned(rgb_usedw) >= unsigned("0000" & settings_reg(31 downto 24)) else '0';

transmit_ok <= pixel_available and control_reg(1);

M_writedata <= out_bfr;

M_byteenable <= "11";

--avalon master
process(reset_n, clock)
begin
	if reset_n = '0' then
		M_write <= '0';
		finished <= '0';
	elsif rising_edge(clock) then
		if restart = '1' then
			master_state <= WAIT_FIRST;
		else
			case master_state is
				when WAIT_FIRST =>
					if transmit_ok = '1' then
						master_state <= WRITE_NEXT;
						M_burstcount <= settings_reg(31 downto 24); -- set the right burstcount
						M_address <= address_reg;
						address_bfr <= unsigned(address_reg);
						read_pix <= '1';
						out_bfr <= rgb_out;
						M_write <= '1';
						send_counter <= to_unsigned(1, send_counter'length);
						burst_counter <= to_unsigned(1, burst_counter'length);
					end if;

				when WRITE_NEXT =>
					read_pix <= '0';	
					if M_waitrequest = '0' then
						M_write <= '0';
						if send_counter = send_number then
							master_state <= WAIT_FIRST; --we go to next strate only when waitreq is 0
							finished <= '1';
						elsif burst_counter = unsigned(settings_reg(31 downto 24)) then
							master_state <= WAIT_NEXT;
							address_bfr <= address_bfr + unsigned(settings_reg(31 downto 24) & "0"); --double because we set word addresses
						else
							read_pix <= '1';
							M_write <= '1';
							send_counter <= send_counter + 1;
							burst_counter <= burst_counter + 1;
							out_bfr <= rgb_out;
						end if;
					end if;


				when WAIT_NEXT =>
					if transmit_ok = '1' then
						master_state <= WRITE_NEXT;
						read_pix <= '1';
						M_write <= '1';
						send_counter <= send_counter + 1;
						burst_counter <= to_unsigned(1, burst_counter'length);
						M_burstcount <= settings_reg(31 downto 24); -- set the right burstcount
						M_address <= std_logic_vector(address_bfr);
						out_bfr <= rgb_out;
					end if;

				
				when others => master_state <= WAIT_FIRST;

			end case;
		end if;
	end if;
end process;

end arch;
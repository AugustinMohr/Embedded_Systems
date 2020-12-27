library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_testbench is
end FIFO_testbench;

architecture test of FIFO_testbench is
	
	-- Delta T
	constant CLK_PERIOD : time := 100 ns;

	-- FIFO ports
	signal clock		: STD_LOGIC ;
	signal data		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal rdreq		: STD_LOGIC ;
	signal wrreq		: STD_LOGIC ;
	signal almost_empty	: STD_LOGIC ;
	signal almost_full	: STD_LOGIC ;
	signal empty		: STD_LOGIC ;
	signal full		: STD_LOGIC ;
	signal q		: STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

	-- Instantiate DUT
	dut: entity work.FIFO
	port map(clock => clock,
		data => data,
		rdreq => rdreq,
		wrreq => wrreq,
		almost_empty => almost_empty,
		almost_full => almost_full,
		empty => empty,
		full => full,
		q => q);
		
	-- Generate clock signal
	clk_generation : process
	begin
		clock <= '1';
		wait for CLK_PERIOD / 2;
		clock <= '0';
		wait for CLK_PERIOD / 2;
	end process clk_generation;

	
	
	simulation : process
		
		-- SIMULATION START
	begin
	
	-- Default values
	
	data <= (others => '0');
	q <= (others => 'Z');
	rdreq <= '0';
	wrreq <= '0';
	
	-- Write request
	wait until rising_edge(clock);
	data <= X"0101_0101";

	wait until rising_edge(clock);
	wrreq <= '1';
	
	wait until rising_edge(clock);
	
	wrreq <= '0';
	data <= (others => '0');
	wait until rising_edge(clock);

	-- Second write
	data <= X"1111_1111";

	wait until rising_edge(clock);
	wrreq <= '1';
	
	wait until rising_edge(clock);
	
	wrreq <= '0';
	data <= (others => '0');

	wait until rising_edge(clock);
	rdreq <= '1';

	wait until rising_edge(clock);
	rdreq <= '0';
	q <= (others => 'Z');
	wait until rising_edge(clock);
	rdreq <= '1';

	wait until rising_edge(clock);
	rdreq <= '0';
	end process simulation;
end architecture test;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_testbench is
end LT24_testbench;

architecture test of LT24_testbench is
	
	-- Delta T
	constant CLK_PERIOD : time := 20 ns;
	
	signal 	clk		: std_logic;
	signal 	nReset	: std_logic;
		
		-- Avalon Slave
	signal 	AS_address 			: std_logic_vector(3 downto 0);	-- in
	signal 	AS_CS					: std_logic;							-- in
	signal 	AS_write				: std_logic;							-- in
	signal 	AS_writedata		: std_logic_vector(31 downto 0);	-- in
	signal 	AS_read				: std_logic;							-- in
	signal 	AS_readdata			: std_logic_vector(31 downto 0); -- out
		
		-- Avalon Master
	signal 	AM_address			: std_logic_vector(31 downto 0);	-- out
	signal	AM_ByteEnable		: std_logic_vector(31 downto 0); -- out 
	signal	AM_read				: std_logic;							-- out
	signal	AM_readdata			: std_logic_vector(31 downto 0);	-- in
	signal	AM_waitRQ			: std_logic;							-- in
	signal	AM_Rddatavalid		: std_logic;							-- in
		
		-- Lcd Output
	signal	LCD_ON				: std_logic;							-- out
	signal	CS_N					: std_logic;							-- out
	signal	RESET_N     		: std_logic;							-- out
	signal	DATA       		 	: std_logic_vector(15 downto 0);	-- out
	signal	RD_N        		: std_logic;							-- out
	signal	WR_N        		: std_logic;							-- out
	signal	D_C_N					: std_logic; 							-- out

begin

	-- Instantiate DUT
	dut: entity work.LT24_controller
	
	port map(clk => clk,
		nReset => nReset,
		
		AS_address => AS_address,
		AS_CS => AS_CS,
		AS_write => AS_write,
		AS_writedata => AS_writedata,
		AS_read => AS_read,
		AS_readdata => AS_readdata,
		
		AM_address => AM_address,
		AM_ByteEnable => AM_ByteEnable,
		AM_read => AM_read,
		AM_readdata => AM_readdata,
		AM_waitRQ => AM_waitRQ,
		AM_Rddatavalid => AM_Rddatavalid,
		
		LCD_ON => LCD_ON,
		CS_N => CS_N,
		RESET_N => RESET_N,
		DATA => DATA,
		RD_N => RD_N,
		WR_N => WR_N,
		D_C_N => D_C_N
		);
		
	-- Generate clock signal
	clk_generation : process
	begin
		clck <= '1';
		wait for CLK_PERIOD / 2;
		clck <= '0';
		wait for CLK_PERIOD / 2;
	end process clk_generation;

	
	-- SIMULATION START
	simulation : process
	begin
	
	-- Default values
	
	nReset <= '1';
	AS_readdata <= (others => 'Z');
	AM_address <= (others => 'Z');
	AM_ByteEnable <= (others => 'Z');
	AM_read <= 'Z';
	
	LCD_ON <= 'Z';
	CS_N <= 'Z';
	RESET_N <= 'Z';
	DATA <= (others => 'Z');
	RD_N <= 'Z';
	WR_N <= 'Z';
	D_C_N <= 'Z';
	
	-- Write request
	wait until rising_edge(clk);
	end process simulation;
end architecture test;

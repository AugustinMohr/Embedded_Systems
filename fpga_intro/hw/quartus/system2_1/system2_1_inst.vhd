	component system2_1 is
		port (
			clk_clk                                 : in    std_logic                    := 'X';             -- clk
			custom_pio_0_external_connection_export : inout std_logic_vector(7 downto 0) := (others => 'X'); -- export
			reset_reset_n                           : in    std_logic                    := 'X'              -- reset_n
		);
	end component system2_1;

	u0 : component system2_1
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                              clk.clk
			custom_pio_0_external_connection_export => CONNECTED_TO_custom_pio_0_external_connection_export, -- custom_pio_0_external_connection.export
			reset_reset_n                           => CONNECTED_TO_reset_reset_n                            --                            reset.reset_n
		);


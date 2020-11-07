	component unsaved is
		port (
			clk_clk                     : in  std_logic := 'X'; -- clk
			reset_reset_n               : in  std_logic := 'X'; -- reset_n
			enable_writeresponsevalid_n : out std_logic         -- writeresponsevalid_n
		);
	end component unsaved;

	u0 : component unsaved
		port map (
			clk_clk                     => CONNECTED_TO_clk_clk,                     --    clk.clk
			reset_reset_n               => CONNECTED_TO_reset_reset_n,               --  reset.reset_n
			enable_writeresponsevalid_n => CONNECTED_TO_enable_writeresponsevalid_n  -- enable.writeresponsevalid_n
		);


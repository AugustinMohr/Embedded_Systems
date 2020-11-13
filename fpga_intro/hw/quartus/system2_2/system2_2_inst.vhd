	component system2_2 is
		port (
			clk_clk                                : in  std_logic                    := 'X';             -- clk
			reset_reset_n                          : in  std_logic                    := 'X';             -- reset_n
			a_7_segment_0_conduit_selseg_export    : out std_logic_vector(7 downto 0);                    -- export
			a_7_segment_0_conduit_ledbutton_export : out std_logic_vector(3 downto 0);                    -- export
			a_7_segment_0_conduit_nseldig_export   : out std_logic_vector(5 downto 0);                    -- export
			a_7_segment_0_conduit_nbutton_export   : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			a_7_segment_0_conduit_reset_led_export : out std_logic                                        -- export
		);
	end component system2_2;

	u0 : component system2_2
		port map (
			clk_clk                                => CONNECTED_TO_clk_clk,                                --                             clk.clk
			reset_reset_n                          => CONNECTED_TO_reset_reset_n,                          --                           reset.reset_n
			a_7_segment_0_conduit_selseg_export    => CONNECTED_TO_a_7_segment_0_conduit_selseg_export,    --    a_7_segment_0_conduit_selseg.export
			a_7_segment_0_conduit_ledbutton_export => CONNECTED_TO_a_7_segment_0_conduit_ledbutton_export, -- a_7_segment_0_conduit_ledbutton.export
			a_7_segment_0_conduit_nseldig_export   => CONNECTED_TO_a_7_segment_0_conduit_nseldig_export,   --   a_7_segment_0_conduit_nseldig.export
			a_7_segment_0_conduit_nbutton_export   => CONNECTED_TO_a_7_segment_0_conduit_nbutton_export,   --   a_7_segment_0_conduit_nbutton.export
			a_7_segment_0_conduit_reset_led_export => CONNECTED_TO_a_7_segment_0_conduit_reset_led_export  -- a_7_segment_0_conduit_reset_led.export
		);


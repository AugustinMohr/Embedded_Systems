
module system2_2 (
	a_7_segment_0_conduit_ledbutton_export,
	a_7_segment_0_conduit_nbutton_export,
	a_7_segment_0_conduit_nseldig_export,
	a_7_segment_0_conduit_reset_led_export,
	a_7_segment_0_conduit_selseg_export,
	clk_clk,
	reset_reset_n);	

	output	[3:0]	a_7_segment_0_conduit_ledbutton_export;
	input	[3:0]	a_7_segment_0_conduit_nbutton_export;
	output	[5:0]	a_7_segment_0_conduit_nseldig_export;
	output		a_7_segment_0_conduit_reset_led_export;
	output	[7:0]	a_7_segment_0_conduit_selseg_export;
	input		clk_clk;
	input		reset_reset_n;
endmodule

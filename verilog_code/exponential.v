module exponential(
	input clk, reset,
	input [5:0] duration,
	input [15:0] full_sample,
	output [15:0] decayed_sample,
	output sample_ready
    );

	wire [9:0] exp_constant;
	wire [25:0] sout_intermed;
	wire [25:0] sout_intermed2;
	wire next_sample_ready = (sout_intermed != sout_intermed2);

	exponential_rom our_exponential_rom(.clk(clk), .duration(duration), .dout(exp_constant));
	
	assign sout_intermed = ($signed({1'b0,exp_constant}) * $signed(full_sample));

	dffr #(26) sout_wait(.clk(clk), .r(reset), .d(sout_intermed), .q(sout_intermed2));
	dffr #(1) srout_wait(.clk(clk), .r(reset), .d(next_sample_ready), .q(sample_ready));

	assign decayed_sample = $signed(sout_intermed2) / $signed(1024);

endmodule

module exponential_tb();

	reg clk, reset;
	reg [5:0] duration;
	reg [15:0] full_sample;
	wire [15:0] decayed_sample;
	wire sample_ready;

	exponential our_exponential(.clk(clk), .reset(reset), .duration(duration), 
		.full_sample(full_sample), .decayed_sample(decayed_sample),
		.sample_ready(sample_ready));

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #2 clk = ~clk;
        reset = 1'b0;
        forever #2 clk = ~clk;
    end

    initial begin
	duration = 6'd16;
	full_sample = 16'b100010001000;
	#10000
	$stop;
    end

endmodule

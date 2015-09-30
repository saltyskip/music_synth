module echo_tb();

	reg clk, reset, new_sample_in;
	reg [5:0] duration;
	reg [15:0] decayed_sample;
	wire [15:0] sample_out;
	wire sample_ready;

	echo our_echo(.clk(clk), .reset(reset), .new_sample_in(new_sample_in), .duration(duration),
		.sample_in(decayed_sample), .sample_out(sample_out), .new_sample_out(sample_ready));

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
	decayed_sample = 16'b100010001000;
	new_sample_in = 1'b0;
	#22
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b100010001010;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b100010011000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b1000100010110;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b101010001000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b010001000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b100010001010;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b100010011000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b1000100010110;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b101010001000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	decayed_sample = 16'b010001000;
	new_sample_in = 1'b1;
	#4 new_sample_in = 1'b0;
	#100
	$stop;
    end

endmodule

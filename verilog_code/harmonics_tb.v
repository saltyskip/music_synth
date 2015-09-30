module harmonics_tb;
	reg clk, reset;
	reg [2:0] meta;
	reg [19:0] step_size;
	reg [15:0] hsample;
	reg gns;
	wire [15:0] sout;

	harmonics our_harmonics(.clk(clk), .reset(reset), .step_size(step_size), .meta(meta),
		.unharmonicked_sample(hsample), .generate_next_sample(gns), .sample_out(sout));

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        gns = 1'b0;
        forever begin
		#130 gns = 1'b1;
		#10 gns = 1'b0;
	end
    end

    initial begin
	meta = 3'b0;

	hsample = 16'b10000_00000;
	step_size = 20'b10000_00000;
	#5000;
    end

endmodule

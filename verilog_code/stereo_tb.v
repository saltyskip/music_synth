module stereo_tb();
   reg clk, reset;
   reg [15:0] codec_sample;
   wire [15:0] codec_sample_left;
   wire [15:0] codec_sample_right;

   stereo DUT(
    	.clk(clk),
        .reset(reset),
        .codec_sample(codec_sample),
        .codec_sample_right(codec_sample_right),
        .codec_sample_left(codec_sample_left)
    );

        // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end



    initial begin
        #10
	codec_sample = 16'b1000_0000_0000_1000;
	#50000
    	$stop;
    end



endmodule

module aggregator(
	input [9:0] in_use,
	input [159:0] samples,
	input clk, reset,

	//compiles the average of all samples
	output [15:0] sample_out, 
	output [15:0] sample_out_left,
	output [15:0] sample_out_right    
);

	wire [3:0] numSamples;
	wire [25:0] interMed;
	wire [25:0] pre_interMed1;
	wire [25:0] pre_interMed2;
	wire [25:0] post_interMed1;
	wire [25:0] post_interMed2;
	reg [25:0] interMed2;

	//add up all the samples should be zero if not in use
	assign pre_interMed1 = $signed(samples[15:0]) + $signed(samples[31:16]) + $signed(samples[47:32]) + 
			$signed(samples[63:48]) + $signed(samples[79:64]);
	assign pre_interMed2 = $signed(samples[95:80]) + 
			$signed(samples[111:96]) + $signed(samples[127:112]) + $signed(samples[143:128]) +
			$signed(samples[159:144]);
	
	dffr #(52) addition_wait(.clk(clk), .r(reset), .d({pre_interMed1, pre_interMed2}), .q({post_interMed1, post_interMed2}));

	assign interMed = post_interMed1+post_interMed2;

	//counts the number of samples
	assign numSamples = in_use[0] + in_use[1] + in_use[2] + in_use[3] + in_use[4] + in_use[5] + 
				in_use[6] + in_use[7] + in_use[8] + in_use[9];  
	
	always @ (*) begin
		
		case(numSamples)
			4'd1    :   interMed2 = $signed(interMed);
			4'd2    :   interMed2 = ($signed(interMed) * $signed(40'd512)) / $signed(40'd1024); 
			4'd3    :   interMed2 = ($signed(interMed) * $signed(40'd256)) / $signed(40'd1024); 
					//interMed2 = ($signed(interMed) * $signed(40'd342)) / $signed(40'd1024); 
			4'd4    :   interMed2 = ($signed(interMed) * $signed(40'd256)) / $signed(40'd1024); 
			4'd5    :   interMed2 = ($signed(interMed) * $signed(40'd256)) / $signed(40'd1024); 
					//interMed2 = ($signed(interMed) * $signed(40'd205)) / $signed(40'd1024); 
			4'd6    :   interMed2 = ($signed(interMed) * $signed(40'd256)) / $signed(40'd1024); 
					//interMed2 = ($signed(interMed) * $signed(40'd171)) / $signed(40'd1024); 
			4'd7    :   interMed2 = ($signed(interMed) * $signed(40'd256)) / $signed(40'd1024); 
					//interMed2 = ($signed(interMed) * $signed(40'd147)) / $signed(40'd1024); 
			4'd8    :   interMed2 = ($signed(interMed) * $signed(40'd128)) / $signed(40'd1024); 
			4'd9    :   interMed2 = ($signed(interMed) * $signed(40'd128)) / $signed(40'd1024);
					//interMed2 = ($signed(interMed) * $signed(40'd114)) / $signed(40'd1024); 
			4'd10   :   interMed2 = ($signed(interMed) * $signed(40'd128)) / $signed(40'd1024);
					//interMed2 = ($signed(interMed) * $signed(40'd103)) / $signed(40'd1024); 
 			default :   interMed2 = $signed(interMed);
		endcase
	end 
	assign sample_out = {interMed2[25], interMed2[14:0]};	

	stereo our_stereo(
    		.clk(clk),
        	.reset(reset),
        	.codec_sample(sample_out),
        	.codec_sample_right(sample_out_right),
        	.codec_sample_left(sample_out_left)
    	);

	

endmodule

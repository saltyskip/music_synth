module stereo(
    input clk,
    input reset,
    input beat,
    input [15:0] codec_sample,
    output [15:0] codec_sample_left,
    output [15:0] codec_sample_right
);
    wire [4:0] percent_sample;
    reg [4:0] next_percent_sample;
    reg [25:0] flooded_sample_left;

    
    wire [39:0] count;
    wire enabler;
    reg [39:0] next_count;

    dffr #(40) count_flop(.d(next_count), .q(count), .r(reset), .clk(clk));
    always @ (*) begin
	case(count)
		40'd250000000: next_count = 40'd0;
		default: next_count = count + 40'd1;
	endcase
    end

    assign enabler = reset ? 0 : (count == 40'd250000000);
    
    

    dffre #(5) percent_sample_flop(.clk(clk), .d(next_percent_sample), .q(percent_sample),
				 .r(reset), .en(enabler));

    always @(*) begin
	case(percent_sample) 
		5'd0:  next_percent_sample = 5'd1;
		5'd1:  next_percent_sample = 5'd2;
		5'd2:  next_percent_sample = 5'd3;
		5'd3:  next_percent_sample = 5'd4;
		5'd4:  next_percent_sample = 5'd5;
		5'd5:  next_percent_sample = 5'd6;
		5'd6:  next_percent_sample = 5'd7;
		5'd7:  next_percent_sample = 5'd8;
		5'd8:  next_percent_sample = 5'd9;
		5'd9:  next_percent_sample = 5'd10;
		5'd10: next_percent_sample = 5'd11;
		5'd11: next_percent_sample = 5'd12;
		5'd12: next_percent_sample = 5'd13;
		5'd13: next_percent_sample = 5'd14;
		5'd14: next_percent_sample = 5'd15;
		5'd15: next_percent_sample = 5'd0;
		default: next_percent_sample = 5'd0;
	endcase
	case(percent_sample) 
		5'd0:  flooded_sample_left = 15'd0;
		5'd1:  flooded_sample_left = $signed(codec_sample)>>>3;
		5'd2:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd2))>>>3;
		5'd3:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd3))>>>3;
		5'd4:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd4))>>>3;
		5'd5:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd5))>>>3; 
		5'd6:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd6))>>>3;
		5'd7:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd7))>>>3;
		5'd8:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd8))>>>3;
		5'd9:  flooded_sample_left = ($signed(codec_sample) * $signed(25'd7))>>>3;
		5'd10: flooded_sample_left = ($signed(codec_sample) * $signed(25'd6))>>>3; 
		5'd11: flooded_sample_left = ($signed(codec_sample) * $signed(25'd5))>>>3; 
		5'd12: flooded_sample_left = ($signed(codec_sample) * $signed(25'd4))>>>3;
		5'd13: flooded_sample_left = ($signed(codec_sample) * $signed(25'd3))>>>3;
		5'd14: flooded_sample_left = ($signed(codec_sample) * $signed(25'd2))>>>3;
		5'd15: flooded_sample_left = $signed(codec_sample)>>>3;
		default: flooded_sample_left = 25'd0;
	endcase
     end
     assign codec_sample_left = {flooded_sample_left[25], flooded_sample_left[14:0]};
     assign codec_sample_right = $signed(codec_sample) - $signed(codec_sample_left);
   



endmodule

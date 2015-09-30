// NOTE: ready sample comes out two clock cycles later due to flip flops
// added to meet timing constraints. Two flip flops were added to wait the "sample ready"
// signal in the note player to compensate.
// Consider doing one or two more to compensate for wait dt sine reader?

module harmonics(
    input clk, reset,
    input [19:0] step_size,
    input [2:0] meta,
    input generate_next_sample,
    input [15:0] unharmonicked_sample,
    output new_sample_out,
    output [15:0] sample_out
);

    wire [3:0] ds; // sine reader note ready
    wire [15:0] hsr_out0;
    wire [15:0] hsr_out1;
    wire [15:0] hsr_out2;
    wire [15:0] hsr_out3;
    wire signed [15:0] harmonic_sample;
    wire [19:0] firsth = (step_size * 2) > 21'd1048575 ? step_size : (step_size * 2);
    wire [19:0] secondh = ((step_size * 2) + step_size) > 21'd1048575 ? step_size : ((step_size * 2) + step_size);
    wire [19:0] thirdh = (step_size * 4) > 21'd1048575 ? step_size : (step_size * 4);
    wire [19:0] fourthh = ((step_size * 4) + step_size) > 21'd1048575 ? step_size : ((step_size * 4) + step_size);
    wire [15:0] pre_sample_out;

   sine_reader harmonic_sine_reader0(.clk(clk), .reset(reset), .step_size(firsth),
       .generate_next(generate_next_sample), .meta(meta),
       .sample_ready(ds[0]), .sample(hsr_out0) );

   sine_reader harmonic_sine_reader1(.clk(clk), .reset(reset), .step_size(secondh),
       .generate_next(generate_next_sample), .meta(meta),
       .sample_ready(ds[1]), .sample(hsr_out1) );

   sine_reader harmonic_sine_reader2(.clk(clk), .reset(reset), .step_size(thirdh),
       .generate_next(generate_next_sample), .meta(meta),
       .sample_ready(ds[2]), .sample(hsr_out2) );

   sine_reader harmonic_sine_reader3(.clk(clk), .reset(reset), .step_size(fourthh),
      .generate_next(generate_next_sample), .meta(meta),
       .sample_ready(ds[3]), .sample(hsr_out3) );

    assign harmonic_sample = $signed(hsr_out0) / 2
                            + $signed(hsr_out1) / 4
			    + $signed(hsr_out2) / 8
                            + $signed(hsr_out3) / 8;

    assign pre_sample_out = ($signed(unharmonicked_sample) >>> 2) + ($signed(unharmonicked_sample) >>> 1) + 
		($signed(harmonic_sample) >>> 2);

    dffr #(17) sample_out_wait(.clk(clk), .r(reset), .d({pre_sample_out, (|ds)}), .q({sample_out, new_sample_out}));

endmodule

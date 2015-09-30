module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    input [2:0] meta,                  // data for effects and what not   

    output done_with_note,  // When we are done with the note this stays high.
    output reg [15:0] sample_out,  // Our sample output
    output reg new_sample_ready,  // Tells the codec when we've got a sample
    output in_use
);

	// Intermediate wires
	wire [15:0] full_sample;
	wire [15:0] full_sample1;
	wire [19:0] step_size;
	wire [5:0] duration;
	wire [5:0] next_duration;
	wire [5:0] loaded_note;
	wire [5:0] loaded_duration;
	wire [2:0] loaded_meta;
	wire [15:0] decayed_sample;
	wire [15:0] echoed_sample;
	wire new_echo_sample_ready, new_harmonic_sample_ready;
	wire new_sample_ready_wait1, new_sample_ready_wait2;
	wire exp_sample_ready;

//	dffr #(1) nsr_wait1(.clk(clk), .r(reset), .d(new_sample_ready_wait1), .q(new_sample_ready_wait2));
//	dffr #(1) nsr_wait2(.clk(clk), .r(reset), .d(new_sample_ready_wait2), .q(new_sample_ready));
	
	// Instantiations of other modules
	frequency_rom our_freq_rom (.clk(clk), .addr(loaded_note), .dout(step_size) );	

	sine_reader our_sine_reader(.clk(clk), .reset(reset), .step_size(step_size), 
		.generate_next(generate_next_sample & play_enable), .meta(loaded_meta), // generate_next will be one
									// cycle ahead of meta but it's okay b/c of
									// sine reader stuff
		.sample_ready(new_sample_ready_wait1), .sample(full_sample1) );

	dffr #(16) sine_reader_exponential_split(.clk(clk), .r(reset), .d(full_sample1), .q(full_sample));

	dffr #(6) duration_tracker(.clk(clk), .r(reset | load_new_note),
		.d(next_duration), .q(duration));

	dffre #(6) store_note(.clk(clk), .r(reset), .en(load_new_note), .d(note_to_load),
		.q(loaded_note));

	dffre #(6) store_duration(.clk(clk), .r(reset), .en(load_new_note), .d(duration_to_load),
		.q(loaded_duration));

	dffre #(3) store_metadata(.clk(clk), .r(reset), .en(load_new_note), .d(meta),
		.q(loaded_meta));

	assign next_duration = (beat & play_enable & in_use) ? duration + 6'b1 : duration;
	assign done_with_note = (duration == loaded_duration);
	assign in_use = /*load_new_note ? 0 :*/ (duration != loaded_duration);  // load new note because we have to wait
									// a clock cycle for loaded duration

	// Effects
	exponential our_exponential(.clk(clk), .reset(reset), .duration(duration), 
		.full_sample(full_sample), .decayed_sample(decayed_sample),
		.sample_ready(exp_sample_ready));

	echo our_echo(.clk(clk), .reset(reset), .new_sample_in(exp_sample_ready), .duration(duration),
		.sample_in(decayed_sample), .sample_out(echoed_sample), .new_sample_out(new_echo_sample_ready));
	
	wire [15:0] harmonic_sample;
	wire [15:0] scale_for_sum;
	harmonics our_harmonics(.clk(clk), .reset(reset), .step_size(step_size), .meta(meta),
		.generate_next_sample(generate_next_sample & play_enable),
		.new_sample_out(new_harmonic_sample_ready),
		.unharmonicked_sample(decayed_sample), .sample_out(harmonic_sample));

	always @(*) begin
		casex (loaded_meta)
//			3'b1: {sample_out, new_sample_ready} = in_use ? {harmonic_sample, new_harmonic_sample_ready} : 0; 
			default: {sample_out, new_sample_ready} = in_use ? {echoed_sample, new_echo_sample_ready} : 0;
		endcase
	end

	
endmodule

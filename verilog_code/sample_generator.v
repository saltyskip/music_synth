module sample_generator(
	input clk, reset, play_enable, beat,
	input [5:0] note,
	input [5:0] duration,
	input [2:0] meta,
	input type_signal,
	input load_count,
	input generate_next_sample,
	output advance,
	output [15:0] sample_out,
	output [15:0] sample_out_left,
	output [15:0] sample_out_right,
	output sample_ready,
	output [15:0] ns1, ns2, ns3, ns4, ns5, ns6, ns7, ns8, ns9, ns10
    );

    wire [9:0] in_use;
    wire [9:0] load_new;
    wire [9:0] note_done;
    wire [9:0] note_sample_ready;
    wire [9:0] arbited;
    wire [159:0] samples;
    wire next_advance;

    wire [5:0] next_advance_dur;
    wire [5:0] advance_dur;
    wire [5:0] loaded_duration;


    assign sample_ready = (|note_sample_ready);
    
    arbiter our_arbiter(.in(~in_use), .out(arbited));
    
    assign load_new = load_count ? (~type_signal ? arbited : 10'b0) : 0;

    // Duration tracker
    dffre #(6) advance_duration_tracker(.clk(clk), .r(load_count | advance | reset), .en(play_enable && beat),
        .d(next_advance_dur), .q(advance_dur));

    dffre #(6) store_advance_duration(.clk(clk), .r(reset), .en(load_count && type_signal), .d(duration), 
		.q(loaded_duration));

    //dffr #(1) store_advance(.clk(clk), .r(reset), .d(next_advance), .q(advance));
    assign next_advance_dur = advance_dur+1'b1;
    //assign next_advance = advance ? 0 : (next_advance_dur == loaded_duration);
    assign advance = (advance_dur == loaded_duration);
  

    aggregator our_aggregator(.samples(samples), .in_use(in_use), .clk(clk), .reset(reset), .sample_out(sample_out),
		.sample_out_left(sample_out_left), .sample_out_right(sample_out_right));


    assign ns1 = samples[15:0];
    assign ns2 = samples[31:16];
    assign ns3 = samples[47:32];
    assign ns4 = samples[63:48];
    assign ns5 = samples[79:64];
    assign ns6 = samples[95:80];
    assign ns7 = samples[111:96];
    assign ns8 = samples[127:112];
    assign ns9 = samples[143:128];
    assign ns10 = samples[159:144];
    assign samples[111:96] = 16'b0;
    assign samples[127:112] = 16'b0;
    assign samples[143:128] = 16'b0;
    assign samples[159:144] = 16'b0;
    assign in_use[9:6] = 4'b0;


    note_player note_player
    (
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .beat(beat),

        .note_to_load(note),
        .duration_to_load(duration),
	.meta(meta),

        .load_new_note(load_new[0]),
        .done_with_note(note_done[0]),
        .generate_next_sample(generate_next_sample),
        .sample_out(samples[15:0]),                        // sample_out
        .new_sample_ready(note_sample_ready[0]),
	.in_use(in_use[0])    
    );

    note_player note_player1
    (
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .beat(beat),

        .note_to_load(note),
        .duration_to_load(duration),
	.meta(meta),

        .load_new_note(load_new[1]),
        .done_with_note(note_done[1]),
        .generate_next_sample(generate_next_sample),
        .sample_out(samples[31:16]),
        .new_sample_ready(note_sample_ready[1]),
	.in_use(in_use[1])
    );

note_player note_player2(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[2]),
        .done_with_note(note_done[2]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[47:32]),
        .new_sample_ready(note_sample_ready[2]),
	.in_use(in_use[2])
);
note_player note_player3(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[3]),
        .done_with_note(note_done[3]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[63:48]),
        .new_sample_ready(note_sample_ready[3]),
	.in_use(in_use[3])
);
note_player note_player4(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[4]),
        .done_with_note(note_done[4]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[79:64]),
        .new_sample_ready(note_sample_ready[4]),
	.in_use(in_use[4])
);
note_player note_player5(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[5]),
        .done_with_note(note_done[5]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[95:80]),
        .new_sample_ready(note_sample_ready[5]),
	.in_use(in_use[5])
);
/*
note_player note_player6(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[6]),
        .done_with_note(note_done[6]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[111:96]),
        .new_sample_ready(note_sample_ready[6]),
	.in_use(in_use[6])
);
note_player note_player7(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[7]),
        .done_with_note(note_done[7]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[127:112]),
        .new_sample_ready(note_sample_ready[7]),
	.in_use(in_use[7])
);
note_player note_player8(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[8]),
        .done_with_note(note_done[8]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[143:128]),
        .new_sample_ready(note_sample_ready[8]),
	.in_use(in_use[8])
);
note_player note_player9(
        .clk(clk),
        .reset(reset),
        .play_enable(play_enable),
        .note_to_load(note),
        .duration_to_load(duration),
        .load_new_note(load_new[9]),
        .done_with_note(note_done[9]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
	.meta(meta),
        .sample_out(samples[159:144]),
        .new_sample_ready(note_sample_ready[9]),
	.in_use(in_use[9])
);*/

endmodule

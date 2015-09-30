//
//  music_player module
//
//  This music_player module connects up the MCU, song_reader, note_player,
//  beat_generator, and codec_conditioner. It provides an output that indicates
//  a new sample (new_sample_generated) which will be used in lab 5.
//

module music_player(
    // Standard system clock and reset
    input clk,
    input reset,

    // Our debounced and one-pulsed button inputs.
    input play_button,
    input next_button,

    // The raw new_frame signal from the ac97_if codec.
    input new_frame,

    // This output must go high for one cycle when a new sample is generated.
    output wire new_sample_generated,

    // Our final output sample to the codec. This needs to be synced to
    // new_frame.
    output wire [15:0] sample_out,
    output wire [15:0] sample_out_left,
    output wire [15:0] sample_out_right,

    // Ouput for wave displays
    output wire [15:0] ns1, ns2, ns3, ns4, ns5, ns6, ns7, ns8, ns9, ns10



);
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;


//
//  ****************************************************************************
//      Master Control Unit
//  ****************************************************************************
//   The reset_player output from the MCU is run only to the song_reader because
//   we don't need to reset any state in the note_player. If we do it may make
//   a pop when it resets the output sample.
//
 
    wire play;
    wire reset_player;
    wire [1:0] current_song;
    wire song_done;
    mcu mcu(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(current_song),
        .song_done(song_done)
    );

//
//  ****************************************************************************
//      Song Reader
//  ****************************************************************************
//
    wire [5:0] note_to_play;
    wire [5:0] duration_for_note;
    wire [2:0] meta;
    wire load_count;
    wire type_signal;
    wire advance;

    song_reader song_reader(
        .clk(clk),
        .reset(reset | reset_player),
        .play(play),
	.advance(advance),
        .song(current_song),
        .song_done(song_done),
        .note(note_to_play),
        .duration(duration_for_note),
        .load_count(load_count),
	.meta(meta),
        .type_signal(type_signal)
    );


//
//  ****************************************************************************
//      Sample Generator
//  ****************************************************************************
//

    wire [15:0] note_sample; // out, in to note_player
    wire [15:0] note_sample_left;
    wire [15:0] note_sample_right; 

    wire generate_next_sample;
    wire note_sample_ready;
    wire beat;

    sample_generator our_sample_generator(
	.clk(clk),
	.reset(reset|reset_player),
        .play_enable(play),
	.beat(beat),
	.note(note_to_play),
	.duration(duration_for_note),
	.meta(meta),
	.type_signal(type_signal),
	.load_count(load_count), 
	.generate_next_sample(generate_next_sample), 
	// out
	.advance(advance),
        .sample_out(note_sample),
	.sample_out_left(note_sample_left),
	.sample_out_right(note_sample_right),
	.sample_ready(note_sample_ready),
	.ns1(ns1), .ns2(ns2), .ns3(ns3), .ns4(ns4), .ns5(ns5),
	.ns6(ns6), .ns7(ns7), .ns8(ns8), .ns9(ns9), .ns10(ns10));


//   
//  ****************************************************************************
//      Note Player
//  ****************************************************************************
//  
/*
    wire in_use;
    note_player note_player(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
        .note_to_load(note_to_play),
        .duration_to_load(duration_for_note),
        .load_new_note(load_count && ~type_signal),
        .done_with_note(advance),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_sample),
        .new_sample_ready(note_sample_ready),
	.meta(meta),
	.in_use(in_use)    
);*/
      
//   
//  ****************************************************************************
//      Beat Generator
//  ****************************************************************************
//  By default this will divide the generate_next_sample signal (48kHz from the
//  codec's new_frame input) down by 1000, to 48Hz. If you change the BEAT_COUNT
//  parameter when instantiating this you can change it for simulation.
//  
    beat_generator #(.WIDTH(10), .STOP(BEAT_COUNT)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(generate_next_sample),
        .beat(beat)
    );

//  
//  ****************************************************************************
//      Codec Conditioner
//  ****************************************************************************
//  
    assign new_sample_generated = generate_next_sample;
    codec_conditioner codec_conditioner(
        .clk(clk),
        .reset(reset),
        .new_sample_in(note_sample),
	.new_sample_in_left(note_sample_left),
	.new_sample_in_right(note_sample_right),
        .latch_new_sample_in(note_sample_ready),
        .generate_next_sample(generate_next_sample),
        .new_frame(new_frame),
        .valid_sample(sample_out),
	.valid_sample_left(sample_out_left),
	.valid_sample_right(sample_out_right)
    );

endmodule

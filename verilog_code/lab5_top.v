module lab5_top(
    // Clock
    input clk,
    // AC97 interface
    input  AC97Clk,            // AC97 clock (~12 Mhz)
    input  SData_In,           // Serial data in (record data and status)
    output AC97Reset_n,        // Reset signal for AC97 controller/clock
    output SData_Out,          // Serial data out (control and playback data)
    output Sync,               // AC97 sync signal
    // Push button interface
    input  left_button,
    input  right_button,
    input  up_button,
    // LEDs
    output wire [3:0] leds_l,
    output wire [3:0] leds_r,
    // DVI Interface
    output chip_hsync,
    output chip_vsync,
    output [11:0] chip_data,
    output chip_reset,
    output chip_data_enable,
    output xclk,
    output xclk_n,
    // I2C
    inout  scl,
    inout  sda
);  
    // button_press_unit's WIDTH parameter is exposed here so that you can
    // reduce it in simulation.  Setting it to 1 effectively disables it.
    parameter BPU_WIDTH = 20;
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;

    // Our reset
    wire reset = up_button;
   
    // These signals are for determining which color to display
    wire [10:0] x;  // [0..1279]
    wire [9:0]  y;  // [0..1023]     
    // Color to display at the given x,y
    wire [7:0]  r, g, b;
 
//   
//  ****************************************************************************
//      Button processor units
//  ****************************************************************************
//  
    wire play;
    button_press_unit #(.WIDTH(BPU_WIDTH)) play_button_press_unit(
        .clk(clk),
        .reset(reset),
        .in(left_button),
        .out(play)
    );

    wire next;
    button_press_unit #(.WIDTH(BPU_WIDTH)) next_button_press_unit(
        .clk(clk),
        .reset(reset),
        .in(right_button),
        .out(next)
    );
       
//   
//  ****************************************************************************
//      The music player
//  ****************************************************************************
//         
    wire new_frame;
    wire [15:0] codec_sample_left;
    wire [15:0] codec_sample;
    wire [15:0] codec_sample_right;
    wire [15:0] flopped_sample;
    wire new_sample, flopped_new_sample;
    wire [15:0] ns1;
    wire [15:0] ns2;
    wire [15:0] ns3;
    wire [15:0] ns4;
    wire [15:0] ns5;
    wire [15:0] ns6;
    wire [15:0] ns7;
    wire [15:0] ns8;
    wire [15:0] ns9;
    wire [15:0] ns10;

  

    music_player #(.BEAT_COUNT(BEAT_COUNT)) music_player(
        .clk(clk),
        .reset(reset),
        .play_button(play),
        .next_button(next),
        .new_frame(new_frame), 
	.sample_out(codec_sample),
	.sample_out_left(codec_sample_left),
	.sample_out_right(codec_sample_right),
        .new_sample_generated(new_sample),
	.ns1(ns1), .ns2(ns2), .ns3(ns3), .ns4(ns4), .ns5(ns5),
	.ns6(ns6), .ns7(ns7), .ns8(ns8), .ns9(ns9), .ns10(ns10)
    );
    dff #(.WIDTH(17)) sample_reg (
        .clk(clk),
        .d({new_sample, codec_sample}),
        .q({flopped_new_sample, flopped_sample})
    );

 		
//   
//  ****************************************************************************
//      Wave display
//  ****************************************************************************
//  
     wave_display_top wd(
         .clk(clk),
         .reset(reset),
         .x(x),
         .y(y),
         .valid(chip_hsync && chip_vsync),
         .vsync(chip_vsync),
         .r(r),
         .g(g),
         .b(b),
         .sample(flopped_sample),
         .new_sample(flopped_new_sample),
	.note1_sample(ns1),
	.note2_sample(ns2),
	.note3_sample(ns3),
	.note4_sample(ns4),
	.note5_sample(ns5),
	.note6_sample(ns6),
	.note7_sample(ns7),
	.note8_sample(ns8),
	.note9_sample(ns9),
	.note10_sample(ns10)
     );

//   
//  ****************************************************************************
//      Codec interface
//  ****************************************************************************
//  
    // Output the sample onto the LEDs for the fun of it.
    //assign leds_l = codec_sample[15:12];
    assign leds_r = codec_sample[15:12];

    ac97_if codec(
        .ClkIn(clk),
        .Reset(1'b0), // The codec's internal reset MUST be tied to 0
        .PCM_Playback_Left(codec_sample_left), //Set these two to different
        .PCM_Playback_Right(codec_sample_right),  // samples to have stereo audio!
        .PCM_Record_Left(),
        .PCM_Record_Right(),
        .PCM_Playback_Accept(new_frame),  // Asserted each sample
        .AC97Reset_n(AC97Reset_n),
        .AC97Clk(AC97Clk),
        .Sync(Sync),
        .SData_Out(SData_Out),
        .SData_In(SData_In)
    );

//   
//  ****************************************************************************
//      Display management
//  ****************************************************************************
//  
    /* blinking leds to show life */
    wire [26:0] led_counter;

    dff #(.WIDTH (27)) led_div (
        .clk (clk),
        .d (led_counter + 27'd1),
        .q (led_counter)
    );
    assign leds_l = led_counter[26:23];

    dvi_controller_top ctrl(
        .clk    (clk),
        .enable (1'b1),
        .reset  (reset),
        .r      (r),
        .g      (g),
        .b      (b),

        .chip_data_enable (chip_data_enable),
        .chip_hsync       (chip_hsync),
        .chip_vsync       (chip_vsync),
        .chip_reset       (chip_reset),
        .chip_data        (chip_data),
        .xclk             (xclk),
        .xclk_n           (xclk_n),
        .x                (x),
        .y                (y)
    );
 
    // I2C controller to configure dvi interface
    i2c_emulator i2c_controller(
        .clk (clk),
        .rst (reset),

        .scl (scl),
        .sda (sda)
    );

endmodule

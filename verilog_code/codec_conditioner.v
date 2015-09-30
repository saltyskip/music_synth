/*
   module codec_conditioner
   by David Black-Schaffer, 15 December 2006

   This module interfaces to the ac97 codec module to insure that the output
   does not change while new_frame is high. What it does is store the *next*
   sample and output that immediately when new_frame goes high.

   When new_frame goes high it also generates a "generate_next_sample" signal
   which indicates to the rest of the system that it should generate the next
   sample. When that sample is ready it is latched in by asserting
   latch_new_sample_in while putting the new sample on new_sample_in.

   Remember that the codec runs at 48kHz and your logic runs at 100MHz. This
   means that you will have a lot of time between when you get
   a generate_next_sample and when you have to have your new_sample_in data
   read.

   Interface:
   input clk - clock
   input reset - reset

   For the codec:
   input new_frame - from the codec, goes high when the codec needs a new sample
   output valid_sample - outputs a valid sample to the codec

   For your system:
   input new_sample_in - the sample to pass to the codec on the next new_frame.
   input latch_new_sample_in - when high new_sample_in is latched.
   output generate_next_sample - tells you when to generate the next sample.

*/

module codec_conditioner(
   input clk,  // Our clock
   input reset,  // Our reset
   input [15:0] new_sample_in,  // The new sample for the next new_frame
   input [15:0] new_sample_in_left,
   input [15:0] new_sample_in_right,
   input latch_new_sample_in,   // Latches the value in new_sample_in
   output wire generate_next_sample, // 1 if it is time to generate a new sample
   input new_frame,  // Codec input triggering output of the next valid_sample
   output wire [15:0] valid_sample,  // Stable while new_frame is high
   output wire [15:0] valid_sample_left, //
   output wire [15:0] valid_sample_right //
);

   // Generate a one-pulse signal when new_frame goes high.
   wire previous_new_frame;
   dffre #(1) new_frame_state(
      .clk(clk),
      .r(reset),
      .en(1'b1),
      .d(new_frame),
      .q(previous_new_frame)
   );
   assign generate_next_sample = new_frame && ~previous_new_frame;

   // The next sample we are storing so we can output it immediately on the next
   // new_frame.
   wire [15:0] next_sample_latched;
   dffre #(16) next_sample_latch(
      .clk(clk),
      .r(reset),
      .en(latch_new_sample_in),
      .d(new_sample_in),
      .q(next_sample_latched)
   );

      // The next sample we are storing so we can output it immediately on the next
   // new_frame.
   wire [15:0] next_sample_latched_left;
   dffre #(16) next_sample_latch_left(
      .clk(clk),
      .r(reset),
      .en(latch_new_sample_in),
      .d(new_sample_in_left),
      .q(next_sample_latched_left)
   );

      // The next sample we are storing so we can output it immediately on the next
   // new_frame.
   wire [15:0] next_sample_latched_right;
   dffre #(16) next_sample_latch_right(
      .clk(clk),
      .r(reset),
      .en(latch_new_sample_in),
      .d(new_sample_in_right),
      .q(next_sample_latched_right)
   );

   // The sample we are currently outputting.
   // We latch in the new next_sample when we get a new_frame.
   wire [15:0] latched_current_sample;
   dffre #(16) current_sample_latch(
      .clk(clk),
      .r(reset),
      .en(generate_next_sample),
      .d(next_sample_latched),
      .q(latched_current_sample)
   );

      // The sample we are currently outputting.
   // We latch in the new next_sample when we get a new_frame.
   wire [15:0] latched_current_sample_left;
   dffre #(16) current_sample_latch_left(
      .clk(clk),
      .r(reset),
      .en(generate_next_sample),
      .d(next_sample_latched_left),
      .q(latched_current_sample_left)
   );

      // The sample we are currently outputting.
   // We latch in the new next_sample when we get a new_frame.
   wire [15:0] latched_current_sample_right;
   dffre #(16) current_sample_latch_right(
      .clk(clk),
      .r(reset),
      .en(generate_next_sample),
      .d(next_sample_latched_right),
      .q(latched_current_sample_right)
   );

   // To make sure we always output the next sample immediately when new_frame
   // goes high we define our output to be either what we've stored or the next
   // one.
   assign valid_sample = (generate_next_sample) ? next_sample_latched : latched_current_sample;
   assign valid_sample_left = (generate_next_sample) ? next_sample_latched_left : latched_current_sample_left; //
   assign valid_sample_right = (generate_next_sample) ? next_sample_latched_right : latched_current_sample_right; //
endmodule

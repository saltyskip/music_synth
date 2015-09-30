//  brute_force_sychronizer
//  26-Jan-2007 David Black-Schaffer
//   Basic 3-flip-flop brute-force synchronizer.
//   Inputs pass through a 3-ff chain and come out synchronized.
//
module brute_force_synchronizer(
    input clk,  // Standard system clock.
    input in,   // Async input 
    output out  // Virtually guaranteed sync output.
);

    // Our chain of three FFs.
    wire ff1_out, ff2_out;

    dff ff1(.clk(clk), .d(in), .q(ff1_out));
    dff ff2(.clk(clk), .d(ff1_out), .q(ff2_out));
    dff ff3(.clk(clk), .d(ff2_out), .q(out));

endmodule

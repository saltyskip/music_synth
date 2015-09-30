// button_press_unit
// 26-Jan-2007 David Black-Schaffer
//
// This module synchronizes, debounces, and one-pulses a button input.
//
module button_press_unit(
    input clk, 
    input reset, 	// Standard system clock and reset
    input in, 	// The async, bouncy input
    output out	// The synchronous, clean, one-pulsed output
);
    // WIDTH determines how long to wait for the bouncing to stop.
    parameter WIDTH = 20;

    // Synchronize our input to safely avoid metastability
    wire button_sync;
    brute_force_synchronizer sync(
        .clk(clk),
        .in(in),
        .out(button_sync)
    );

    // Debounce our synchronized input
    wire button_debounced;
    debouncer #(WIDTH) debounce(
        .clk(clk),
        .reset(reset),
        .in(button_sync),
        .out(button_debounced)
    );

    // One-pulse our debounced input
    one_pulse one_pulse(
        .clk(clk),
        .reset(reset),
        .in(button_debounced),
        .out(out)
    );

endmodule
   

/*******************************************************************************
* Module: dvi_defines.v
* Author: David Gal, Frank Nothaft, David Schneider
* Email: david.gal84@gmail.com, fnothaft@stanford.edu, dns@stanford.edu
* Project: EE108A DVI
* Description: Variables to drive 1280 x 1024 at 56 Hz
*
* Updated: 2012/02/07
*******************************************************************************/

// Parameters
`define COLOR_WIDTH 8
`define NUM_COLS 1280
`define NUM_ROWS 1024
`define log2NUM_COLS 11
`define log2NUM_ROWS 10

// For quick simulation:
// synthesis translate_off
`define H_SYNC_PULSE 1
`define H_BACK_PORCH 1
`define H_FRONT_PORCH 1
`define V_SYNC_PULSE 1
`define V_BACK_PORCH 1
`define V_FRONT_PORCH 1

// For synthesis:
`ifdef SYNTHESIS
// synthesis translate_on
`define H_SYNC_PULSE 112
`define H_BACK_PORCH 248
`define H_FRONT_PORCH 48
`define V_SYNC_PULSE 3
`define V_BACK_PORCH 38
`define V_FRONT_PORCH 1
// synthesis translate_off
`endif
// synthesis translate_on

// For both:
`define NUM_XCLKS_IN_ROW `NUM_COLS + `H_SYNC_PULSE + `H_BACK_PORCH + `H_FRONT_PORCH
`define log2NUM_XCLKS_IN_ROW   11
`define NUM_LINES_IN_FRAME `NUM_ROWS + `V_FRONT_PORCH + `V_SYNC_PULSE + `V_BACK_PORCH
`define log2NUM_LINES_IN_FRAME 11


/*******************************************************************************
* Module: sync_generators.v
* Author: David Gal, David Schneider
* Email: david.gal84@gmail.com, dns@stanford.edu
* Project: EE108A DVI
* Description: HSYNC and VSYNC generators
* 
* Updated: 2012/02/12
*******************************************************************************/

`include "dvi_defines.v"

module sync_generators(
    input clk,
    input reset,
    input enable,

    output wire hsync,
    output wire vsync,
    output wire valid_data,
    output reg [`log2NUM_COLS-1:0] x,
    output reg [`log2NUM_ROWS-1:0] y
);

    /* Regs and Wires */
    reg [`log2NUM_XCLKS_IN_ROW-1  :0] pixel_counter;
    reg [`log2NUM_LINES_IN_FRAME-1:0] hsync_counter;
    wire valid_h, valid_v;
    
    /* Logic for X, Y Outputs */
    assign valid_data = valid_h && valid_v;
    
    /* Counts pixels in a row...row counter is incemented every row */
    always @(posedge clk)
        if ((pixel_counter == `NUM_XCLKS_IN_ROW-1) || reset)
            pixel_counter <= 0;
        else if (enable)
            pixel_counter <= pixel_counter + 1;
        else
            pixel_counter <= pixel_counter;
 
    /* Combinational Logic for hsync */
    assign hsync = pixel_counter >= `H_SYNC_PULSE; 
 
    /* Count the hsyncs */
    always @(posedge clk)
        if ((hsync_counter == `NUM_LINES_IN_FRAME-1) || reset)
            hsync_counter <= 0;
        else if (enable && (pixel_counter == `NUM_XCLKS_IN_ROW-1))
            hsync_counter <= hsync_counter + 1;
        else
            hsync_counter <= hsync_counter;
 
    /* Comb L for vsync */
    assign vsync = (hsync_counter != `NUM_LINES_IN_FRAME)
                    && (hsync_counter >= (`V_SYNC_PULSE));
 
    assign valid_h = (pixel_counter >= (`H_SYNC_PULSE + `H_BACK_PORCH))
                     && (pixel_counter <= (`NUM_XCLKS_IN_ROW - `H_FRONT_PORCH));
    assign valid_v = (hsync_counter >= (`V_SYNC_PULSE + `V_BACK_PORCH))
                     && (hsync_counter <= (`NUM_LINES_IN_FRAME - `V_FRONT_PORCH));
 
    /* X & Y Generation */
    always @(posedge clk)
        if (~valid_h || reset)
            x <= 0;
        else if (enable)
            x <= x+1;
        else
            x <= x;
 
    always @(posedge clk)
        if (~valid_v || reset)
            y <= 0;
        else if (enable && (pixel_counter == `NUM_XCLKS_IN_ROW-1))
            y <= y+1;
        else
            y <= y;
 
endmodule

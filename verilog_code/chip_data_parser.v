/*******************************************************************************
* Module: chip_data_parser.v
* Author: David Schneider
* Email: dns@stanford.edu
* Project: EE108A DVI
* Description: Module to drive the data output from RGB data.
* 
* Updated: 2012/02/12
*******************************************************************************/

module chip_data_parser(
    input clk,
    input [7:0] r,
    input [7:0] g,
    input [7:0] b,
    input valid,

    output reg [11:0] chip_data,
    output reg chip_data_enable
);

    reg [23:0] pixel;
    always @(posedge clk) begin
        pixel <= {r, g, b};
        chip_data_enable <= valid;
    end

    /* Double-pumped flip-flop */
    always @(posedge clk or negedge clk)
        if (clk)
            chip_data <= pixel[11:0];
        else
            chip_data <= pixel[23:12];

endmodule

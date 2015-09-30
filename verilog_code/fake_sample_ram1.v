/*
 * A simple fake RAM that you can use to aid in debugging your wave display.
 */
module fake_sample_ram1 (
    input clk,
    input [8:0] addr,
    output reg [7:0] dout
);

    always @(posedge clk)
        dout = addr[6:0] + 8'd15;

endmodule

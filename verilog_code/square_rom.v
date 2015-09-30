module square_rom (
    input clk,
    input [9:0] addr,
    output reg [15:0] dout
);

    always @(posedge clk)
        dout = 16'd32767;

    
endmodule

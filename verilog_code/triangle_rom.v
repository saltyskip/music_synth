module triangle_rom (
    input clk,
    input [9:0] addr,
    output reg [15:0] dout
);

    always @(posedge clk)
        dout = addr * 9'd32 - 1'b1;

    
endmodule

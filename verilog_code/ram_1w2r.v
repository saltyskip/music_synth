/*
 * Instantiates a RAM.
 * The size of the RAM is WIDTH bits wide by DEPTH^2 words deep.
 */

module ram_1w2r #(parameter WIDTH = 8, parameter DEPTH = 8) (
    /* Dual read/write port A */
    input clka,
    input wea,
    input [DEPTH-1:0] addra,
    input [WIDTH-1:0] dina,
    output wire [WIDTH-1:0] douta,
    
    /* Read-only port B */
    input clkb,
    input [DEPTH-1:0] addrb,
    output wire [WIDTH-1:0] doutb
);

    reg [WIDTH-1:0] RAM [(2**DEPTH)-1:0];
    reg [DEPTH-1:0] read_addra;
    reg [DEPTH-1:0] read_addrb;

    always @(posedge clka) begin
        if (wea == 1'b1)
            RAM[addra] <= dina;
        read_addra <= addra;
    end

    always @(posedge clkb)
        read_addrb <= addrb;

    assign douta = RAM[read_addra];
    assign doutb = RAM[read_addrb];

endmodule

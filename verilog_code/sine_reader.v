module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,
    input [2:0] meta,

    output sample_ready,
    output wire [15:0] sample
);

    //states
    localparam SWIDTH = 22;

    wire [SWIDTH - 1:0] addr;
    dffre #(.WIDTH(SWIDTH)) state_reg (
        .clk(clk),
        .r(reset),
        .en(generate_next),
        .d(addr + step_size),
        .q(addr)
    );

    wire [9:0] sine_rom_addr = addr[20] ? ~addr[19:10] : addr[19:10];
    wire [15:0] sine_rom_out;
    wire [15:0] square_rom_out;
    wire [15:0] triangle_rom_out;
    reg [15:0] rom_out;

    always @(*) begin
	case(meta[2:1])
		2'b11: rom_out = square_rom_out;
		2'b10: rom_out = triangle_rom_out;
		default: rom_out = sine_rom_out;
	endcase
    end

    sine_rom sineRom (
        .clk(clk),
        .addr(sine_rom_addr),
        .dout(sine_rom_out)
    );
    square_rom squareRom (
        .clk(clk),
        .addr(sine_rom_addr),
        .dout(square_rom_out)
    );
    triangle_rom triangeRom (
        .clk(clk),
        .addr(sine_rom_addr),
        .dout(triangle_rom_out)
    );

    assign sample = addr[21] ? -rom_out : rom_out;

    wire almost_ready;
    dff #(.WIDTH(1)) ready_1 (
        .clk(clk),
        .d(generate_next),
        .q(almost_ready)
    );
    dff #(.WIDTH(1)) ready_2 (
        .clk(clk),
        .d(almost_ready),
        .q(sample_ready)
    );

endmodule

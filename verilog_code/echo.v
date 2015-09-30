`define RAMDEPTH 11
`define ECHOSW 2
`define INACTIVE 2'b00
`define FILL_RAM 2'b01
`define READ_AND_WRITE 2'b10

module echo(
	input clk,
	input reset,
	input [5:0] duration,
	input new_sample_in,
	input [15:0] sample_in,
	output reg [15:0] sample_out,
	output reg new_sample_out
    );

    reg [`ECHOSW-1:0] next_state;
    wire [`ECHOSW-1:0] state;
    wire [`RAMDEPTH-1:0] fill_write_address;
    wire [`RAMDEPTH-1:0] rw_write_address;
    wire [`RAMDEPTH-1:0] write_address = (state == `FILL_RAM) ? fill_write_address : rw_write_address;
    wire [`RAMDEPTH-1:0] stop_address = 11'b11111111111;  // no greater than 2^RAMDEPTH
    wire [`RAMDEPTH-1:0] read_address = (write_address == stop_address) ? 1'b0 : write_address + 1'b1;
    wire [15:0] read_sample;
    wire [9:0] exp_constant;
    wire [15:0] echo;
    wire [15:0] prepared_sample_out;
    wire [15:0] pre_prepared_sample_out;
    wire nso, nso1, nso2;

    // width = num data bits, depth = num address bits
    ram_1w2r #(.WIDTH(16), .DEPTH(`RAMDEPTH)) sample_ram(
        .clka(clk),
        .clkb(clk),
        .wea(new_sample_in),
        .addra(write_address),
        .dina(sample_in),
        .douta(),
        .addrb(read_address),
        .doutb(read_sample)
    );

    dffr #(`ECHOSW) echo_state_tracker(.clk(clk), .r(reset), .d(next_state), .q(state));

    dffre #(`RAMDEPTH) fill_ram_tracker(.clk(clk), .r(reset | next_state == `INACTIVE), .en(state == `FILL_RAM && new_sample_in),
	.d(read_address), .q(fill_write_address)); // note that read address is our next write address

    dffre #(`RAMDEPTH) rw_addr_tracker(.clk(clk), .r(reset | next_state == `INACTIVE), 
	.en(state == `READ_AND_WRITE && new_sample_in), .d(read_address), .q(rw_write_address));

    always @(*) begin
	casex ({state, new_sample_in, (write_address == stop_address)})  // stop address assigned above,
		{`INACTIVE, 1'b0, 1'bx}: next_state = `INACTIVE;	// could be parameterizable
		{`INACTIVE, 1'b1, 1'bx}: next_state = `FILL_RAM;
		{`FILL_RAM, 1'b1, 1'b1}: next_state = `READ_AND_WRITE;
		{`FILL_RAM, 1'bx, 1'bx}: next_state = `FILL_RAM;
		{`READ_AND_WRITE, 1'bx, 1'bx}: next_state = `READ_AND_WRITE;
		default: next_state = `INACTIVE;
	endcase

	case (state)
		`FILL_RAM: {new_sample_out, sample_out} = {new_sample_in, sample_in};
		default: {new_sample_out, sample_out} = {nso, prepared_sample_out};
	endcase
    end

    exponential_rom our_exponential_rom(.clk(clk), 
		.duration(((duration << 2) < duration) ? 6'b111111 : (duration << 2)), 
		.dout(exp_constant));
    dffr #(1) nso_wait(.clk(clk), .r(reset), .d(new_sample_in), .q(nso1));  // one clock cycle wait to match exp_rom lookup
    dffr #(1) nso_wait1(.clk(clk), .r(reset), .d(nso1), .q(nso2));

    assign echo = ($signed({1'b0,exp_constant}) * $signed(read_sample)) / $signed(1024);

    dffr #(17) echo_arith_wait(.clk(clk), .r(reset), .d({nso2, echo}), .q({nso, pre_prepared_sample_out}));

    assign prepared_sample_out = /*($signed(sample_in) >>> 2) + */($signed(sample_in) >>> 1) + 
		($signed(pre_prepared_sample_out) >>> 1);

    

endmodule

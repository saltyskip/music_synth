`define COUNTERWIDTH 8
`define STATEWIDTH 2
`define SAMPLEWIDTH 16
`define ARMED 2'b00
`define ACTIVE 2'b01
`define WAIT 2'b10

module wave_capture(
	input  clk,
	input  reset,
	input  new_sample_ready,
	input  [15:0] new_sample_in,
	input  wave_display_idle,
	output [8:0] write_address,
	output write_enable,
	output [7:0] write_sample,
	output read_index
    );
	wire [15:0] old_sample;
	wire pos_crossing = ($signed(old_sample) < 0) && ($signed(new_sample_in) > 0);
	wire next_read_index;
	wire [8:0] next_write_address;
	
	reg  [1:0] next_state;
	wire [1:0] curr_state;	

	reg  [7:0] next_count;
	wire [7:0] curr_count;

	wire [7:0] next_sample;

	dffr #(`STATEWIDTH+1) our_states(.clk(clk), .r(reset), 
			.d({next_state, next_read_index}),
			.q({curr_state, read_index}));

	dffr #(8) sample_storer(.clk(clk), .r(reset), .d(next_sample), .q(write_sample));	
	
	dffr #(9) addr_storer(.clk(clk), .r(reset), .d(next_write_address), .q(write_address));

	dffre #(`COUNTERWIDTH) our_counter(.clk(clk), .r(reset), .d(next_count), .q(curr_count), .en(new_sample_ready));
	
	dffre #(`SAMPLEWIDTH) store_curr_sample(.clk(clk), .r(reset), .en(new_sample_ready), 
			.d(new_sample_in), .q(old_sample));

	assign next_write_address = (curr_state == `ACTIVE) ? {~read_index, curr_count} : write_address;
	assign write_enable = (curr_state == `ACTIVE);
	assign next_read_index = ((curr_state == `ACTIVE) && (curr_count == 8'b11111111)) ? ~read_index : read_index;

	assign next_sample = ((curr_state == `ACTIVE) & new_sample_ready & (curr_count != 8'b11111111)) 
						? (old_sample[15:8] + 8'd128) : write_sample;  // Changed this to fix
											// all the things
	
	always @(*) begin

		casex ({ curr_state, pos_crossing, new_sample_ready, (curr_count == 8'b11111111), wave_display_idle })

			{ `ARMED, 4'b1xxx }:  { next_state, next_count } = { `ACTIVE, 8'b0 };
			{ `ARMED, 4'b0xxx }:  { next_state, next_count } = { `ARMED, 8'b0 };
			{ `ACTIVE, 4'bxx1x }: { next_state, next_count } = { `WAIT, curr_count };
			{ `ACTIVE, 4'bx10x }: { next_state, next_count } = { `ACTIVE, curr_count+1'b1 };
			{ `ACTIVE, 4'bx0xx }: { next_state, next_count } = { `ACTIVE, curr_count };
			{ `WAIT, 4'bxxx0 }:   { next_state, next_count } = { `WAIT, 8'b0 };
			{ `WAIT, 4'bxxx1 }:   { next_state, next_count } = { `ARMED, 8'b0 };

			default:  { next_state, next_count } = { `ARMED, 8'b0 };
		endcase
	end




endmodule

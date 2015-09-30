// TODO fix the tall crap, it fails completely

module wave_display(
	input clk,
	input reset,
	input [10:0] x,
	input [9:0] y,
	input valid,
	input read_index,
	input [7:0] read_value,
	input [7:0] note1_value,
	input [7:0] note2_value,
	input [7:0] note3_value,
	input [7:0] note4_value,
	input [7:0] note5_value,
	input [7:0] note6_value,
	input [7:0] note7_value,
	input [7:0] note8_value,	
	input [7:0] note9_value,
	input [7:0] note10_value,

	output reg [8:0] read_address,
	output reg valid_pixel,
	output reg [7:0] r,
	output reg [7:0] g,
	output reg [7:0] b
    );

	// Intermediate wires
	wire [7:0] prev_read_value;
	wire [7:0] prev_note1_value;
	wire [7:0] prev_note2_value;
	wire [7:0] prev_note3_value;
	wire [7:0] prev_note4_value;
	wire [7:0] prev_note5_value;
	wire [7:0] prev_note6_value;
	wire [7:0] prev_note7_value;
	wire [7:0] prev_note8_value;	
	wire [7:0] prev_note9_value;
	wire [7:0] prev_note10_value;
	wire [8:0] curr_address;  // current stored address
	wire [8:0] prev_address;  // previous stored address
	wire in_y_bounds;
	wire in_x_bounds;
	wire in_wave_bounds;
	wire boundary_pixel;
	wire read_addr_changed = (curr_address != prev_address);
	wire ib1, bp1, tall1;
	wire ib2, bp2, tall2;
	wire ib3, bp3, tall3;
	wire ib4, bp4, tall4;
	wire ib5, bp5, tall5;
	wire ib6, bp6;
	wire ib7, bp7;
	wire ib8, bp8;
	wire ib9, bp9;
	wire ib10, bp10;
	

	// Flip flop to keep track of our previous RAM addr
	dffr #(9) addr_tracker1(.clk(clk), .r(reset), .d(read_address), .q(curr_address));
	dffr #(9) addr_tracker2(.clk(clk), .r(reset), .d(curr_address), .q(prev_address));
	
	// Flip flop to keep track of our previous RAM data
	dffre #(88) data_tracker(.clk(clk), .r(reset), .en(read_addr_changed), 
		.d({read_value, note1_value, note2_value, note3_value, note4_value, note5_value, 
			note6_value, note7_value, note8_value, note9_value, note10_value}),
		.q({prev_read_value, prev_note1_value, prev_note2_value, prev_note3_value, 
			prev_note4_value, prev_note5_value, prev_note6_value, prev_note7_value, 
			prev_note8_value, prev_note9_value, prev_note10_value}));

	// master wave
	assign in_wave_bounds = ((y[8:1] >= prev_read_value) & (y[8:1] <= read_value)) 
				| ((y[8:1] <= prev_read_value) & (y[8:1] >= read_value));
	assign boundary_pixel = (y[8:1] >= prev_read_value-1'b1 & y[8:1] <= read_value+1'b1) 
				| (y[8:1] <= prev_read_value+1'b1 & y[8:1] >= read_value-1'b1);
	assign in_x_bounds = x >= 256 & x <= 768;
	assign in_y_bounds = (y[9] == 1'b0);


	always @(*) begin
		casex (x[10:8])
			3'b001: read_address = {read_index, 1'b0, x[7:1]};
			3'b010: read_address = {read_index, 1'b1, x[7:1]};	
			default: read_address = 9'b0;
		endcase

		// set color
		casex ({(~in_x_bounds || ~in_y_bounds), in_wave_bounds, boundary_pixel,
			ib1, bp1, tall1,
			ib2, bp2, tall2,
			ib3, bp3, tall3,
			ib4, bp4, tall4,
			ib5, bp5, tall5})
			18'b1xxxxxxx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h000000,valid};
			18'b01xxxxxx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'hFFFFFF,valid};
			18'b001xxxxx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h696969,valid};
			18'bxxx1xxxx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h5A3278,valid};
			18'bxxx010xx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h321B42,valid};
			18'bxxx011xx_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h452654,valid};
			18'bxxxxxx1x_xxxxxxxxxx: {r,g,b,valid_pixel} = {24'h852064,valid};
			18'bxxxxxx01_0xxxxxxxxx: {r,g,b,valid_pixel} = {24'h471136,valid};
			18'bxxxxxx01_1xxxxxxxxx: {r,g,b,valid_pixel} = {24'h66184C,valid};
			18'bxxxxxxxx_x1xxxxxxxx: {r,g,b,valid_pixel} = {24'h2842A0,valid};
			18'bxxxxxxxx_x010xxxxxx: {r,g,b,valid_pixel} = {24'h142252,valid};
			18'bxxxxxxxx_x011xxxxxx: {r,g,b,valid_pixel} = {24'h1F327A,valid};
			18'bxxxxxxxx_xxxx1xxxxx: {r,g,b,valid_pixel} = {24'h33755E,valid};
			18'bxxxxxxxx_xxxx010xxx: {r,g,b,valid_pixel} = {24'h1A3D31,valid};
			18'bxxxxxxxx_xxxx011xxx: {r,g,b,valid_pixel} = {24'h275847,valid};
			18'bxxxxxxxx_xxxxxxx1xx: {r,g,b,valid_pixel} = {24'h964B23,valid};
			18'bxxxxxxxx_xxxxxxx010: {r,g,b,valid_pixel} = {24'h4D271B,valid};
			18'bxxxxxxxx_xxxxxxx011: {r,g,b,valid_pixel} = {24'h6F391F,valid};
			default: {r,g,b,valid_pixel} = {24'h000000,valid};
		endcase
		/*casex({(~in_x_bounds || ~in_y_bounds), in_wave_bounds, boundary_pixel,
			ib1, bp1, tall1,
			ib2, bp2, tall2,
			ib3, bp3, tall3,
			ib4, bp4, tall4,
			ib5, bp5, tall5,
			ib6, bp6,
			ib7, bp7,
			ib8, bp8,
			ib9, bp9,
			ib10, bp10})
			28'b1xxxxxx_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h000000,valid}; // out of bounds
			28'b01xxxxx_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'hFFFFFF,valid}; // master
			28'b001xxxx_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h696969,valid};
			28'b0xx1xxx_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h5A3278,valid}; // 1
			28'b0xx010x_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h301A40,valid};
			28'b0xx010x_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h452654,valid}; // interpolated
			28'b0xxxxx1_xxxxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h852064,valid}; // 2
			28'b0xxxxx0_10xxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h471136,valid};
			28'b0xxxxx0_10xxxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h66184C,valid};
			28'b0xxxxxx_xx1xxxxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h2842A0,valid}; // 3
			28'b0xxxxxx_xx010xxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h142252,valid};
			28'b0xxxxxx_xx010xxxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h1F327A,valid};
			28'b0xxxxxx_xxxxx1xxxx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h33755E,valid}; // 4
			28'b0xxxxxx_xxxxx010xx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h1A3D31,valid};
			28'b0xxxxxx_xxxxx010xx_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h275847,valid};
			28'b0xxxxxx_xxxxxxxx1x_xxxxxxxxxx:    {r,g,b,valid_pixel} = {24'h964B23,valid}; // 5
			28'b0xxxxxx_xxxxxxxx01_0xxxxxxxxx:    {r,g,b,valid_pixel} = {24'h4D271B,valid};
			28'b0xxxxxx_xxxxxxxx01_0xxxxxxxxx:    {r,g,b,valid_pixel} = {24'h6F391F,valid};
			default: {r,g,b,valid_pixel} = {24'h000000,valid};
		endcase*/

	end


	// Other wave assignments

	// wave 1
	assign ib1 = (y[8:1] >= prev_note1_value) & (y[8:1] <= note1_value)
				| ((y[8:1] <= prev_note1_value) & (y[8:1] >= note1_value));
	assign tall1 = ((prev_note1_value < note1_value) ? 
		(note1_value - prev_note1_value) : (prev_note1_value - note1_value) > 5'd20);
	assign bp1 = (y[8:1] >= prev_note1_value-1'b1 & y[8:1] <= note1_value+1'b1)	
				| (y[8:1] <= prev_note1_value+1'b1 & y[8:1] >= note1_value-1'b1);
	
	// wave 2
	assign ib2 = (y[8:1] >= prev_note2_value) & (y[8:1] <= note2_value)
				| ((y[8:1] <= prev_note2_value) & (y[8:1] >= note2_value));
	assign tall2 = (prev_note2_value <= note2_value + 4'd10) || (note2_value <= prev_note2_value + 4'd10);
	assign bp2 = (y[8:1] >= prev_note2_value-1'b1 & y[8:1] <= note2_value+1'b1)	
				| (y[8:1] <= prev_note2_value+1'b1 & y[8:1] >= note2_value-1'b1);
	
	// wave 3
	assign ib3 = (y[8:1] >= prev_note3_value) & (y[8:1] <= note3_value)
				| ((y[8:1] <= prev_note3_value) & (y[8:1] >= note3_value));
	assign tall3 = (prev_note3_value <= note3_value + 4'd10) || (note3_value <= prev_note3_value + 4'd10);
	assign bp3 = (y[8:1] >= prev_note3_value-1'b1 & y[8:1] <= note3_value+1'b1)
				| (y[8:1] <= prev_note3_value+1'b1 & y[8:1] >= note3_value-1'b1);
	
	// wave 4)
	assign ib4 = (y[8:1] >= prev_note4_value) & (y[8:1] <= note4_value)
				| ((y[8:1] <= prev_note4_value) & (y[8:1] >= note4_value));
	assign tall4 = (prev_note1_value <= note4_value + 4'd10) || (note4_value <= prev_note4_value + 4'd10);
	assign bp4 = (y[8:1] >= prev_note4_value-1'b1 & y[8:1] <= note4_value+1'b1)
				| (y[8:1] <= prev_note4_value+1'b1 & y[8:1] >= note4_value-1'b1);
	
	// wave 5
	assign ib5 = (y[8:1] >= prev_note5_value) & (y[8:1] <= note5_value)
				| ((y[8:1] <= prev_note5_value) & (y[8:1] >= note5_value));
	assign tall5 = (prev_note5_value <= note5_value + 4'd10) || (note5_value <= prev_note5_value + 4'd10);
	assign bp5 = (y[8:1] >= prev_note5_value-1'b1 & y[8:1] <= note5_value+1'b1)
				| (y[8:1] <= prev_note5_value+1'b1 & y[8:1] >= note5_value-1'b1);
	
	// wave 6
	assign ib6 = (y[8:1] >= prev_note6_value) & (y[8:1] <= note6_value)
				| ((y[8:1] <= prev_note6_value) & (y[8:1] >= note6_value));

	assign bp6 = (y[8:1] >= prev_note6_value-1'b1 & y[8:1] <= note6_value+1'b1)
				| (y[8:1] <= prev_note6_value+1'b1 & y[8:1] >= note6_value-1'b1);
	
	// wave 7
	assign ib7 = (y[8:1] >= prev_note7_value) & (y[8:1] <= note7_value)	
				| ((y[8:1] <= prev_note7_value) & (y[8:1] >= note7_value));

	assign bp7 = (y[8:1] >= prev_note7_value-1'b1 & y[8:1] <= note7_value+1'b1)
				| (y[8:1] <= prev_note7_value+1'b1 & y[8:1] >= note7_value-1'b1);
	
	// wave 8
	assign ib8 = (y[8:1] >= prev_note8_value) & (y[8:1] <= note8_value)
				| ((y[8:1] <= prev_note8_value) & (y[8:1] >= note8_value));

	assign bp8 = (y[8:1] >= prev_note8_value-1'b1 & y[8:1] <= note8_value+1'b1)
				| (y[8:1] <= prev_note8_value+1'b1 & y[8:1] >= note8_value-1'b1);
	
	// wave 9
	assign ib9 = (y[8:1] >= prev_note9_value) & (y[8:1] <= note9_value)
				| ((y[8:1] <= prev_note9_value) & (y[8:1] >= note9_value));

	assign bp9 = (y[8:1] >= prev_note9_value-1'b1 & y[8:1] <= note9_value+1'b1)
				| (y[8:1] <= prev_note9_value+1'b1 & y[8:1] >= note9_value-1'b1);
	
	// wave 10
	assign ib10 = (y[8:1] >= prev_note10_value) & (y[8:1] <= note10_value)
				| ((y[8:1] <= prev_note10_value) & (y[8:1] >= note10_value));

	assign bp10 = (y[8:1] >= prev_note10_value-1'b1 & y[8:1] <= note10_value+1'b1)
				| (y[8:1] <= prev_note10_value+1'b1 & y[8:1] >= note10_value-1'b1);
	


endmodule

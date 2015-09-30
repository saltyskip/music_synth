module wave_display_tb;

	reg clk, reset, valid, read_index;
	wire [10:0] x;
	wire [9:0] y;
	wire [7:0] read_value;
	wire [8:0] read_address;
	wire valid_pixel;
	wire [7:0] r;
	wire [7:0] g;
	wire [7:0] b;
	wire [7:0] note1_value;
	wire [7:0] note2_value;
	wire [7:0] note3_value;
	wire [7:0] note4_value = 1'b0;
	wire [7:0] note5_value = 1'b0;
	wire [7:0] note6_value = 1'b0;
	wire [7:0] note7_value = 1'b0;
	wire [7:0] note8_value = 1'b0;	
	wire [7:0] note9_value = 1'b0;
	wire [7:0] note10_value = 1'b0;

	wire chip_hsync, chip_vsync;
	wire chip_data_enable;
	wire [11:0] chip_data;
	wire chip_reset;
	wire xclk, xclk_n;

	wave_display DUT(.clk(clk), .reset(reset), .valid(chip_hsync && chip_vsync), .read_index(read_index),
		.x(x), .y(y), .read_value(read_value), .read_address(read_address),
		.note1_value(note1_value),
		.note2_value(note2_value),
		.note3_value(note3_value),
		.note4_value(note4_value),
		.note5_value(note5_value),
		.note6_value(note6_value),
		.note7_value(note7_value),
		.note8_value(note8_value),	
		.note9_value(note9_value),
		.note10_value(note10_value),
		.valid_pixel(valid_pixel), .r(r), .g(g), .b(b));

	fake_sample_ram our_fake_ram(.clk(clk), .addr(read_address), .dout(read_value));
	fake_sample_ram1 our_fake_ram1(.clk(clk), .addr(read_address), .dout(note1_value));
	fake_sample_ram2 our_fake_ram2(.clk(clk), .addr(read_address), .dout(note2_value));

    dvi_controller_top ctrl(
	// In
        .clk    (clk),
        .enable (1'b1),
        .reset  (reset),
        .r      (r),
        .g      (g),
        .b      (b),

	// Out
        .chip_data_enable (chip_data_enable),
        .chip_hsync       (chip_hsync),
        .chip_vsync       (chip_vsync),
        .chip_reset       (chip_reset),
        .chip_data        (chip_data),
        .xclk             (xclk),
        .xclk_n           (xclk_n),
        .x                (x),
        .y                (y)
    );



    // Clock and reset
    initial begin
	read_index = 1'b1;
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #2 clk = ~clk;
        reset = 1'b0;
        forever #2 clk = ~clk;
    end


endmodule

module wave_display_top(
    input clk,
    input reset,
    input new_sample,
    input [15:0] sample,
    input [15:0] note1_sample,
    input [15:0] note2_sample,
    input [15:0] note3_sample,
    input [15:0] note4_sample,
    input [15:0] note5_sample,
    input [15:0] note6_sample,
    input [15:0] note7_sample,
    input [15:0] note8_sample,
    input [15:0] note9_sample,
    input [15:0] note10_sample,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]     
    input valid,
    input vsync,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b
);

    wire [7:0] read_sample, write_sample;
    wire [8:0] read_address, write_address;
    wire [8:0] write_address1, write_address2, write_address3, write_address4, write_address5, 
	write_address6, write_address7, write_address8, write_address9, write_address10;
    wire [7:0] write_sample1, note1_value;
    wire [7:0] write_sample2, note2_value;
    wire [7:0] write_sample3, note3_value;
    wire [7:0] write_sample4, note4_value;
    wire [7:0] write_sample5, note5_value;
    wire [7:0] write_sample6, note6_value;
    wire [7:0] write_sample7, note7_value;
    wire [7:0] write_sample8, note8_value;
    wire [7:0] write_sample9, note9_value;
    wire [7:0] write_sample10, note10_value;
    wire read_index;
    wire write_en;
    wire wave_display_idle = ~vsync;

    wave_capture wc(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(sample),
        .write_address(write_address),
        .write_enable(write_en),
        .write_sample(write_sample),
        .wave_display_idle(wave_display_idle),
        .read_index(read_index)
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample),
        .douta(),
        .addrb(read_address),
        .doutb(read_sample)
    );
 
    wire valid_pixel;
    wire [7:0] wd_r, wd_g, wd_b;
    wave_display wd(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .valid(valid),
        .read_address(read_address),
        .read_value(read_sample),
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
        .read_index(read_index),
        .valid_pixel(valid_pixel),
        .r(wd_r), .g(wd_g), .b(wd_b)
    );

	// 1
    wave_capture wc1(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note1_sample),
        .write_address(write_address1),
        .write_enable(),
        .write_sample(write_sample1),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram1(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address1),
        .dina(write_sample1),
        .douta(),
        .addrb(read_address),
        .doutb(note1_value)
    );

	// 2
    wave_capture wc2(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note2_sample),
        .write_address(write_address2),
        .write_enable(),
        .write_sample(write_sample2),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram2(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address2),
        .dina(write_sample2),
        .douta(),
        .addrb(read_address),
        .doutb(note2_value)
    );

	// 3
    wave_capture wc3(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note3_sample),
        .write_address(write_address3),
        .write_enable(),
        .write_sample(write_sample3),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram3(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address3),
        .dina(write_sample3),
        .douta(),
        .addrb(read_address),
        .doutb(note3_value)
    );

	// 4
    wave_capture wc4(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note4_sample),
        .write_address(write_address4),
        .write_enable(),
        .write_sample(write_sample4),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram4(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address4),
        .dina(write_sample4),
        .douta(),
        .addrb(read_address),
        .doutb(note4_value)
    );

	// 5
    wave_capture wc5(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note5_sample),
        .write_address(write_address5),
        .write_enable(),
        .write_sample(write_sample5),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram5(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address5),
        .dina(write_sample5),
        .douta(),
        .addrb(read_address),
        .doutb(note5_value)
    );

	// 6
    wave_capture wc6(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note6_sample),
        .write_address(write_address6),
        .write_enable(),
        .write_sample(write_sample6),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram6(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address6),
        .dina(write_sample6),
        .douta(),
        .addrb(read_address),
        .doutb(note6_value)
    );

	// 7
    wave_capture wc7(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note7_sample),
        .write_address(write_address7),
        .write_enable(),
        .write_sample(write_sample7),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram7(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address7),
        .dina(write_sample7),
        .douta(),
        .addrb(read_address),
        .doutb(note7_value)
    );

	// 8
    wave_capture wc8(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note8_sample),
        .write_address(write_address8),
        .write_enable(),
        .write_sample(write_sample8),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram8(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address8),
        .dina(write_sample8),
        .douta(),
        .addrb(read_address),
        .doutb(note8_value)
    );

	// 9
    wave_capture wc9(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note9_sample),
        .write_address(write_address9),
        .write_enable(),
        .write_sample(write_sample9),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram9(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address9),
        .dina(write_sample9),
        .douta(),
        .addrb(read_address),
        .doutb(note9_value)
    );

	// 10
    wave_capture wc10(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(note10_sample),
        .write_address(write_address10),
        .write_enable(),
        .write_sample(write_sample10),
        .wave_display_idle(wave_display_idle),
        .read_index()
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram10(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address10),
        .dina(write_sample10),
        .douta(),
        .addrb(read_address),
        .doutb(note10_value)
    );

    assign {r, g, b} = valid_pixel ? {wd_r, wd_g, wd_b} : {3{8'b0}};

endmodule

`define SONG_SW 3

`define SONG_SET_ADDR 3'b000
`define SEND_NOTE     3'b001
`define INC_NOTE_ADDR 3'b010
`define ADVANCE_WAIT  3'b011
`define INC_DUR_ADDR  3'b100
// See inline comments on loc_in_song / next_loc_in_song

module song_reader(
    input clk,
    input reset,
    input advance,
    input play,
    input [1:0] song,
   
    output song_done,
    output [5:0] note,
    output [5:0] duration,
    output [2:0] meta,
    output load_count,
    output type_signal	
);
    reg [`SONG_SW-1:0] next_state;
    wire [`SONG_SW-1:0] state;
    reg [6:0] next_loc_in_song;
    wire [6:0] loc_in_song;

	dffre #(`SONG_SW) song_state_reg(.clk(clk), .r(reset), .en(play),
		.d(next_state), .q(state));

	dffr #(7) song_loc(.clk(clk), .r(reset), .d(next_loc_in_song), .q(loc_in_song));

	song_rom our_song_rom(.clk(clk), .addr({song, loc_in_song}), .dout({type_signal, note, duration, meta}));

	always @(*) begin
		casex ({state, advance, type_signal})
			{`SONG_SET_ADDR,1'bx,1'bx}:     {next_state, next_loc_in_song} = {`SEND_NOTE, 7'b0};
			{`SEND_NOTE, 1'bx,1'bx}   : 	next_state = `INC_NOTE_ADDR;
			{`INC_NOTE_ADDR,1'bx,1'b0}:     next_state = `SEND_NOTE;
			{`INC_NOTE_ADDR,1'bx,1'b1}:     next_state = `ADVANCE_WAIT;
			{`ADVANCE_WAIT,1'b1,1'bx} :     next_state = `INC_DUR_ADDR;
			{`ADVANCE_WAIT,1'b0,1'bx} :     next_state = `ADVANCE_WAIT;
			{`INC_DUR_ADDR,1'bx,1'bx} :     next_state = `SEND_NOTE;
			default: next_state = `ADVANCE_WAIT;			
		endcase

		next_loc_in_song = ((state == `INC_NOTE_ADDR && type_signal ==1'b0) || state==`INC_DUR_ADDR ) ? loc_in_song + 7'b1 : loc_in_song;
	end
	assign load_count = (state==`INC_NOTE_ADDR) ? 1'b1: 1'b0;

	assign song_done = (state == `INC_DUR_ADDR || state == `INC_NOTE_ADDR) ? (loc_in_song == 7'b1111111) : 0;
	
endmodule


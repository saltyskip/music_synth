`define MCUSWIDTH 1
`define SONGWIDTH 2
`define MCU_PAUSE 1'b0
`define MCU_PLAY  1'b1

module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output reg play,
    output reg reset_player,
    output [1:0] song,
    input song_done
);
    wire curr_state;
    wire [1:0] curr_song;
    reg [1:0] next_song;
    reg next_state;
    // Implementation goes here!
    dffr #(`MCUSWIDTH) state_flopper(.clk(clk), .r(reset), .d(next_state), .q(curr_state));
    dffr #(`SONGWIDTH) song_flopper(.clk(clk), .r(reset), .d(next_song), .q(curr_song));
    always @(*) begin
	reset_player = 1'b0;
	next_song=curr_song;
    	if (curr_state == `MCU_PAUSE) begin	
		next_state = `MCU_PAUSE;
		play = 1'b0;
		if(play_button) begin
			play = 1'b1;
			next_state = `MCU_PLAY;		
		end
		if(next_button)begin
			next_song=curr_song+2'b1;
			reset_player = 1'b1;
		end    
	end	
	else begin
		play = 1'b1;
		next_state = `MCU_PLAY;
		if(song_done)begin
			play = 1'b0;
			next_state = `MCU_PAUSE;
			next_song = curr_song +2'b1;
		end
		if(play_button) begin
			play= 1'b0;
			next_state = `MCU_PAUSE;
		end
		if(next_button) begin
			next_state= `MCU_PAUSE;			
			play = 1'b0;
			next_song = curr_song+2'b1;
			reset_player = 1'b1;		
		end
	end
    end
	assign song = curr_song;
endmodule

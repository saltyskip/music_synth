module arbiter (
    input wire [9:0] in,
    output reg [9:0] out
);

    always @(*) begin
	casex (in)
		10'bzzzzzzzzx1: out = 10'b1;
		10'bzzzzzzzz10: out = 10'b10;
		10'bxxxxxxx100: out = 10'b100;
		10'bxxxxxx1000: out = 10'b1000;
		10'bxxxxx10000: out = 10'b10000;
		10'bxxxx100000: out = 10'b100000;
		10'bxxx1000000: out = 10'b1000000;
		10'bxx10000000: out = 10'b10000000;
		10'bx100000000: out = 10'b100000000;
		10'b1000000000: out = 10'b1000000000;
		default: out = 10'b0;
	endcase
    end

endmodule

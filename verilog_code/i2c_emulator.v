// I2C Emulating module.
// Bit-bangs I2C with reckless abandon to set up the DVI driver.
//
// Author: David Schneider (dns@stanford.edu)
//
// Updated: 2011-02-07
module i2c_emulator(
    input clk,  // 100 MHz clock
    input rst,
    inout scl,
    inout sda
);
    parameter CLKS_PER_SCL = 10000;  // 10 KHz I2C @ 100 MHz clock
    `define NUM_PACKETS     5
    `define BITS_PER_PACKET 28

    `define STATE_STARTCOND 0
    `define STATE_BIT0      1
    `define STATE_BITLAST   (`STATE_BIT0 + `BITS_PER_PACKET - 1)
    `define STATE_STOPCOND  (`STATE_BITLAST + 1)
    `define STATE_RESET     `STATE_STARTCOND
    `define STATE_FIRST     `STATE_STARTCOND
    `define STATE_LAST      `STATE_STOPCOND

    `define ADDR 8'hEC
    `define ACK  1'b1  // acks are basically logic high, since it goes hi-z
    `define STOP 1'b0

    wire scl_logic;
    reg sda_logic;

    reg [2:0]  packet_index;
    reg [4:0]  state;
    reg [13:0] scl_counter;
    reg [`BITS_PER_PACKET-1:0] sda_shift;

    // Drive SDA and SCL with open-drain logic.
    bufif0 scl_buffer(scl, 0, scl_logic);
    bufif0 sda_buffer(sda, 0, sda_logic);

    assign scl_logic = ((scl_counter <= CLKS_PER_SCL/2)
                        || (state < `STATE_BIT0)
                        || (state > `STATE_BITLAST));

    wire done = (packet_index == `NUM_PACKETS);

    // Processing
    always @(posedge clk) begin
        if (rst) begin
            scl_counter <= 0;
            state <= `STATE_RESET;
            packet_index <= 0;
            sda_shift <= 0;
            sda_logic <= 1;
        end
        else if (done) begin
            scl_counter <= 0;
            state <= state;
            packet_index <= packet_index;
            sda_shift <= sda_shift;
            sda_logic <= 1;
        end
        else begin
            // SCL
            if (scl_counter == CLKS_PER_SCL)
                scl_counter <= 0;
            else
                scl_counter <= scl_counter + 1;

            // STATE
            if (scl_counter == CLKS_PER_SCL)
                if (state < `STATE_LAST)
                    state <= state + 1;
                else
                    state <= `STATE_FIRST;
            else
                state <= state;

            // PACKET_INDEX
            if ((scl_counter == CLKS_PER_SCL) && (state == `STATE_LAST))
                packet_index <= packet_index + 1;
            else
                packet_index <= packet_index;

            // SDA
            if (state == `STATE_STARTCOND) begin
                // SHIFT
                case (packet_index)
                    // I2C data goes here. ACK bits are logic 1's.
                    0: sda_shift <= {`ADDR, `ACK, 8'h49, `ACK, 8'hC0, `ACK, `STOP};
                    1: sda_shift <= {`ADDR, `ACK, 8'h21, `ACK, 8'h09, `ACK, `STOP};
                    2: sda_shift <= {`ADDR, `ACK, 8'h33, `ACK, 8'h08, `ACK, `STOP};
                    3: sda_shift <= {`ADDR, `ACK, 8'h34, `ACK, 8'h16, `ACK, `STOP};
                    4: sda_shift <= {`ADDR, `ACK, 8'h36, `ACK, 8'h60, `ACK, `STOP};
                    default: sda_shift <= {`BITS_PER_PACKET{1'bX}};
                endcase
                sda_logic <= (scl_counter <= CLKS_PER_SCL/2);
            end
            else if ((state >= `STATE_BIT0) && (state <= `STATE_BITLAST)) begin
                // Always change data in the middle of SCL low
                if (scl_counter == CLKS_PER_SCL*3/4) begin
                    sda_shift <= {sda_shift[`BITS_PER_PACKET-2:0], 1'b1};
                    sda_logic <= sda_shift[`BITS_PER_PACKET-1];
                end
                else begin
                    sda_shift <= sda_shift;
                    sda_logic <= sda_logic;
                end
            end
            else if (state == `STATE_STOPCOND) begin
                sda_shift <= sda_shift;
                sda_logic <= (scl_counter >= CLKS_PER_SCL/2);
            end
            else begin
                sda_shift <= sda_shift;
                sda_logic <= sda_logic;
            end
        end
    end

endmodule

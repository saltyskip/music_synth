// Frequency Rom
// Input: note address.
// Output: step size for the frequency.
module frequency_rom (
    input clk,
    input [5:0] addr,
    output reg [19:0] dout
);

    wire [19:0] memory [63:0];

    always @(posedge clk)
        dout = memory[addr];

    assign memory[   0  ] = {10'd000, 10'd000};  // Note: rest
    assign memory[   1  ] = {10'd009, 10'd395};  // Note: 1A
    assign memory[   2  ] = {10'd009, 10'd963};  // Note: 1A#Bb
    assign memory[   3  ] = {10'd010, 10'd573};  // Note: 1B
    assign memory[   4  ] = {10'd011, 10'd182};  // Note: 1C
    assign memory[   5  ] = {10'd011, 10'd838};  // Note: 1C#Db
    assign memory[   6  ] = {10'd012, 10'd557};  // Note: 1D
    assign memory[   7  ] = {10'd013, 10'd275};  // Note: 1D#Eb
    assign memory[   8  ] = {10'd014, 10'd081};  // Note: 1E
    assign memory[   9  ] = {10'd014, 10'd912};  // Note: 1F
    assign memory[  10  ] = {10'd015, 10'd805};  // Note: 1F#Gb
    assign memory[  11  ] = {10'd016, 10'd742};  // Note: 1G
    assign memory[  12  ] = {10'd017, 10'd723};  // Note: 1G#Ab
    assign memory[  13  ] = {10'd018, 10'd791};  // Note: 2A
    assign memory[  14  ] = {10'd019, 10'd903};  // Note: 2A#Bb
    assign memory[  15  ] = {10'd021, 10'd122};  // Note: 2B
    assign memory[  16  ] = {10'd022, 10'd365};  // Note: 2C
    assign memory[  17  ] = {10'd023, 10'd652};  // Note: 2C#Db
    assign memory[  18  ] = {10'd025, 10'd090};  // Note: 2D
    assign memory[  19  ] = {10'd026, 10'd551};  // Note: 2D#Eb
    assign memory[  20  ] = {10'd028, 10'd163};  // Note: 2E
    assign memory[  21  ] = {10'd029, 10'd800};  // Note: 2F
    assign memory[  22  ] = {10'd031, 10'd587};  // Note: 2F#Gb
    assign memory[  23  ] = {10'd033, 10'd461};  // Note: 2G
    assign memory[  24  ] = {10'd035, 10'd423};  // Note: 2G#Ab
    assign memory[  25  ] = {10'd037, 10'd559};  // Note: 3A
    assign memory[  26  ] = {10'd039, 10'd783};  // Note: 3A#Bb
    assign memory[  27  ] = {10'd042, 10'd245};  // Note: 3B
    assign memory[  28  ] = {10'd044, 10'd731};  // Note: 3C
    assign memory[  29  ] = {10'd047, 10'd281};  // Note: 3C#Db
    assign memory[  30  ] = {10'd050, 10'd180};  // Note: 3D
    assign memory[  31  ] = {10'd053, 10'd079};  // Note: 3D#Eb
    assign memory[  32  ] = {10'd056, 10'd327};  // Note: 3E
    assign memory[  33  ] = {10'd059, 10'd576};  // Note: 3F
    assign memory[  34  ] = {10'd063, 10'd150};  // Note: 3F#Gb
    assign memory[  35  ] = {10'd066, 10'd922};  // Note: 3G
    assign memory[  36  ] = {10'd070, 10'd846};  // Note: 3G#Ab
    assign memory[  37  ] = {10'd075, 10'd095};  // Note: 4A
    assign memory[  38  ] = {10'd079, 10'd543};  // Note: 4A#Bb
    assign memory[  39  ] = {10'd084, 10'd491};  // Note: 4B
    assign memory[  40  ] = {10'd089, 10'd439};  // Note: 4C
    assign memory[  41  ] = {10'd094, 10'd562};  // Note: 4C#Db
    assign memory[  42  ] = {10'd100, 10'd360};  // Note: 4D
    assign memory[  43  ] = {10'd106, 10'd158};  // Note: 4D#Eb
    assign memory[  44  ] = {10'd112, 10'd655};  // Note: 4E
    assign memory[  45  ] = {10'd119, 10'd128};  // Note: 4F
    assign memory[  46  ] = {10'd126, 10'd300};  // Note: 4F#Gb
    assign memory[  47  ] = {10'd133, 10'd821};  // Note: 4G
    assign memory[  48  ] = {10'd141, 10'd669};  // Note: 4G#Ab
    assign memory[  49  ] = {10'd150, 10'd191};  // Note: 5A
    assign memory[  50  ] = {10'd159, 10'd062};  // Note: 5A#Bb
    assign memory[  51  ] = {10'd168, 10'd983};  // Note: 5B
    assign memory[  52  ] = {10'd178, 10'd879};  // Note: 5C
    assign memory[  53  ] = {10'd189, 10'd101};  // Note: 5C#Db
    assign memory[  54  ] = {10'd200, 10'd720};  // Note: 5D
    assign memory[  55  ] = {10'd212, 10'd316};  // Note: 5D#Eb
    assign memory[  56  ] = {10'd225, 10'd286};  // Note: 5E
    assign memory[  57  ] = {10'd238, 10'd256};  // Note: 5F
    assign memory[  58  ] = {10'd252, 10'd600};  // Note: 5F#Gb
    assign memory[  59  ] = {10'd267, 10'd619};  // Note: 5G
    assign memory[  60  ] = {10'd283, 10'd314};  // Note: 5G#Ab
    assign memory[  61  ] = {10'd300, 10'd382};  // Note: 6A
    assign memory[  62  ] = {10'd318, 10'd125};  // Note: 6A#Bb
    assign memory[  63  ] = {10'd337, 10'd942};  // Note: 6B

endmodule

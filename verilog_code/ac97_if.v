//-----------------------------------------------------------------
//
// AC97 codec declaration for simulation
//
//-----------------------------------------------------------------
module ac97_if(
    input  ClkIn,
    input Reset,
    input  [15:0] PCM_Playback_Left,
    input  [15:0] PCM_Playback_Right,
    output wire [15:0] PCM_Record_Left,
    output wire [15:0] PCM_Record_Right,
    output wire PCM_Record_Valid,
    output wire PCM_Playback_Accept,
    output wire AC97Reset_n,
    input  AC97Clk,
    output wire Sync,
    output wire SData_Out,
    input  SData_In
);
// synthesis translate_off
    reg    resetState;
    assign AC97Reset_n = 1'b1;
    assign Sync = 1'b0;
    assign SData_Out = 1'b0;

    initial begin
        resetState = 1'b1;
        // Delay two clock posedges
        @(posedge ClkIn);
        @(posedge ClkIn);
        resetState = 1'b0;
    end

    wire [7:0] cycles_current;
    dffr #(8) cycles_ff(
        .clk(ClkIn),
        .r(resetState),
        .d(cycles_current + 8'b1),
        .q(cycles_current)
    );

    assign PCM_Playback_Accept = cycles_current[4];

    // The following is merely keeping state so that we can display an error
    // message if we change the input to the codec at the wrong time!
    wire New_Frame_previous;
    wire new_frame_one_pulse;
    dffr #(1) new_frame_latch(
        .clk(ClkIn),
        .r(resetState),
        .d(PCM_Playback_Accept),
        .q(New_Frame_previous)
    );
    assign new_frame_one_pulse = ~New_Frame_previous && PCM_Playback_Accept;

    wire [31:0] previous_latched_sample;
    dffre #(32) latched_sample(
        .clk(ClkIn),
        .r(resetState),
        .en(new_frame_one_pulse),
        .d({PCM_Playback_Left, PCM_Playback_Right}),
        .q(previous_latched_sample)
    );

    always @(posedge ClkIn)
        if (~new_frame_one_pulse &&
                {PCM_Playback_Left, PCM_Playback_Right} != previous_latched_sample)
            $display("ERROR: you are changing the inputs to the codec at the wrong time!");

    // Generate a SND file with the audio data
    integer file, samplecount;
    initial begin
        // Open the output file. GENERATES_SND (a player is auto-launched)
        file = $fopen("audio.snd", "wb");
        $display("Audio out: sound file audio.snd opened for output.");
        // Write the SND header. It consists of 6 32-bit, big-endian words, and
        // is followed by four 8-bit zero bytes to signify no annotations.
        // 0: Magic number: ASCII ".snd"
        // 1: Offset of the audio data in bytes: 28
        // 2: Data size: unknown -> all F's
        // 3: Encoding format: 3 = 16-bit linear PCM 
        // 4: Sample rate: 48KHz = 0xBB80
        // 5: Number of channels: 2
        // (6): No annotations: 0
        $fwrite(file, ".snd%u%u%u%u%u%u",
            32'h1C_00_00_00, 32'hFF_FF_FF_FF, 32'h03_00_00_00,
            32'h80_BB_00_00, 32'h02_00_00_00, 32'h00_00_00_00);
        // After this is all the PCM data, stored in big-endian format.
        samplecount = 0;
        forever begin
            // Wait for a new sample
            @(posedge new_frame_one_pulse);
            // Output the sample data (16-bit big-endian, left then right)
            $fwrite(file, "%u",
                {PCM_Playback_Right[7:0], PCM_Playback_Right[15:8],
                  PCM_Playback_Left[7:0],  PCM_Playback_Left[15:8]});
            samplecount = samplecount + 1;
            if (samplecount && samplecount % 48000 == 0)
                $display("[%0t] Audio out: generated %0d seconds.",
                    $time, samplecount/48000);
        end
    end

// synthesis translate_on
endmodule 

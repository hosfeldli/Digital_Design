`timescale 1ns / 1ps

module Audio (
    input wire clk,           // 100 MHz system clock
    input wire rst,           // Active high reset
    input wire [7:0] note,    // MIDI note number
    output reg PWM            // PWM audio output
);

    reg [31:0] period_lut [0:127];
    reg [31:0] period = 0;
    reg [31:0] high_time = 0;
    reg [31:0] counter = 0;
    reg [7:0]  prev_note = 0;

    // Period lookup table
    initial begin
        period_lut[12] = 32'd6115610;  // C0
        period_lut[13] = 32'd5772367;  // C#
        period_lut[14] = 32'd5448389;  // D
        period_lut[15] = 32'd5142594;  // D#
        period_lut[16] = 32'd4853963;  // E
        period_lut[17] = 32'd4580858;  // F
        period_lut[18] = 32'd4325483;  // F#
        period_lut[19] = 32'd4081632;  // G
        period_lut[20] = 32'd3854398;  // G#
        period_lut[21] = 32'd3636363;  // A
        period_lut[22] = 32'd3432458;  // A#
        period_lut[23] = 32'd3239437;  // B
        period_lut[24] = 32'd3057851;  // C1
        period_lut[25] = 32'd2886053;  // C#
        period_lut[26] = 32'd2724194;  // D
        period_lut[27] = 32'd2571197;  // D#
        period_lut[28] = 32'd2427184;  // E
        period_lut[29] = 32'd2290830;  // F
        period_lut[30] = 32'd2162341;  // F#
        period_lut[31] = 32'd2040816;  // G
        period_lut[32] = 32'd1923089;  // G#
        period_lut[33] = 32'd1814058;  // A
        period_lut[34] = 32'd1712074;  // A#
        period_lut[35] = 32'd1612903;  // B
        period_lut[36] = 32'd1524390;  // C2
        period_lut[37] = 32'd1443375;  // C#
        period_lut[38] = 32'd1366120;  // D
        period_lut[39] = 32'd1290322;  // D#
        period_lut[40] = 32'd1219512;  // E
        period_lut[41] = 32'd1149425;  // F
        period_lut[42] = 32'd1086956;  // F#
        period_lut[43] = 32'd1028806;  // G
        period_lut[44] = 32'd970873;   // G#
        period_lut[45] = 32'd909091;   // A
        period_lut[46] = 32'd857143;   // A#
        period_lut[47] = 32'd806451;   // B
        period_lut[48] = 32'd762195;   // C3
        period_lut[49] = 32'd720720;   // C#
        period_lut[50] = 32'd681818;   // D
        period_lut[51] = 32'd645161;   // D#
        period_lut[52] = 32'd609756;   // E
        period_lut[53] = 32'd577367;   // F
        period_lut[54] = 32'd543478;   // F#
        period_lut[55] = 32'd512821;   // G
        period_lut[56] = 32'd485437;   // G#
        period_lut[57] = 32'd454545;   // A
        period_lut[58] = 32'd428571;   // A#
        period_lut[59] = 32'd403226;   // B
        period_lut[60] = 32'd381679;   // C4 (Middle C)
        period_lut[61] = 32'd360721;   // C#
        period_lut[62] = 32'd340909;   // D
        period_lut[63] = 32'd322581;   // D#
        period_lut[64] = 32'd304878;   // E
        period_lut[65] = 32'd288184;   // F
        period_lut[66] = 32'd271739;   // F#
        period_lut[67] = 32'd256410;   // G
        period_lut[68] = 32'd242718;   // G#
        period_lut[69] = 32'd227273;   // A
        period_lut[70] = 32'd214286;   // A#
        period_lut[71] = 32'd201613;   // B
        period_lut[72] = 32'd190839;   // C5
        period_lut[73] = 32'd180361;   // C#
        period_lut[74] = 32'd170455;   // D
        period_lut[75] = 32'd161290;   // D#
        period_lut[76] = 32'd152439;   // E
        period_lut[77] = 32'd144928;   // F
        period_lut[78] = 32'd136986;   // F#
        period_lut[79] = 32'd128205;   // G
        period_lut[80] = 32'd121359;   // G#
        period_lut[81] = 32'd113636;   // A
        period_lut[82] = 32'd107143;   // A#
        period_lut[83] = 32'd100807;   // B
        period_lut[84] = 32'd95420;    // C6
        period_lut[85] = 32'd90180;    // C#
        period_lut[86] = 32'd85227;    // D
        period_lut[87] = 32'd80402;    // D#
        period_lut[88] = 32'd76220;    // E
        period_lut[89] = 32'd72165;    // F
        period_lut[90] = 32'd68306;    // F#
        period_lut[91] = 32'd64102;    // G
        period_lut[92] = 32'd60606;    // G#
        period_lut[93] = 32'd56818;    // A
        period_lut[94] = 32'd53571;    // A#
        period_lut[95] = 32'd50403;    // B
        period_lut[96] = 32'd47719;    // C7
    end

    // Update period and high_time only on note change
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            period <= 0;
            high_time <= 0;
            prev_note <= 0;
        end else if (note != prev_note) begin
            prev_note <= note;

            if (note != 8'd0) begin
                period <= period_lut[note];
                high_time <= period_lut[note] >> 1;
            end else begin
                period <= 0;
                high_time <= 0;
            end
        end
    end

    // PWM generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            PWM <= 0;
        end else if (period == 0) begin
            counter <= 0;
            PWM <= 0;
        end else begin
            if (counter >= period - 1)
                counter <= 0;
            else
                counter <= counter + 1;

            PWM <= (counter < high_time);
        end
    end

endmodule

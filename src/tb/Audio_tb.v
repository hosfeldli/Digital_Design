`timescale 1ns / 1ps

module Audio_tb;

    reg clk;
    reg rst;
    reg [7:0] note;
    wire PWM;
    
    integer i;
    
    Audio uut(
        .clk(clk),
        .rst(rst),
        .note(note),
        .PWM(PWM)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;

        for (i = 1; i < 97; i = i + 1) begin
            rst = 1;
            note = i;
            #50 rst = 0;
            #100000000;
        end
        $stop;
    end
endmodule

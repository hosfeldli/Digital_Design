`timescale 1ns / 1ps

module top (
    input wire CLK_I,                      // 100 MHz clock
    input wire RESET,                      // Active-high reset
    input wire UART_RX,                    // MIDI serial input

    output wire AUDIO_PWM,                 // Audio output

    output wire VGA_HS_O,
    output wire VGA_VS_O,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    wire [7:0] NOTE;
    
    // Instantiate MIDI_Top (Verilog)
    MIDI_Top midi_inst (
        .clk(CLK_I),
        .reset(RESET),
        .uart_rx(UART_RX),
        .audio_pwm(AUDIO_PWM),
        .midi_note(NOTE)
    );

    // Instantiate VGA top (VHDL black box)
    vga_top vga_top (
        .CLK_I(CLK_I),
        .NOTE(NOTE),
        .VGA_HS_O(VGA_HS_O),
        .VGA_VS_O(VGA_VS_O),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

endmodule

`timescale 1ns / 1ps

module MIDI_Top (
    input wire clk,           // 100 MHz system clock
    input wire reset,         // Active-high reset
    input wire uart_rx,       // MIDI serial input
    output wire audio_pwm,     // Audio output (e.g. to PMOD)
    output wire [7:0] midi_note
);

    wire note_on;
    wire note_off;
    
    // Used to bypass MIDI handling and force a specific note output
    //wire [7:0] test_note = 8'd69;
    
    // MIDI interface
    MIDI_Interface #(
        .CLOCK_FREQ(100_000_000),
        .BAUD_RATE(9600)
    ) midi_rx (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .midi_note(midi_note),
        .note_on(note_on),
        .note_off(note_off),
        .debug_uart_byte(),     // optional
        .debug_uart_ready()
    );

    // Audio output generator
    Audio audio_out (
        .clk(clk),
        .rst(reset),
        .note(midi_note),
        .PWM(audio_pwm)
    );

endmodule

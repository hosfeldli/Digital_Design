`timescale 1ns / 1ps

module MIDI_Interface_tb;

    // Parameters
    localparam CLOCK_FREQ = 100_000_000;
    localparam BAUD_RATE = 9600;
    localparam BIT_TICKS = CLOCK_FREQ / BAUD_RATE;
    localparam integer BIT_DELAY_NS = 104160; // For # delays in ns

    // DUT signals
    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    wire [7:0] midi_note;
    wire note_on;
    wire note_off;

    wire [7:0] debug_uart_byte;
    wire debug_uart_ready;

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    // Instantiate DUT
    MIDI_Interface #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .midi_note(midi_note),
        .note_on(note_on),
        .note_off(note_off),
        .debug_uart_byte(debug_uart_byte),
        .debug_uart_ready(debug_uart_ready)
    );

    // Task to send a UART byte
    task send_uart_byte(input [7:0] byte);
        integer i;
        begin
            // Start bit
            uart_rx <= 0;
            #(BIT_DELAY_NS);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx <= byte[i];
                #(BIT_DELAY_NS);
            end

            // Stop bit
            uart_rx <= 1;
            #(BIT_DELAY_NS);
        end
    endtask

    initial begin
        // Reset
        reset = 1;
        #(BIT_DELAY_NS * 2);
        reset = 0;

        // Wait a bit after reset
        #(BIT_DELAY_NS * 4);

        $display("Sending Note On for Middle C (0x90 0x3C 0x7F)");
        send_uart_byte(8'h90); // Note On
        send_uart_byte(8'h3C); // Note = 60 (Middle C)
        send_uart_byte(8'h7F); // Velocity (ignored)

        // Wait before sending Note Off
        #(BIT_DELAY_NS * 20);

        $display("Sending Note Off for Middle C (0x80 0x3C 0x00)");
        send_uart_byte(8'h80); // Note Off
        send_uart_byte(8'h3C); // Note = 60 (Middle C)
        send_uart_byte(8'h00); // Velocity = 0 (ignored)

        // Wait to observe signals
        #(BIT_DELAY_NS * 50);

        $display("Simulation complete.");
        $stop;
    end

endmodule

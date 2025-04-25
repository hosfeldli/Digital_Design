`timescale 1ns / 1ps

module MIDI_Top_tb;

    localparam CLOCK_FREQ = 100_000_000;
    localparam BAUD_RATE = 9600;
    localparam integer BIT_DELAY_NS = 104160; // ns per bit at 9600 baud

    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    wire audio_pwm;

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    // Instantiate the top module
    MIDI_Top dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .audio_pwm(audio_pwm)
    );

    // Task to send one UART byte
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

    // MIDI message wrapper
    task send_note(input [7:0] status, input [7:0] note_val);
        begin
            send_uart_byte(status);    // Note On or Off
            send_uart_byte(note_val); // Note number
            send_uart_byte(8'h7F);     // Velocity (ignored)
        end
    endtask

    initial begin
        // Apply reset
        reset = 1;
        #(BIT_DELAY_NS * 2);
        reset = 0;

        #(BIT_DELAY_NS * 4);

        // Note On: Middle C (0x3C = 60)
        $display("Note On: C4 (0x3C)");
        send_note(8'h90, 8'h3C);
        #(BIT_DELAY_NS * 40); // wait to observe PWM

        // Note Off: Middle C
        $display("Note Off: C4");
        send_note(8'h80, 8'h3C);
        #(BIT_DELAY_NS * 20);

        // Note On: E4 (0x40 = 64)
        $display("Note On: E4 (0x40)");
        send_note(8'h90, 8'h40);
        #(BIT_DELAY_NS * 40);

        // Note Off: E4
        $display("Note Off: E4");
        send_note(8'h80, 8'h40);
        #(BIT_DELAY_NS * 20);

        // Note On: G4 (0x43 = 67)
        $display("Note On: G4 (0x43)");
        send_note(8'h90, 8'h43);
        #(BIT_DELAY_NS * 40);

        // Note Off: G4
        $display("Note Off: G4");
        send_note(8'h80, 8'h43);
        #(BIT_DELAY_NS * 20);

        $display("Simulation done.");
        $stop;
    end

endmodule

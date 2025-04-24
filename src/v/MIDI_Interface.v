`timescale 1ns / 1ps

module MIDI_Interface #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    input wire uart_rx,

    output reg [7:0] midi_note = 0,
    output reg note_on = 0,
    output reg note_off = 0,

    // Debug outputs
    output wire [7:0] debug_uart_byte,
    output wire debug_uart_ready
);

    localparam BIT_TICKS = CLOCK_FREQ / BAUD_RATE;

    reg [15:0] clk_count = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] rx_shift = 10'b1111111111;
    reg [7:0] uart_byte = 0;
    reg uart_ready = 0;
    reg rx_busy = 0;

    assign debug_uart_byte = uart_byte;
    assign debug_uart_ready = uart_ready;

    // UART Receiver FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_count <= 0;
            bit_index <= 0;
            rx_shift <= 10'b1111111111;
            uart_ready <= 0;
            rx_busy <= 0;
        end else begin
            uart_ready <= 0;

            if (!rx_busy && uart_rx == 0) begin
                rx_busy <= 1;
                clk_count <= BIT_TICKS / 2;
                bit_index <= 0;
            end else if (rx_busy) begin
                if (clk_count == 0) begin
                    rx_shift[bit_index] <= uart_rx;
                    bit_index <= bit_index + 1;
                    clk_count <= BIT_TICKS - 1;
                end else begin
                    clk_count <= clk_count - 1;
                end

                if (bit_index == 9 && clk_count == 0) begin
                    uart_byte <= rx_shift[8:1];
                    uart_ready <= 1;
                    rx_busy <= 0;
                end
            end
        end
    end

    // MIDI Parser
    reg [1:0] midi_state = 0;
    reg [7:0] status_byte;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            midi_note <= 0;
            note_on <= 0;
            note_off <= 0;
            midi_state <= 0;
            status_byte <= 0;
        end else begin
            note_on <= 0;
            note_off <= 0;

            if (uart_ready) begin
                case (midi_state)
                    0: begin
                        if (uart_byte[7]) begin
                            status_byte <= uart_byte;
                            if (uart_byte[7:4] == 4'b1001 || uart_byte[7:4] == 4'b1000)
                                midi_state <= 1;
                        end
                    end

                    1: begin
                        if (status_byte[7:4] == 4'b1001) begin
                            midi_note <= uart_byte;
                            note_on <= 1;
                        end else if (status_byte[7:4] == 4'b1000) begin
                            midi_note <= 0;
                            note_off <= 1;
                        end
                        midi_state <= 2;
                    end

                    2: midi_state <= 0;
                endcase
            end
        end
    end

endmodule

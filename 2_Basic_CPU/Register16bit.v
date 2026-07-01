`timescale 1ns / 1ps

module Register16bit(
    input wire Clock,
    input wire [15:0] I,
    input wire [2:0] FunSel,
    input wire Enable,
    output reg [15:0] Q
);

    initial Q = 16'h0000;

    always @(posedge Clock) begin
        if (Enable) begin
            case (FunSel)
                3'b000: Q <= 16'h0000;           // Clear
                3'b001: Q <= I;                    // Load
                3'b010: Q <= Q + 16'h0001;        // Increment
                3'b011: Q <= Q - 16'h0001;        // Decrement
                default: Q <= Q;                   // Hold
            endcase
        end
    end

endmodule

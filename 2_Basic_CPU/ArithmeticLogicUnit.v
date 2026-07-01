`timescale 1ns / 1ps

module ArithmeticLogicUnit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [4:0] FunSel,
    input wire WF,
    input wire Clock,
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut  // [3]=Z, [2]=C, [1]=N, [0]=O
);

    reg [16:0] temp;

    initial begin
        ALUOut = 16'h0000;
        FlagsOut = 4'b0000;
    end

    always @(*) begin
        temp = 17'h00000;
        case (FunSel)
            5'b00000: temp = {1'b0, A};                          // A
            5'b00001: temp = {1'b0, B};                          // B
            5'b00010: temp = {1'b0, ~A};                         // NOT A
            5'b00011: temp = {1'b0, ~B};                         // NOT B
            5'b00100: temp = {1'b0, A} + {1'b0, B};              // A + B
            5'b00101: temp = {1'b0, A} + {1'b0, B} + {16'b0, FlagsOut[2]}; // A + B + C
            5'b00110: temp = {1'b0, A} + {1'b0, ~B} + 17'b1;    // A - B
            5'b00111: temp = {1'b0, A & B};                      // A AND B
            5'b01000: temp = {1'b0, A | B};                      // A OR B
            5'b01001: temp = {1'b0, A ^ B};                      // A XOR B
            5'b01010: temp = {1'b0, ~(A & B)};                   // A NAND B
            5'b01011: temp = {A[15], A[14:0], 1'b0};             // LSL A  (C=A[15])
            5'b01100: temp = {A[0], 1'b0, A[15:1]};              // LSR A  (C=A[0])
            5'b01101: temp = {A[0], A[15], A[15:1]};             // ASR A  (C=A[0])
            5'b01110: temp = {A[15], A[14:0], A[15]};            // CSL A  (C=A[15])
            5'b01111: temp = {A[0], A[0], A[15:1]};              // CSR A  (C=A[0])
            5'b10000: temp = {1'b0, A} + 17'b1;                  // A + 1
            5'b10001: temp = {1'b0, A} + {1'b0, 16'hFFFF};       // A - 1
            default:  temp = {1'b0, A};
        endcase
    end

    always @(*) begin
        ALUOut = temp[15:0];
    end

    always @(posedge Clock) begin
        if (WF) begin
            // Z flag
            FlagsOut[3] <= (temp[15:0] == 16'h0000) ? 1'b1 : 1'b0;
            // C flag
            FlagsOut[2] <= temp[16];
            // N flag
            FlagsOut[1] <= temp[15];
            // O flag (overflow for signed)
            case (FunSel)
                5'b00100, 5'b00101, 5'b10000: // ADD, ADC, INC
                    FlagsOut[0] <= (~A[15] & ~B[15] & temp[15]) | (A[15] & B[15] & ~temp[15]);
                5'b00110, 5'b10001: // SUB, DEC
                    FlagsOut[0] <= (~A[15] & B[15] & temp[15]) | (A[15] & ~B[15] & ~temp[15]);
                default:
                    FlagsOut[0] <= 1'b0;
            endcase
        end
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module ArithmeticLogicUnit(
    input wire [15:0] A,           // First operand
    input wire [15:0] B,           // Second operand
    input wire [4:0] FunSel,       // Function select
    input wire WF,                 // Write Flags enable
    input wire Clock,
    output reg [15:0] ALUOut,      // ALU output
    output reg [3:0] FlagsOut      // Z, C, N, O flags
);
    
    // Flags: FlagsOut[3]=Z, FlagsOut[2]=C, FlagsOut[1]=N, FlagsOut[0]=O
    reg [16:0] temp;
    reg Z_flag, C_flag, N_flag, O_flag;

    always @(*) begin
        temp = 17'b0;
        Z_flag = FlagsOut[3];
        C_flag = FlagsOut[2];
        N_flag = FlagsOut[1];
        O_flag = FlagsOut[0];
        
        case(FunSel)
            5'h00: begin // A (pass through)
                ALUOut = A;
            end
            5'h01: begin // B (pass through)
                ALUOut = B;
            end
            5'h02: begin // NOT A
                ALUOut = ~A;
            end
            5'h03: begin // NOT B
                ALUOut = ~B;
            end
            5'h04: begin // A + B
                temp = {1'b0, A} + {1'b0, B};
                ALUOut = temp[15:0];
                C_flag = temp[16];
                O_flag = (A[15] == B[15]) && (ALUOut[15] != A[15]);
            end
            5'h05: begin // A + B + Carry
                temp = {1'b0, A} + {1'b0, B} + {16'b0, FlagsOut[2]};
                ALUOut = temp[15:0];
                C_flag = temp[16];
                O_flag = (A[15] == B[15]) && (ALUOut[15] != A[15]);
            end
            5'h06: begin // A - B
                temp = {1'b0, A} + {1'b0, ~B} + 17'b1;
                ALUOut = temp[15:0];
                C_flag = temp[16];
                O_flag = (A[15] != B[15]) && (ALUOut[15] != A[15]);
            end
            5'h07: begin // A AND B
                ALUOut = A & B;
            end
            5'h08: begin // A OR B
                ALUOut = A | B;
            end
            5'h09: begin // A XOR B
                ALUOut = A ^ B;
            end
            5'h0A: begin // A NAND B
                ALUOut = ~(A & B);
            end
            5'h0B: begin // LSL A (Logical Shift Left)
                C_flag = A[15];
                ALUOut = {A[14:0], 1'b0};
            end
            5'h0C: begin // LSR A (Logical Shift Right)
                C_flag = A[0];
                ALUOut = {1'b0, A[15:1]};
            end
            5'h0D: begin // ASR A (Arithmetic Shift Right)
                C_flag = A[0];
                ALUOut = {A[15], A[15:1]};
            end
            5'h0E: begin // CSL A (Circular Shift Left)
                C_flag = A[15];
                ALUOut = {A[14:0], A[15]};
            end
            5'h0F: begin // CSR A (Circular Shift Right)
                C_flag = A[0];
                ALUOut = {A[0], A[15:1]};
            end
            5'h10: begin // A + 1 (Increment)
                temp = {1'b0, A} + 17'b1;
                ALUOut = temp[15:0];
                C_flag = temp[16];
                O_flag = (~A[15]) && (ALUOut[15]);
            end
            5'h11: begin // A - 1 (Decrement)
                temp = {1'b0, A} + {1'b0, 16'hFFFF};
                ALUOut = temp[15:0];
                C_flag = temp[16];
                O_flag = (A[15]) && (~ALUOut[15]);
            end
            default: begin
                ALUOut = 16'h0000;
            end
        endcase
        
        // Update Z and N flags for all operations
        Z_flag = (ALUOut == 16'h0000) ? 1'b1 : 1'b0;
        N_flag = ALUOut[15];
    end
    
    always @(posedge Clock) begin
        if (WF) begin
            FlagsOut <= {Z_flag, C_flag, N_flag, O_flag};
        end
    end

endmodule

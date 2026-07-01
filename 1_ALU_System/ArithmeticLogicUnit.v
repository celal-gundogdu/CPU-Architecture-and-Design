`timescale 1ns / 1ps

module ArithmeticLogicUnit(
                            input wire        Clock,
                            input wire [15:0] A,
                            input wire [15:0] B,
                            input wire [3:0]  FunSel,
                            input wire        WF,

                            output reg [15:0] ALUOut,
                            output reg [3:0] FlagsOut // 3: Z, 2: C, 1: N, 0: O
                           );

   reg [15:0] result;
   reg        Z_new, C_new, N_new, O_new;
   reg [16:0] extended;

   always @(*) begin
      C_new = FlagsOut[2];
      O_new = FlagsOut[0];

      result = 0;
      extended = 0;

      case (FunSel)
        0: result = A;  // A
        1: result = B;  // B
        2: result = ~A;  // ~A
        3: result = ~B;  // ~B

        // A + B (set C, O)
        4: begin
           extended = {1'd0, A} + {1'd0, B};
           result = extended[15:0];
           C_new = extended[16];
           O_new = (~A[15] & ~B[15] & result[15]) | (A[15] & B[15] & ~result[15]);
        end

        // A + B + C (set C, O)
        5: begin
           extended = {1'd0, A} + {1'd0, B} + {16'd0, FlagsOut[2]};
           result = extended[15:0];
           C_new = extended[16];
           O_new = (~A[15] & ~B[15] & result[15]) | (A[15] & B[15] & ~result[15]);
        end

        // A - B (set C, O)
        6: begin
           extended = {1'd0, A} + {1'd0, ~B} + 1;
           result = extended[15:0];
           C_new = extended[16];
           O_new = (~A[15] & B[15] & result[15]) | (A[15] & ~B[15] & ~result[15]);
        end

        7: result = A & B;  // A & B
        8: result = A | B;  // A | B
        9: result = A ^ B;  // A ^ B
        10: result = ~(A & B);  // ~(A & B)

        // A << 1 (set C)
        11: begin
           result = {A[14:0], 1'b0};
           C_new = A[15];
        end

        // A >> 1 (set C)
        12: begin
           result = {1'd0, A[15:1]};
           C_new = A[0];
        end

        // A >> 1 (arithmetic) (N invariant)
        13: result = {A[15], A[15:1]};

        // A << 1 (circular) (set C)
        14: begin
           result = {A[14:0], A[15]};
           C_new = A[15];
        end

        // A >> 1 (circular) (set C)
        15: begin // CSR A
           result = {A[0], A[15:1]};
           C_new = A[0];
        end

        // dummy
        default: result = 0;
      endcase

      Z_new = (result == 0);

      // Arithmetic right shift leaves N invariant
      N_new = (FunSel == 13) ? FlagsOut[1] : result[15];

      ALUOut = result;
   end

   always @(posedge Clock) begin
      if (WF) begin
         FlagsOut = {Z_new, C_new, N_new, O_new};
      end
   end

endmodule

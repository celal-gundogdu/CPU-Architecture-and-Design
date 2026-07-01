`timescale 1ns / 1ps

module Multiplexer3_8(
                      input wire [15:0]  I0,
                      input wire [15:0]  I1,
                      input wire [15:0]  I2,
                      input wire [15:0]  I3,
                      input wire [15:0]  I4,
                      input wire [15:0]  I5,
                      input wire [15:0]  I6,
                      input wire [15:0]  I7,
                      input wire [2:0]   Sel,

                      output wire [15:0] Out
                      );

   assign Out = (Sel == 0) ? I0 :
                (Sel == 1) ? I1 :
                (Sel == 2) ? I2 :
                (Sel == 3) ? I3 :
                (Sel == 4) ? I4 :
                (Sel == 5) ? I5 :
                (Sel == 6) ? I6 : I7;
endmodule

module RegisterFile(
                    input wire         Clock,
                    input wire [15:0]  I,
                    input wire [1:0]   FunSel,
                    input wire [3:0]   RegSel,
                    input wire [3:0]   ScrSel,
                    input wire [2:0]   OutASel,
                    input wire [2:0]   OutBSel,

                    output wire [15:0] OutA,
                    output wire [15:0] OutB
                    );

   wire [15:0] R1_Q, R2_Q, R3_Q, R4_Q;
   wire [15:0] S1_Q, S2_Q, S3_Q, S4_Q;

   Register16bit R1 (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[3]), .I(I), .Q(R1_Q));
   Register16bit R2 (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[2]), .I(I), .Q(R2_Q));
   Register16bit R3 (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[1]), .I(I), .Q(R3_Q));
   Register16bit R4 (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[0]), .I(I), .Q(R4_Q));

   Register16bit S1 (.Clock(Clock), .FunSel(FunSel), .E(~ScrSel[3]), .I(I), .Q(S1_Q));
   Register16bit S2 (.Clock(Clock), .FunSel(FunSel), .E(~ScrSel[2]), .I(I), .Q(S2_Q));
   Register16bit S3 (.Clock(Clock), .FunSel(FunSel), .E(~ScrSel[1]), .I(I), .Q(S3_Q));
   Register16bit S4 (.Clock(Clock), .FunSel(FunSel), .E(~ScrSel[0]), .I(I), .Q(S4_Q));

   Multiplexer3_8 MA (.I0(R1_Q), .I1(R2_Q), .I2(R3_Q), .I3(R4_Q), .I4(S1_Q), .I5(S2_Q), .I6(S3_Q), .I7(S4_Q), .Sel(OutASel), .Out(OutA));
   Multiplexer3_8 MB (.I0(R1_Q), .I1(R2_Q), .I2(R3_Q), .I3(R4_Q), .I4(S1_Q), .I5(S2_Q), .I6(S3_Q), .I7(S4_Q), .Sel(OutBSel), .Out(OutB));
endmodule

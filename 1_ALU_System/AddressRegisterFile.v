`timescale 1ns / 1ps

module AddressRegisterFile(
                           input wire         Clock,
                           input wire [15:0]  I,
                           input wire [1:0]   FunSel,
                           input wire [2:0]   RegSel,
                           input wire [1:0]   OutCSel,
                           input wire         OutDSel,

                           output wire [15:0] OutC,
                           output wire [15:0] OutD,
                           output wire [15:0] OutE
                           );

   Register16bit PC (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[2]), .I(I), .Q());
   Register16bit SP (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[1]), .I(I), .Q());
   Register16bit AR (.Clock(Clock), .FunSel(FunSel), .E(~RegSel[0]), .I(I), .Q());

   assign OutC = (OutCSel[1] == 0) ? PC.Q : (OutCSel[0] == 0) ? AR.Q : SP.Q;
   assign OutD = (OutDSel == 0) ? AR.Q : SP.Q;
   assign OutE = PC.Q;
endmodule

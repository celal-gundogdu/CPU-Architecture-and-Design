`timescale 1ns / 1ps

module ArithmeticLogicUnitSystem(
                                 input wire       Clock,

                                 input wire [2:0] RF_OutASel,
                                 input wire [2:0] RF_OutBSel,
                                 input wire [1:0] RF_FunSel,
                                 input wire [3:0] RF_RegSel,
                                 input wire [3:0] RF_ScrSel,

                                 input wire [3:0] ALU_FunSel,
                                 input wire       ALU_WF,

                                 input wire [1:0] ARF_OutCSel,
                                 input wire       ARF_OutDSel,
                                 input wire [1:0] ARF_FunSel,
                                 input wire [2:0] ARF_RegSel,

                                 input wire       IMU_CS,
                                 input wire       IMU_LH,

                                 input wire       DMU_WR,
                                 input wire       DMU_CS,
                                 input wire       DMU_FunSel,

                                 input wire [1:0] MuxASel,
                                 input wire [1:0] MuxBSel,
                                 input wire       MuxCSel
                                 );

   wire [15:0] OutA, OutB;
   wire [15:0] OutC, OutD, OutE;
   wire [15:0] ALUOut;
   wire [3:0]  FlagsOut;
   wire [15:0] IROut, IMUOut, DMUOut;
   wire [15:0] MuxAOut, MuxBOut;
   wire [7:0]  MuxCOut;

   assign MuxAOut = (MuxASel == 2'b00) ? ALUOut :
                    (MuxASel == 2'b01) ? OutC   :
                    (MuxASel == 2'b10) ? DMUOut : IROut;

   assign MuxBOut = (MuxBSel == 2'b00) ? ALUOut :
                    (MuxBSel == 2'b01) ? OutC   :
                    (MuxBSel == 2'b10) ? DMUOut : IROut;

   assign MuxCOut = (MuxCSel == 1'b0) ? ALUOut[7:0] : ALUOut[15:8];

   RegisterFile RF (
                    .Clock(Clock),
                    .I(MuxAOut),
                    .FunSel(RF_FunSel),
                    .RegSel(RF_RegSel),
                    .ScrSel(RF_ScrSel),
                    .OutASel(RF_OutASel),
                    .OutBSel(RF_OutBSel),
                    .OutA(OutA),
                    .OutB(OutB)
                    );

   AddressRegisterFile ARF (
                            .Clock(Clock),
                            .I(MuxBOut),
                            .FunSel(ARF_FunSel),
                            .RegSel(ARF_RegSel),
                            .OutCSel(ARF_OutCSel),
                            .OutDSel(ARF_OutDSel),
                            .OutC(OutC),
                            .OutD(OutD),
                            .OutE(OutE)
                            );

   ArithmeticLogicUnit ALU (
                            .Clock(Clock),
                            .A(OutA),
                            .B(OutB),
                            .FunSel(ALU_FunSel),
                            .WF(ALU_WF),
                            .ALUOut(ALUOut),
                            .FlagsOut(FlagsOut)
                            );


   InstructionMemoryUnit IMU (
                              .Clock(Clock),
                              .Address(OutE),
                              .CS(IMU_CS),
                              .LH(IMU_LH),
                              .IROut(IROut),
                              .IMUOut(IMUOut)
                              );

   DataMemoryUnit DMU (
                       .Clock(Clock),
                       .I(MuxCOut),
                       .Address(OutD),
                       .WR(DMU_WR),
                       .CS(DMU_CS),
                       .FunSel(DMU_FunSel),
                       .DMUOut(DMUOut)
                       );

endmodule

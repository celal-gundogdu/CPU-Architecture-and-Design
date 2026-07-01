`timescale 1ns / 1ps

module InstructionMemoryUnit(
                             input wire         Clock,
                             input wire [15:0]  Address,
                             input wire         CS,
                             input wire         LH,

                             output wire [15:0] IROut,
                             output wire [15:0] IMUOut
                             );

   wire [7:0] MemOut_wire;

   InstructionMemory IM (
                         .Address(Address),
                         .MemOut(MemOut_wire)
                         );

   InstructionRegister IR (
                           .Clock(Clock),
                           .I(MemOut_wire),
                           .Write(CS),
                           .LH(LH),
                           .IROut(IROut)
                           );

   assign IMUOut = {8'd0, IROut[7:0]};
endmodule

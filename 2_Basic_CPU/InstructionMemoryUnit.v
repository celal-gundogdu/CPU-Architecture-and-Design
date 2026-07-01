`timescale 1ns / 1ps

module InstructionMemoryUnit(
    input wire Clock,
    input wire Reset,
    input wire [15:0] Address,
    input wire LH,
    input wire Load,
    input wire CS,
    output wire [15:0] IROut
);

    wire [7:0] MemOut;

    InstructionMemory IM(
        .Address(Address),
        .CS(CS),
        .MemOut(MemOut)
    );

    InstructionRegister IR(
        .Clock(Clock),
        .Reset(Reset),
        .LH(LH),
        .Load(Load),
        .I(MemOut),
        .IROut(IROut)
    );

endmodule

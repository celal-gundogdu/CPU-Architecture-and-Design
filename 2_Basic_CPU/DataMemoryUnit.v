`timescale 1ns / 1ps

module DataMemoryUnit(
    input wire Clock,
    input wire Reset,
    input wire [15:0] Address,
    input wire [7:0] Data,
    input wire WR,
    input wire CS,
    input wire LH,
    input wire Load,
    output wire [15:0] DMUOut
);

    wire [7:0] MemOut;

    DataMemory DM(
        .Address(Address),
        .Data(Data),
        .WR(WR),
        .CS(CS),
        .Clock(Clock),
        .MemOut(MemOut)
    );

    DataRegister DR(
        .Clock(Clock),
        .Reset(Reset),
        .LH(LH),
        .Load(Load),
        .I(MemOut),
        .DROut(DMUOut)
    );

endmodule

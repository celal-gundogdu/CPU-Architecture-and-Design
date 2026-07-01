`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module DataMemoryUnit(
    input wire Clock,
    input wire [15:0] Address,     // Address from ARF (AR or SP)
    input wire [7:0] Data,         // Data to write
    input wire WR,                 // Read=0, Write=1
    input wire CS,                 // Chip Select (active-low)
    input wire LH,                 // Load High/Low select for DR
    input wire DR_Enable,          // DR Enable (active-low)
    output wire [15:0] DROut       // DR output
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
        .I(MemOut),
        .LH(LH),
        .Enable(DR_Enable),
        .DROut(DROut)
    );

endmodule

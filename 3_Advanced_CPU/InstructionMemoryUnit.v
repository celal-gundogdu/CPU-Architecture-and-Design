`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module InstructionMemoryUnit(
    input wire Clock,
    input wire [15:0] Address,     // Address from ARF (PC)
    input wire LH,                 // Load High/Low select for IR
    input wire CS,                 // Chip Select (active-low)
    input wire IR_Enable,          // IR Enable (active-low)
    output wire [15:0] IROut       // IR output
);

    wire [7:0] MemOut;

    InstructionMemory IM(
        .Address(Address),
        .CS(CS),
        .MemOut(MemOut)
    );

    InstructionRegister IR(
        .Clock(Clock),
        .I(MemOut),
        .LH(LH),
        .Enable(IR_Enable),
        .IROut(IROut)
    );

endmodule

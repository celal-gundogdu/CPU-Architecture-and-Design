`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module InstructionRegister(
    input wire Clock,
    input wire [7:0] I,            // 8-bit input from instruction memory
    input wire LH,                 // 0: Load LSB (7-0), 1: Load MSB (15-8)
    input wire Enable,             // Enable (active-low)
    output reg [15:0] IROut        // 16-bit instruction register output
);

    always @(posedge Clock) begin
        if (~Enable) begin
            if (~LH)              // LH=0: Load LSB
                IROut[7:0] <= I;
            else                  // LH=1: Load MSB
                IROut[15:8] <= I;
        end
    end

endmodule

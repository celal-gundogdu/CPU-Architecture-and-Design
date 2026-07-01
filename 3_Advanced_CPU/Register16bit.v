`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module Register16bit(
    input wire Clock,
    input wire [15:0] I,       // Input data
    input wire FunSel,         // 0: Load, 1: Clear  (active-low load)
    input wire E,              // Enable (active-low)
    output reg [15:0] Q        // Output
);

    always @(posedge Clock) begin
        if (~E) begin          // Enable is active-low
            if (~FunSel)       // FunSel=0: Load
                Q <= I;
            else               // FunSel=1: Clear
                Q <= 16'h0000;
        end
    end

endmodule

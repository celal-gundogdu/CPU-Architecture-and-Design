`timescale 1ns / 1ps

module DataRegister(
    input wire Clock,
    input wire Reset,
    input wire LH,
    input wire Load,
    input wire [7:0] I,
    output reg [15:0] DROut
);

    initial DROut = 16'h0000;

    always @(posedge Clock) begin
        if (!Reset)
            DROut <= 16'h0000;
        else if (Load) begin
            if (LH == 1'b0)
                DROut[7:0] <= I;
            else
                DROut[15:8] <= I;
        end
    end

endmodule

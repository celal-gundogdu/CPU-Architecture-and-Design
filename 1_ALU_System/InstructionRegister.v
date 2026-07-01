`timescale 1ns / 1ps

module InstructionRegister(
                           input wire        Clock,
                           input wire [7:0]  I,
                           input wire        Write,
                           input wire        LH,

                           output reg [15:0] IROut
                           );

   always @(posedge Clock)
     begin
        if (Write)
          begin
             if (LH == 0)
               IROut[7:0]  <= I;
             else
               IROut[15:8] <= I;
          end
     end
endmodule

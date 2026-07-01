`timescale 1ns / 1ps

module DataRegister(
                    input wire        Clock,
                    input wire [7:0]  I,
                    input wire        E,
                    input wire        FunSel,

                    output reg [15:0] DROut
                    );

   always @(posedge Clock)
     begin
        if (E)
          begin
             if (FunSel == 0)
               DROut[7:0]  <= I;
             else
               DROut[15:8] <= I;
          end
     end
endmodule

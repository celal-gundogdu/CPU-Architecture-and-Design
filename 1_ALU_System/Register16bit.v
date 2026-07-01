`timescale 1ns / 1ps

module Register16bit(
                     input wire        Clock,
                     input wire [15:0] I,
                     input wire        E,
                     input wire [1:0]  FunSel,

                     output reg [15:0] Q
                     );

   always @(posedge Clock)
     begin
        if (E)
          begin
             case (FunSel)
               2'b00: Q <= 0;
               2'b01: Q <= I;
               2'b10: Q <= Q + 1;
               2'b11: Q <= Q - 1;
             endcase
          end
     end
endmodule

`timescale 1ns / 1ps

module DataMemoryUnit(
                      input wire         Clock,
                      input wire [7:0]   I,
                      input wire [15:0]  Address,
                      input wire         WR,
                      input wire         CS,
                      input wire         FunSel,

                      output wire [15:0] DMUOut
                      );

   wire [7:0] MemOut_wire;
   wire [15:0] DROut_wire;

   DataMemory DM (
                  .Clock(Clock),
                  .Address(Address),
                  .Data(I),
                  .WR(WR),
                  .CS(~CS),
                  .MemOut(MemOut_wire)
                  );

   DataRegister DR (
                    .Clock(Clock),
                    .I(MemOut_wire),
                    .E(CS),
                    .FunSel(FunSel),
                    .DROut(DROut_wire)
                    );

   assign DMUOut = DROut_wire;

endmodule

`timescale 1ns / 1ps

module AddressRegisterFile(
    input wire Clock,
    input wire Reset,
    input wire [15:0] I,
    input wire [1:0] OutCSel,
    input wire [1:0] OutDSel,
    input wire [2:0] FunSel,
    input wire [2:0] RegSel,
    output reg [15:0] OutC,
    output reg [15:0] OutD
);

    // Enable: RegSel is active-low, also enable on reset
    wire PC_Enable = ~RegSel[0] | ~Reset;
    wire AR_Enable = ~RegSel[1] | ~Reset;
    wire SP_Enable = ~RegSel[2] | ~Reset;

    // On reset, force clear
    wire [2:0] ActualFunSel = (~Reset) ? 3'b000 : FunSel;

    wire [15:0] PC_Q, AR_Q, SP_Q;

    Register16bit PC(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(PC_Enable), .Q(PC_Q));
    Register16bit AR(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(AR_Enable), .Q(AR_Q));
    Register16bit SP(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(SP_Enable), .Q(SP_Q));

    // Output MUX C: 00->PC, 01->PC, 10->AR, 11->SP
    always @(*) begin
        case (OutCSel)
            2'b00: OutC = PC_Q;
            2'b01: OutC = PC_Q;
            2'b10: OutC = AR_Q;
            2'b11: OutC = SP_Q;
        endcase
    end

    // Output MUX D: 00->PC, 01->PC, 10->AR, 11->SP
    always @(*) begin
        case (OutDSel)
            2'b00: OutD = PC_Q;
            2'b01: OutD = PC_Q;
            2'b10: OutD = AR_Q;
            2'b11: OutD = SP_Q;
        endcase
    end

endmodule

`timescale 1ns / 1ps

module RegisterFile(
    input wire Clock,
    input wire Reset,
    input wire [15:0] I,
    input wire [2:0] OutASel,
    input wire [2:0] OutBSel,
    input wire [2:0] FunSel,
    input wire [3:0] RegSel,
    input wire [3:0] ScrSel,
    output reg [15:0] OutA,
    output reg [15:0] OutB
);

    // Enable signals: RegSel/ScrSel are active-low
    wire R1_Enable = ~RegSel[0] | ~Reset;
    wire R2_Enable = ~RegSel[1] | ~Reset;
    wire R3_Enable = ~RegSel[2] | ~Reset;
    wire R4_Enable = ~RegSel[3] | ~Reset;
    wire S1_Enable = ~ScrSel[0] | ~Reset;
    wire S2_Enable = ~ScrSel[1] | ~Reset;
    wire S3_Enable = ~ScrSel[2] | ~Reset;
    wire S4_Enable = ~ScrSel[3] | ~Reset;

    // FunSel override: when Reset is active (low), force clear (FunSel=000)
    wire [2:0] ActualFunSel = (~Reset) ? 3'b000 : FunSel;

    wire [15:0] R1_Q, R2_Q, R3_Q, R4_Q;
    wire [15:0] S1_Q, S2_Q, S3_Q, S4_Q;

    Register16bit R1(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(R1_Enable), .Q(R1_Q));
    Register16bit R2(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(R2_Enable), .Q(R2_Q));
    Register16bit R3(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(R3_Enable), .Q(R3_Q));
    Register16bit R4(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(R4_Enable), .Q(R4_Q));
    Register16bit S1(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(S1_Enable), .Q(S1_Q));
    Register16bit S2(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(S2_Enable), .Q(S2_Q));
    Register16bit S3(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(S3_Enable), .Q(S3_Q));
    Register16bit S4(.Clock(Clock), .I(I), .FunSel(ActualFunSel), .Enable(S4_Enable), .Q(S4_Q));

    // Output MUX A
    always @(*) begin
        case (OutASel)
            3'b000: OutA = R1_Q;
            3'b001: OutA = R2_Q;
            3'b010: OutA = R3_Q;
            3'b011: OutA = R4_Q;
            3'b100: OutA = S1_Q;
            3'b101: OutA = S2_Q;
            3'b110: OutA = S3_Q;
            3'b111: OutA = S4_Q;
        endcase
    end

    // Output MUX B
    always @(*) begin
        case (OutBSel)
            3'b000: OutB = R1_Q;
            3'b001: OutB = R2_Q;
            3'b010: OutB = R3_Q;
            3'b011: OutB = R4_Q;
            3'b100: OutB = S1_Q;
            3'b101: OutB = S2_Q;
            3'b110: OutB = S3_Q;
            3'b111: OutB = S4_Q;
        endcase
    end

endmodule

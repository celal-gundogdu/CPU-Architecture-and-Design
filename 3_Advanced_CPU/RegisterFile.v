`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module RegisterFile(
    input wire Clock,
    input wire [15:0] I,           // Input data
    input wire [3:0] RegSel,       // Register select (active-low): R1,R2,R3,R4
    input wire [3:0] ScrSel,       // Scratch select (active-low): S1,S2,S3,S4
    input wire [2:0] OutASel,      // Output A register select
    input wire [2:0] OutBSel,      // Output B register select
    input wire FunSel,             // Function select for registers
    output reg [15:0] OutA,        // Output A
    output reg [15:0] OutB         // Output B
);

    // Registers R1-R4 and Scratch S1-S4
    wire [15:0] R1_Q, R2_Q, R3_Q, R4_Q;
    wire [15:0] S1_Q, S2_Q, S3_Q, S4_Q;

    Register16bit R1(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[0]), .Q(R1_Q));
    Register16bit R2(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[1]), .Q(R2_Q));
    Register16bit R3(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[2]), .Q(R3_Q));
    Register16bit R4(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[3]), .Q(R4_Q));

    Register16bit S1(.Clock(Clock), .I(I), .FunSel(FunSel), .E(ScrSel[0]), .Q(S1_Q));
    Register16bit S2(.Clock(Clock), .I(I), .FunSel(FunSel), .E(ScrSel[1]), .Q(S2_Q));
    Register16bit S3(.Clock(Clock), .I(I), .FunSel(FunSel), .E(ScrSel[2]), .Q(S3_Q));
    Register16bit S4(.Clock(Clock), .I(I), .FunSel(FunSel), .E(ScrSel[3]), .Q(S4_Q));

    // Output A MUX
    always @(*) begin
        case(OutASel)
            3'b000: OutA = R1_Q;
            3'b001: OutA = R2_Q;
            3'b010: OutA = R3_Q;
            3'b011: OutA = R4_Q;
            3'b100: OutA = S1_Q;
            3'b101: OutA = S2_Q;
            3'b110: OutA = S3_Q;
            3'b111: OutA = S4_Q;
            default: OutA = 16'h0000;
        endcase
    end

    // Output B MUX
    always @(*) begin
        case(OutBSel)
            3'b000: OutB = R1_Q;
            3'b001: OutB = R2_Q;
            3'b010: OutB = R3_Q;
            3'b011: OutB = R4_Q;
            3'b100: OutB = S1_Q;
            3'b101: OutB = S2_Q;
            3'b110: OutB = S3_Q;
            3'b111: OutB = S4_Q;
            default: OutB = 16'h0000;
        endcase
    end

endmodule

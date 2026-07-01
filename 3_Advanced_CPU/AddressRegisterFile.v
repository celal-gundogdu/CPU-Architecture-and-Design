`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 3
//////////////////////////////////////////////////////////////////////////////////

module AddressRegisterFile(
    input wire Clock,
    input wire [15:0] I,           // Input data
    input wire [2:0] RegSel,       // Register select (active-low): PC, AR, SP
    input wire [1:0] OutCSel,      // Output C register select
    input wire [1:0] OutDSel,      // Output D register select
    input wire FunSel,             // Function select for registers
    output reg [15:0] OutC,        // Output C
    output reg [15:0] OutD         // Output D
);

    wire [15:0] PC_Q, AR_Q, SP_Q;

    Register16bit PC(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[0]), .Q(PC_Q));
    Register16bit AR(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[1]), .Q(AR_Q));
    Register16bit SP(.Clock(Clock), .I(I), .FunSel(FunSel), .E(RegSel[2]), .Q(SP_Q));

    // Output C MUX
    always @(*) begin
        case(OutCSel)
            2'b00: OutC = PC_Q;
            2'b01: OutC = PC_Q;
            2'b10: OutC = AR_Q;
            2'b11: OutC = SP_Q;
            default: OutC = 16'h0000;
        endcase
    end

    // Output D MUX
    always @(*) begin
        case(OutDSel)
            2'b00: OutD = PC_Q;
            2'b01: OutD = PC_Q;
            2'b10: OutD = AR_Q;
            2'b11: OutD = SP_Q;
            default: OutD = 16'h0000;
        endcase
    end

endmodule

`timescale 1ns / 1ps

module ArithmeticLogicUnitSystem(
    input wire Clock,
    input wire [3:0] RF_RegSel,
    input wire [3:0] RF_ScrSel,
    input wire [2:0] RF_OutASel,
    input wire [2:0] RF_OutBSel,
    input wire RF_FunSel,
    input wire [2:0] ARF_RegSel,
    input wire [1:0] ARF_OutCSel,
    input wire [1:0] ARF_OutDSel,
    input wire ARF_FunSel,
    input wire [4:0] ALU_FunSel,
    input wire ALU_WF,
    input wire [1:0] MuxASel,
    input wire [1:0] MuxBSel,
    input wire MuxCSel,
    input wire IMU_CS,
    input wire IMU_LH,
    input wire IR_Enable,
    input wire DMU_CS,
    input wire DMU_WR,
    input wire DMU_LH,
    input wire DR_Enable,
    input wire DMU_DataSel,
    output wire [15:0] IROut,
    output wire [3:0] ALUFlags
);

    wire [15:0] RF_OutA, RF_OutB;
    wire [15:0] ARF_OutC, ARF_OutD;
    wire [15:0] ALUOut_w;
    wire [15:0] DROut;
    wire [3:0] ALUFlags_w;

    // Aliases for testbench hierarchical access compatibility
    wire [15:0] OutA = RF_OutA;
    wire [15:0] OutB = RF_OutB;
    wire [15:0] OutC = ARF_OutC;
    wire [15:0] OutD = ARF_OutD;
    wire [15:0] ALUOut = ALUOut_w;
    wire [15:0] DMUOut = DROut;

    reg [15:0] MuxAOut, MuxBOut, MuxCOut;
    reg [7:0] DMU_DataIn;

    always @(*) begin
        case(MuxASel)
            2'b00: MuxAOut = ALUOut_w;
            2'b01: MuxAOut = DROut;
            2'b10: MuxAOut = {8'h00, IROut[7:0]};
            2'b11: MuxAOut = ARF_OutC;
            default: MuxAOut = 16'h0000;
        endcase
    end

    always @(*) begin
        case(MuxBSel)
            2'b00: MuxBOut = ALUOut_w;
            2'b01: MuxBOut = DROut;
            2'b10: MuxBOut = {8'h00, IROut[7:0]};
            2'b11: MuxBOut = ARF_OutC;
            default: MuxBOut = 16'h0000;
        endcase
    end

    always @(*) begin
        case(MuxCSel)
            1'b0: MuxCOut = RF_OutA;
            1'b1: MuxCOut = ARF_OutC;
            default: MuxCOut = 16'h0000;
        endcase
    end

    always @(*) begin
        case(DMU_DataSel)
            1'b0: DMU_DataIn = ALUOut_w[7:0];
            1'b1: DMU_DataIn = ALUOut_w[15:8];
            default: DMU_DataIn = 8'h00;
        endcase
    end

    RegisterFile RF(
        .Clock(Clock), .I(MuxAOut), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel),
        .OutASel(RF_OutASel), .OutBSel(RF_OutBSel), .FunSel(RF_FunSel),
        .OutA(RF_OutA), .OutB(RF_OutB)
    );

    AddressRegisterFile ARF(
        .Clock(Clock), .I(MuxBOut), .RegSel(ARF_RegSel),
        .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel), .FunSel(ARF_FunSel),
        .OutC(ARF_OutC), .OutD(ARF_OutD)
    );

    ArithmeticLogicUnit ALU(
        .A(MuxCOut), .B(RF_OutB), .FunSel(ALU_FunSel), .WF(ALU_WF),
        .Clock(Clock), .ALUOut(ALUOut_w), .FlagsOut(ALUFlags_w)
    );

    InstructionMemoryUnit IMU(
        .Clock(Clock), .Address(ARF_OutD), .LH(IMU_LH), .CS(IMU_CS),
        .IR_Enable(IR_Enable), .IROut(IROut)
    );

    DataMemoryUnit DMU(
        .Clock(Clock), .Address(ARF_OutD), .Data(DMU_DataIn),
        .WR(DMU_WR), .CS(DMU_CS), .LH(DMU_LH), .DR_Enable(DR_Enable),
        .DROut(DROut)
    );

    assign ALUFlags = ALUFlags_w;

endmodule

`timescale 1ns / 1ps

module ArithmeticLogicUnitSystem(
    input wire Clock,
    input wire Reset,
    // RF control
    input wire [2:0] RF_OutASel,
    input wire [2:0] RF_OutBSel,
    input wire [2:0] RF_FunSel,
    input wire [3:0] RF_RegSel,
    input wire [3:0] RF_ScrSel,
    // ARF control
    input wire [1:0] ARF_OutCSel,
    input wire [1:0] ARF_OutDSel,
    input wire [2:0] ARF_FunSel,
    input wire [2:0] ARF_RegSel,
    // ALU control
    input wire [4:0] ALU_FunSel,
    input wire ALU_WF,
    // MUX selects
    input wire MuxASel,
    input wire MuxBSel,
    input wire [1:0] MuxCSel,
    // IMU control
    input wire IR_LH,
    input wire IR_Load,
    input wire IR_CS,
    // DMU control  
    input wire [7:0] DMU_Data,
    input wire DMU_WR,
    input wire DMU_CS,
    input wire DR_LH,
    input wire DR_Load,
    // Outputs
    output wire [15:0] ALUOut,
    output wire [3:0] FlagsOut,
    output wire [15:0] IROut,
    output wire [15:0] OutA,
    output wire [15:0] OutB,
    output wire [15:0] OutC,
    output wire [15:0] OutD,
    output wire [15:0] DMUOut
);

    // MUX outputs
    reg [15:0] MuxAOut;
    reg [15:0] MuxBOut;
    reg [15:0] MuxCOut;

    // RF I/O
    wire [15:0] RF_OutA, RF_OutB;
    // ARF I/O  
    wire [15:0] ARF_OutC, ARF_OutD;
    // ALU I/O
    wire [15:0] ALU_Out;
    wire [3:0] ALU_FlagsOut;
    // IMU
    wire [15:0] IMU_IROut;
    // DMU
    wire [15:0] DMU_Out;

    // Register File
    RegisterFile RF(
        .Clock(Clock),
        .Reset(Reset),
        .I(MuxCOut),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .OutA(RF_OutA),
        .OutB(RF_OutB)
    );

    // Address Register File
    AddressRegisterFile ARF(
        .Clock(Clock),
        .Reset(Reset),
        .I(MuxCOut),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .OutC(ARF_OutC),
        .OutD(ARF_OutD)
    );

    // ALU
    ArithmeticLogicUnit ALU(
        .A(MuxAOut),
        .B(MuxBOut),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .Clock(Clock),
        .ALUOut(ALU_Out),
        .FlagsOut(ALU_FlagsOut)
    );

    // IMU - uses ARF OutD as address
    InstructionMemoryUnit IMU(
        .Clock(Clock),
        .Reset(Reset),
        .Address(ARF_OutD),
        .LH(IR_LH),
        .Load(IR_Load),
        .CS(IR_CS),
        .IROut(IMU_IROut)
    );

    // DMU - uses ARF OutD as address
    DataMemoryUnit DMU(
        .Clock(Clock),
        .Reset(Reset),
        .Address(ARF_OutD),
        .Data(DMU_Data),
        .WR(DMU_WR),
        .CS(DMU_CS),
        .LH(DR_LH),
        .Load(DR_Load),
        .DMUOut(DMU_Out)
    );

    // MUX A: 0->RF.OutA, 1->ARF.OutC
    always @(*) begin
        case (MuxASel)
            1'b0: MuxAOut = RF_OutA;
            1'b1: MuxAOut = ARF_OutC;
        endcase
    end

    // MUX B: 0->RF.OutB, 1->ARF.OutD
    always @(*) begin
        case (MuxBSel)
            1'b0: MuxBOut = RF_OutB;
            1'b1: MuxBOut = ARF_OutD;
        endcase
    end

    // MUX C: 00->ALUOut, 01->DMUOut, 10->IROut(low 8 zero-extended), 11->ALUOut
    always @(*) begin
        case (MuxCSel)
            2'b00: MuxCOut = ALU_Out;
            2'b01: MuxCOut = DMU_Out;
            2'b10: MuxCOut = {8'h00, IMU_IROut[7:0]};
            2'b11: MuxCOut = ALU_Out;
        endcase
    end

    // Output assignments
    assign ALUOut = ALU_Out;
    assign FlagsOut = ALU_FlagsOut;
    assign IROut = IMU_IROut;
    assign OutA = RF_OutA;
    assign OutB = RF_OutB;
    assign OutC = ARF_OutC;
    assign OutD = ARF_OutD;
    assign DMUOut = DMU_Out;

endmodule

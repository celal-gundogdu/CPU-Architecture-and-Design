`timescale 1ns / 1ps

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);
    // ===== Control signals =====
    reg [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [1:0] ARF_OutCSel, ARF_OutDSel;
    reg [2:0] ARF_FunSel;
    reg [2:0] ARF_RegSel;
    reg [4:0] ALU_FunSel;
    reg ALU_WF;
    reg MuxASel, MuxBSel;
    reg [1:0] MuxCSel;
    reg IR_LH, IR_Load, IR_CS;
    reg IMU_CS;
    reg [7:0] DMU_Data;
    reg DMU_WR, DMU_CS;
    reg DR_LH, DR_Load;
    reg T_Reset;

    // ===== T counter logic =====
    initial T = 12'b0000_0000_0001;
    always @(posedge Clock) begin
        if (~Reset || T_Reset)
            T <= 12'b0000_0000_0001;
        else
            T <= {T[10:0], 1'b0};
    end

    // ===== Instruction decode =====
    wire [15:0] IROut;
    wire [5:0] Opcode  = IROut[15:10];
    wire [1:0] RegSel  = IROut[9:8];
    wire [7:0] Address = IROut[7:0];
    wire [2:0] DestReg = IROut[9:7];
    wire [2:0] SrcReg1 = IROut[6:4];
    wire [2:0] SrcReg2 = IROut[3:1];

    // ===== ALUSystem outputs =====
    wire [15:0] ALUOut;
    wire [3:0] FlagsOut;
    wire [15:0] OutA, OutB, OutC, OutD;
    wire [15:0] DMUOut;

    // ===== ALUSystem =====
    ArithmeticLogicUnitSystem ALUSys(
        .Clock(Clock), .Reset(Reset),
        .RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel), .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel),
        .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel),
        .ARF_FunSel(ARF_FunSel), .ARF_RegSel(ARF_RegSel),
        .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF),
        .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel),
        .IR_LH(IR_LH), .IR_Load(IR_Load), .IR_CS(IR_CS),
        .DMU_Data(DMU_Data), .DMU_WR(DMU_WR), .DMU_CS(DMU_CS),
        .DR_LH(DR_LH), .DR_Load(DR_Load),
        .ALUOut(ALUOut), .FlagsOut(FlagsOut), .IROut(IROut),
        .OutA(OutA), .OutB(OutB), .OutC(OutC), .OutD(OutD), .DMUOut(DMUOut)
    );

    // ===== Opcode constants =====
    localparam [5:0] BRA=0, BNE=1, BEQ=2, BLT=3, BGT=4, BLE=5, BGE=6;
    localparam [5:0] INC=7, DEC=8, LSL_O=9, LSR_O=10, ASR_O=11;
    localparam [5:0] CSL_O=12, CSR_O=13, NOT_O=14;
    localparam [5:0] AND_O=15, ORR_O=16, XOR_O=17, NAND_O=18;
    localparam [5:0] ADD=19, ADC=20, SUB_O=21, MOV=22, IMM=23;

    // ===== Flags =====
    wire Zf = FlagsOut[3], Cf = FlagsOut[2], Nf = FlagsOut[1], Of = FlagsOut[0];

    // ===== Category =====
    wire is_branch    = (Opcode <= BGE);
    wire is_single_op = (Opcode >= INC && Opcode <= NOT_O);
    wire is_two_op    = (Opcode >= AND_O && Opcode <= SUB_O);
    wire is_alu_or_mov= (Opcode >= INC && Opcode <= MOV);

    // ===== Branch condition =====
    reg branch_taken;
    always @(*) begin
        case (Opcode)
            BRA: branch_taken = 1;
            BNE: branch_taken = ~Zf;
            BEQ: branch_taken = Zf;
            BLT: branch_taken = (Nf != Of);
            BGT: branch_taken = (Nf == Of) & ~Zf;
            BLE: branch_taken = (Nf != Of) | Zf;
            BGE: branch_taken = (Nf == Of);
            default: branch_taken = 0;
        endcase
    end

    // ===== ALU FunSel mapping =====
    reg [4:0] alu_fun;
    always @(*) begin
        case (Opcode)
            INC:    alu_fun = 5'b10000;
            DEC:    alu_fun = 5'b10001;
            LSL_O:  alu_fun = 5'b01011;
            LSR_O:  alu_fun = 5'b01100;
            ASR_O:  alu_fun = 5'b01101;
            CSL_O:  alu_fun = 5'b01110;
            CSR_O:  alu_fun = 5'b01111;
            NOT_O:  alu_fun = 5'b00010;
            AND_O:  alu_fun = 5'b00111;
            ORR_O:  alu_fun = 5'b01000;
            XOR_O:  alu_fun = 5'b01001;
            NAND_O: alu_fun = 5'b01010;
            ADD:    alu_fun = 5'b00100;
            ADC:    alu_fun = 5'b00101;
            SUB_O:  alu_fun = 5'b00110;
            MOV:    alu_fun = 5'b00000;
            default: alu_fun = 5'b00000;
        endcase
    end

    // ===== Destination decode =====
    reg [3:0] dst_rf;
    always @(*) begin
        case (DestReg[1:0])
            2'b00: dst_rf = 4'b1110;
            2'b01: dst_rf = 4'b1101;
            2'b10: dst_rf = 4'b1011;
            2'b11: dst_rf = 4'b0111;
        endcase
    end

    reg [2:0] dst_arf;
    always @(*) begin
        case (DestReg)
            3'b000: dst_arf = 3'b110;
            3'b001: dst_arf = 3'b110;
            3'b010: dst_arf = 3'b101;
            3'b011: dst_arf = 3'b011;
            default: dst_arf = 3'b111;
        endcase
    end

    reg [3:0] imm_rf;
    always @(*) begin
        case (RegSel)
            2'b00: imm_rf = 4'b1110;
            2'b01: imm_rf = 4'b1101;
            2'b10: imm_rf = 4'b1011;
            2'b11: imm_rf = 4'b0111;
        endcase
    end

    // ===== Source helpers =====
    wire [2:0] src_a_rf = {1'b0, SrcReg1[1:0]};
    wire [2:0] src_b_rf = {1'b0, SrcReg2[1:0]};

    // ===== MAIN CONTROL LOGIC=====
    always @(*) begin
        // 1. DEFAULT VALUES FOR WRITES AND STATUS
        RF_FunSel   = 3'b000;  
        RF_RegSel   = 4'b1111; 
        RF_ScrSel   = 4'b1111;
        ARF_FunSel  = 3'b000;  
        ARF_RegSel  = 3'b111;
        ALU_WF      = 0;
        MuxCSel     = 2'b00;
        IR_LH       = 0; 
        IR_Load     = 0; 
        IR_CS       = 1;
        IMU_CS      = 1;
        DMU_Data    = 8'h00; 
        DMU_WR      = 0; 
        DMU_CS      = 1;
        DR_LH       = 0; 
        DR_Load     = 0;
        T_Reset     = 0;

        // 2. COMBINATIONAL SOURCE ROUTING
        RF_OutASel  = 3'b000;
        RF_OutBSel  = 3'b000;
        ARF_OutCSel = 2'b00;
        ARF_OutDSel = 2'b00;
        MuxASel     = 0; 
        MuxBSel     = 0; 
        ALU_FunSel  = 5'b00000;

        if (is_alu_or_mov) begin
            ALU_FunSel = alu_fun;
            
            // Source A Muxing
            if (SrcReg1[2]) begin
                MuxASel = 0;
                RF_OutASel = src_a_rf;
            end else begin
                MuxASel = 1;
                ARF_OutCSel = SrcReg1[1:0];
            end

            // Source B Muxing
            if (is_two_op) begin
                if (SrcReg2[2]) begin
                    MuxBSel = 0;
                    RF_OutBSel = src_b_rf;
                end else begin
                    MuxBSel = 1;
                    ARF_OutDSel = SrcReg2[1:0];
                end
            end
        end

        // 3. T-STATE SPECIFIC BEHAVIORS & OVERRIDES
        if (T[0]) begin
            ARF_OutDSel = 2'b00; // Fetch için Adres mecburen PC olmalı
            IR_CS = 0; 
            IMU_CS = 0;
            IR_LH = 0; 
            IR_Load = 1;
            ARF_FunSel = 3'b010; // PC Increment
            ARF_RegSel = 3'b110; 
        end
        else if (T[1]) begin
            ARF_OutDSel = 2'b00; // Fetch için Adres mecburen PC olmalı
            IR_CS = 0; 
            IMU_CS = 0;
            IR_LH = 1; 
            IR_Load = 1;
            ARF_FunSel = 3'b010; // PC Increment
            ARF_RegSel = 3'b110; 
        end
        else if (T[2]) begin
            if (is_branch) begin
                if (branch_taken) begin
                    MuxCSel = 2'b10; // Adresi IROut'tan al
                    ARF_FunSel = 3'b001; // Load PC
                    ARF_RegSel = 3'b110; 
                end
                T_Reset = 1;
            end
            else if (Opcode == IMM) begin
                MuxCSel = 2'b10;
                RF_FunSel = 3'b001; // Load Dst Register
                RF_RegSel = imm_rf;
                T_Reset = 1;
            end
        end
        else if (T[3]) begin
            if (is_alu_or_mov) begin
                ALU_WF = 1; // Flagleri güncelle
                MuxCSel = 2'b00; // Veriyi ALUOut'tan al
                
                if (DestReg[2]) begin
                    RF_FunSel = 3'b001;
                    RF_RegSel = dst_rf;
                end else begin
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = dst_arf;
                end
                T_Reset = 1;
            end
        end
    end

endmodule
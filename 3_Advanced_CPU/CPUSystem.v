`timescale 1ns / 1ps
module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [2:0] RF_OutASel, RF_OutBSel;
    reg RF_FunSel;
    reg [2:0] ARF_RegSel;
    reg [1:0] ARF_OutCSel, ARF_OutDSel;
    reg ARF_FunSel;
    reg [4:0] ALU_FunSel;
    reg ALU_WF;
    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;
    reg IMU_CS, IMU_LH, IR_Enable;
    reg DMU_CS, DMU_WR, DMU_LH, DR_Enable;
    reg DMU_DataSel;
    reg T_Reset;

    wire [15:0] IROut;
    wire [3:0] ALUFlags;

    wire [5:0] Opcode = IROut[15:10];
    wire [1:0] RegSel = IROut[9:8];
    wire [7:0] Address = IROut[7:0];
    wire [2:0] DestReg = IROut[9:7];
    wire [2:0] SrcReg1 = IROut[6:4];
    wire [2:0] SrcReg2 = IROut[3:1];

    wire Z = ALUFlags[3], C = ALUFlags[2], N = ALUFlags[1], O = ALUFlags[0];
    wire dst_rf = DestReg[2];
    wire s1_rf = SrcReg1[2];
    wire s2_rf = SrcReg2[2];

    wire [3:0] dst_rf_sel = ~(4'b0001 << DestReg[1:0]);
    wire [2:0] dst_arf_sel = (DestReg[1:0]==2'b00||DestReg[1:0]==2'b01)?3'b110:
                             (DestReg[1:0]==2'b10)?3'b101:3'b011;
    wire [3:0] rsel_rf_sel = ~(4'b0001 << RegSel);

    ArithmeticLogicUnitSystem ALUSys(
        .Clock(Clock),
        .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel),
        .RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel), .RF_FunSel(RF_FunSel),
        .ARF_RegSel(ARF_RegSel), .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel),
        .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF),
        .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel),
        .IMU_CS(IMU_CS), .IMU_LH(IMU_LH), .IR_Enable(IR_Enable),
        .DMU_CS(DMU_CS), .DMU_WR(DMU_WR), .DMU_LH(DMU_LH), .DR_Enable(DR_Enable),
        .DMU_DataSel(DMU_DataSel),
        .IROut(IROut), .ALUFlags(ALUFlags)
    );

    // T counter
    always @(posedge Clock) begin
        if (~Reset)
            T <= 12'h001;
        else if (T_Reset)
            T <= 12'h001;
        else
            T <= T << 1;
    end

    // Default all signals task-like
    task set_defaults;
    begin
        RF_RegSel=4'b1111; RF_ScrSel=4'b1111; RF_FunSel=1; RF_OutASel=3'b000; RF_OutBSel=3'b000;
        ARF_RegSel=3'b111; ARF_FunSel=1; ARF_OutCSel=2'b00; ARF_OutDSel=2'b00;
        ALU_FunSel=5'h00; ALU_WF=0;
        MuxASel=2'b00; MuxBSel=2'b00; MuxCSel=0;
        IMU_CS=1; IMU_LH=0; IR_Enable=1;
        DMU_CS=1; DMU_WR=0; DMU_LH=0; DR_Enable=1;
        DMU_DataSel=0; T_Reset=0;
    end
    endtask

    reg branch_taken;
    reg [4:0] alu_op;

    always @(*) begin
        set_defaults;
        branch_taken = 0;
        alu_op = 5'h00;

        if (~Reset) begin
            // Active-low reset: clear all RF and ARF registers
            RF_RegSel  = 4'b0000;   // Enable all RF registers (active-low)
            RF_ScrSel  = 4'b0000;   // Enable all scratch registers
            RF_FunSel  = 1;         // FunSel=1 means Clear
            ARF_RegSel = 3'b000;    // Enable all ARF registers
            ARF_FunSel = 1;         // Clear
            T_Reset    = 1;
        end
        else if (T[0]) begin // T0: Fetch LSB
            ARF_OutDSel=2'b00; ARF_OutCSel=2'b00;
            IMU_CS=0; IMU_LH=0; IR_Enable=0;
            MuxCSel=1; ALU_FunSel=5'h10;
            MuxBSel=2'b00; ARF_RegSel=3'b110; ARF_FunSel=0;
        end
        else if (T[1]) begin // T1: Fetch MSB
            ARF_OutDSel=2'b00; ARF_OutCSel=2'b00;
            IMU_CS=0; IMU_LH=1; IR_Enable=0;
            MuxCSel=1; ALU_FunSel=5'h10;
            MuxBSel=2'b00; ARF_RegSel=3'b110; ARF_FunSel=0;
        end
        else begin // T2+: Execute
            case(Opcode)
            // ---- BRANCHES ----
            6'h00: begin branch_taken=1; end // BRA
            6'h01: begin if(!Z) branch_taken=1; else T_Reset=1; end // BNE
            6'h02: begin if(Z) branch_taken=1; else T_Reset=1; end // BEQ
            6'h03: begin if(N!=O) branch_taken=1; else T_Reset=1; end // BLT
            6'h04: begin if(N==O && !Z) branch_taken=1; else T_Reset=1; end // BGT
            6'h05: begin if(N!=O || Z) branch_taken=1; else T_Reset=1; end // BLE
            6'h06: begin if(N==O) branch_taken=1; else T_Reset=1; end // BGE

            // ---- SINGLE OPERAND ALU (0x07-0x0E) ----
            6'h07, 6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0C, 6'h0D, 6'h0E: begin
                if (T[2]) begin
                    case(Opcode)
                        6'h07: alu_op=5'h10; 6'h08: alu_op=5'h11;
                        6'h09: alu_op=5'h0B; 6'h0A: alu_op=5'h0C;
                        6'h0B: alu_op=5'h0D; 6'h0C: alu_op=5'h0E;
                        6'h0D: alu_op=5'h0F; 6'h0E: alu_op=5'h02;
                        default: alu_op=5'h00;
                    endcase
                    ALU_FunSel = alu_op; ALU_WF=1;
                    if (s1_rf) begin MuxCSel=0; RF_OutASel={1'b0,SrcReg1[1:0]}; end
                    else begin MuxCSel=1; ARF_OutCSel=SrcReg1[1:0]; end
                    if (dst_rf) begin MuxASel=2'b00; RF_RegSel=dst_rf_sel; RF_FunSel=0; end
                    else begin MuxBSel=2'b00; ARF_RegSel=dst_arf_sel; ARF_FunSel=0; end
                    T_Reset=1;
                end
            end

            // ---- TWO OPERAND ALU (0x0F-0x15) ----
            6'h0F, 6'h10, 6'h11, 6'h12, 6'h13, 6'h14, 6'h15: begin
                case(Opcode)
                    6'h0F: alu_op=5'h07; 6'h10: alu_op=5'h08;
                    6'h11: alu_op=5'h09; 6'h12: alu_op=5'h0A;
                    6'h13: alu_op=5'h04; 6'h14: alu_op=5'h05;
                    6'h15: alu_op=5'h06;
                    default: alu_op=5'h00;
                endcase

                if (s2_rf) begin // SREG2 in RF - single cycle
                    if (T[2]) begin
                        ALU_FunSel=alu_op; ALU_WF=1;
                        RF_OutBSel={1'b0,SrcReg2[1:0]};
                        if (s1_rf) begin MuxCSel=0; RF_OutASel={1'b0,SrcReg1[1:0]}; end
                        else begin MuxCSel=1; ARF_OutCSel=SrcReg1[1:0]; end
                        if (dst_rf) begin MuxASel=2'b00; RF_RegSel=dst_rf_sel; RF_FunSel=0; end
                        else begin MuxBSel=2'b00; ARF_RegSel=dst_arf_sel; ARF_FunSel=0; end
                        T_Reset=1;
                    end
                end else begin // SREG2 in ARF - need scratch copy
                    if (T[2]) begin // Copy SREG2 to S1
                        ARF_OutCSel=SrcReg2[1:0]; MuxCSel=1;
                        ALU_FunSel=5'h00; MuxASel=2'b00;
                        RF_ScrSel=4'b1110; RF_FunSel=0;
                    end
                    else if (T[3]) begin // Do operation
                        ALU_FunSel=alu_op; ALU_WF=1;
                        RF_OutBSel=3'b100; // S1
                        if (s1_rf) begin MuxCSel=0; RF_OutASel={1'b0,SrcReg1[1:0]}; end
                        else begin MuxCSel=1; ARF_OutCSel=SrcReg1[1:0]; end
                        if (dst_rf) begin MuxASel=2'b00; RF_RegSel=dst_rf_sel; RF_FunSel=0; end
                        else begin MuxBSel=2'b00; ARF_RegSel=dst_arf_sel; ARF_FunSel=0; end
                        T_Reset=1;
                    end
                end
            end

            // ---- MOV (0x16) ----
            6'h16: begin
                if (T[2]) begin
                    ALU_FunSel=5'h00;
                    if (s1_rf) begin MuxCSel=0; RF_OutASel={1'b0,SrcReg1[1:0]}; end
                    else begin MuxCSel=1; ARF_OutCSel=SrcReg1[1:0]; end
                    if (dst_rf) begin MuxASel=2'b00; RF_RegSel=dst_rf_sel; RF_FunSel=0; end
                    else begin MuxBSel=2'b00; ARF_RegSel=dst_arf_sel; ARF_FunSel=0; end
                    T_Reset=1;
                end
            end

            // ---- IMM (0x17) ----
            6'h17: begin
                if (T[2]) begin
                    MuxASel=2'b10; RF_RegSel=rsel_rf_sel; RF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- POP (0x18) ----
            6'h18: begin
                if (T[2]) begin // SP++
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[3]) begin // Read M[SP] LSB, SP++
                    ARF_OutDSel=2'b11; DMU_CS=0; DR_Enable=0; DMU_LH=0;
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[4]) begin // Read M[SP] MSB
                    ARF_OutDSel=2'b11; DMU_CS=0; DR_Enable=0; DMU_LH=1;
                end
                else if (T[5]) begin // DR -> Rx
                    MuxASel=2'b01; RF_RegSel=rsel_rf_sel; RF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- PSH (0x19) ----
            6'h19: begin
                if (T[2]) begin // Write Rx MSB to M[SP]
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b11; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                end
                else if (T[3]) begin // SP--
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h11;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[4]) begin // Write Rx LSB to M[SP]
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b11; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                end
                else if (T[5]) begin // SP--
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h11;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- CALL (0x1A) ----
            6'h1A: begin
                if (T[2]) begin // Write PC MSB to M[SP]
                    ARF_OutCSel=2'b00; MuxCSel=1; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b11; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                end
                else if (T[3]) begin // SP--
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h11;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[4]) begin // Write PC LSB to M[SP]
                    ARF_OutCSel=2'b00; MuxCSel=1; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b11; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                end
                else if (T[5]) begin // SP--
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h11;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[6]) begin // PC <- VALUE
                    MuxBSel=2'b10; ARF_RegSel=3'b110; ARF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- RET (0x1B) ----
            6'h1B: begin
                if (T[2]) begin // SP++
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[3]) begin // Read M[SP] LSB, SP++
                    ARF_OutDSel=2'b11; DMU_CS=0; DR_Enable=0; DMU_LH=0;
                    ARF_OutCSel=2'b11; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b011; ARF_FunSel=0;
                end
                else if (T[4]) begin // Read M[SP] MSB
                    ARF_OutDSel=2'b11; DMU_CS=0; DR_Enable=0; DMU_LH=1;
                end
                else if (T[5]) begin // DR -> PC
                    MuxBSel=2'b01; ARF_RegSel=3'b110; ARF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- LDR (0x1C) ----
            6'h1C: begin
                if (T[2]) begin // Read M[AR] LSB, AR++
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=0;
                    ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[3]) begin // Read M[AR] MSB
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=1;
                end
                else if (T[4]) begin // DR -> DSTREG
                    if (dst_rf) begin MuxASel=2'b01; RF_RegSel=dst_rf_sel; RF_FunSel=0; end
                    else begin MuxBSel=2'b01; ARF_RegSel=dst_arf_sel; ARF_FunSel=0; end
                    T_Reset=1;
                end
            end

            // ---- STR (0x1D) ----
            6'h1D: begin
                if (s1_rf) begin // SREG1 in RF
                    if (T[2]) begin // Write LSB
                        RF_OutASel={1'b0,SrcReg1[1:0]}; MuxCSel=0; ALU_FunSel=5'h00;
                        ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                    end
                    else if (T[3]) begin // AR++
                        ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                        MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                    end
                    else if (T[4]) begin // Write MSB
                        RF_OutASel={1'b0,SrcReg1[1:0]}; MuxCSel=0; ALU_FunSel=5'h00;
                        ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                        T_Reset=1;
                    end
                end else begin // SREG1 in ARF
                    if (T[2]) begin // Copy to S1
                        ARF_OutCSel=SrcReg1[1:0]; MuxCSel=1; ALU_FunSel=5'h00;
                        MuxASel=2'b00; RF_ScrSel=4'b1110; RF_FunSel=0;
                    end
                    else if (T[3]) begin // Write LSB
                        RF_OutASel=3'b100; MuxCSel=0; ALU_FunSel=5'h00;
                        ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                    end
                    else if (T[4]) begin // AR++
                        ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                        MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                    end
                    else if (T[5]) begin // Write MSB
                        RF_OutASel=3'b100; MuxCSel=0; ALU_FunSel=5'h00;
                        ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                        T_Reset=1;
                    end
                end
            end

            // ---- LDA (0x1E) ----
            6'h1E: begin
                if (T[2]) begin // AR <- ADDRESS
                    MuxBSel=2'b10; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[3]) begin // Read M[AR] LSB, AR++
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=0;
                    ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[4]) begin // Read M[AR] MSB
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=1;
                end
                else if (T[5]) begin // DR -> Rx
                    MuxASel=2'b01; RF_RegSel=rsel_rf_sel; RF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- STA (0x1F) ----
            6'h1F: begin
                if (T[2]) begin // AR <- ADDRESS
                    MuxBSel=2'b10; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[3]) begin // Write Rx LSB
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                end
                else if (T[4]) begin // AR++
                    ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[5]) begin // Write Rx MSB
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                    T_Reset=1;
                end
            end

            // ---- LDT (0x20) ----
            6'h20: begin
                if (T[2]) begin // S1 <- OFFSET
                    MuxASel=2'b10; RF_ScrSel=4'b1110; RF_FunSel=0;
                end
                else if (T[3]) begin // AR <- AR + S1
                    ARF_OutCSel=2'b10; MuxCSel=1; RF_OutBSel=3'b100;
                    ALU_FunSel=5'h04; MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[4]) begin // Read M[AR] LSB, AR++
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=0;
                    ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[5]) begin // Read M[AR] MSB
                    ARF_OutDSel=2'b10; DMU_CS=0; DR_Enable=0; DMU_LH=1;
                end
                else if (T[6]) begin // DR -> Rx
                    MuxASel=2'b01; RF_RegSel=rsel_rf_sel; RF_FunSel=0;
                    T_Reset=1;
                end
            end

            // ---- STT (0x21) ----
            6'h21: begin
                if (T[2]) begin // S1 <- OFFSET
                    MuxASel=2'b10; RF_ScrSel=4'b1110; RF_FunSel=0;
                end
                else if (T[3]) begin // AR <- AR + S1
                    ARF_OutCSel=2'b10; MuxCSel=1; RF_OutBSel=3'b100;
                    ALU_FunSel=5'h04; MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[4]) begin // Write Rx LSB
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=0;
                end
                else if (T[5]) begin // AR++
                    ARF_OutCSel=2'b10; MuxCSel=1; ALU_FunSel=5'h10;
                    MuxBSel=2'b00; ARF_RegSel=3'b101; ARF_FunSel=0;
                end
                else if (T[6]) begin // Write Rx MSB
                    RF_OutASel={1'b0,RegSel}; MuxCSel=0; ALU_FunSel=5'h00;
                    ARF_OutDSel=2'b10; DMU_CS=0; DMU_WR=1; DMU_DataSel=1;
                    T_Reset=1;
                end
            end

            default: T_Reset=1;
            endcase

            // Branch common logic
            if (branch_taken && T[2]) begin
                MuxBSel=2'b10; ARF_RegSel=3'b110; ARF_FunSel=0;
                T_Reset=1;
            end
        end
    end
endmodule

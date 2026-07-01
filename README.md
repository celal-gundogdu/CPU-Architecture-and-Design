# Custom 16-Bit CPU Architecture in Verilog ⚙️

Hey there! This repository contains the source code for a complete 16-bit Central Processing Unit (CPU) that I designed and implemented from scratch using Verilog HDL. 

This was developed as the core project for the BLG222E Computer Organization course at Istanbul Technical University. Instead of relying on pre-built IP cores or high-level synthesis, every component here—from the lowest-level multiplexers to the hardwired control unit—was designed, wired, and simulated manually at the Register-Transfer Level (RTL).

## 🧠 Architecture Breakdown

The processor was built progressively across three main stages:

### Phase 1: The Datapath & ALU
I started by laying down the hardware foundation and memory interfaces:
* **Custom ALU:** A 16-bit Arithmetic Logic Unit supporting 16 distinct operations (including arithmetic, logic, and logical/arithmetic/circular shifts) with Zero, Carry, Negative, and Overflow (ZCNO) flags.
* **Register File (RF):** Designed with 4 General Purpose registers (R1-R4) and 4 Scratch registers (S1-S4).
* **Address Register File (ARF):** Dedicated memory tracking unit containing the Program Counter (PC), Stack Pointer (SP), and Address Register (AR).
* **Memory Units:** Integrated a Data Memory Unit (DMU) and Instruction Memory Unit (IMU).

### Phase 2: Instruction Set & Basic Control Unit
With the datapath ready, I built a hardwired control unit to bring the CPU to life.
* **Little-Endian Memory Handling:** Since the RAM outputs 8 bits per cycle, I designed a 2-cycle fetch sequence (T=0 for LSB, T=1 for MSB) to load the 16-bit Instruction Register.
* **Basic ISA:** Implemented the core instruction set, including branching (BRA, BNE, BEQ, BLT, BGT), arithmetic, and immediate value loading operations.

### Phase 3: Advanced Execution & Stack Management
The final phase turned the design into a fully capable processor.
* **Memory & Stack Operations:** Added logic for pushing/popping from the stack (PSH, POP) and handling subroutine calls/returns (CALL, RET). Added explicit load/store operations (LDR, STR, LDA, STA, LDT).
* **Running Real Code:** To prove the architecture works, I wrote a custom assembly-like program that iterates through an array, processes data based on ALU flags, and stores results back to memory. I hand-assembled this program into machine code, loaded it into the ROM, and successfully executed it on the CPU.

## 🛠️ Simulation and Testing

The entire system is verified using automated testbenches in **Xilinx Vivado (2017.4)**.

If you want to run the simulations locally:
1. Navigate to the folder containing the `.v` source and simulation files.
2. Open `Run.bat` in a text editor and ensure the first line points to your local Vivado `settings64.bat` path.
3. Execute `Run.bat` from your command prompt.
4. The script will compile the Verilog files, load `RAM.mem` and `ROM.mem`, and generate a `debug.txt` log with the execution results.
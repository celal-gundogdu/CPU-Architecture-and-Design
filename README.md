# ⚙️ Custom 16-Bit CPU Architecture in Verilog

Hey there! This repository contains the source code for a complete 16-bit Central Processing Unit (CPU) that I designed and implemented from scratch using Verilog HDL. 

This project was developed as the core assignment for the BLG222E Computer Organization course at Istanbul Technical University. **The main objective** was to completely demystify how computers work under the hood. Instead of relying on pre-built IP cores or high-level synthesis, every single component—from the lowest-level multiplexers to the hardwired control unit—was designed, wired, and simulated manually at the Register-Transfer Level (RTL).

## 🧠 What I Built & How It Works

The processor architecture was built progressively across three main stages. By the end of the project, I had a fully functional CPU capable of executing a custom instruction set, managing memory, and handling subroutine calls.

### Phase 1: The Foundation (Datapath & Memory)
I started by laying down the hardware foundation. The goal was to build the execution units and memory interfaces:
* **Custom ALU:** A 16-bit Arithmetic Logic Unit supporting 16 distinct operations (arithmetic, logic, and logical/arithmetic/circular shifts). It continuously calculates and updates the Zero, Carry, Negative, and Overflow (ZCNO) flags based on the results.
* **Register File (RF):** A general-purpose storage unit containing 4 General Purpose registers (R1-R4) and 4 Scratch registers (S1-S4).
* **Address Register File (ARF):** A dedicated memory tracking unit containing the Program Counter (PC), Stack Pointer (SP), and Address Register (AR).
* **Memory Units:** Integrated a Data Memory Unit (DMU) and Instruction Memory Unit (IMU) mapped to block RAMs.

### Phase 2: The Brain (Basic Control Unit & ISA)
With the datapath ready, I built a hardwired control unit to bring the CPU to life.
* **2-Cycle Instruction Fetch:** Since the physical RAM outputs 8 bits per cycle, I designed a 2-cycle fetch sequence. At $T=0$, the LSB of the instruction is loaded; at $T=1$, the MSB is loaded into the 16-bit Instruction Register.
* **Basic ISA:** Implemented the core instruction set, including conditional branching (BRA, BNE, BEQ, BLT, BGT), arithmetic operations, and immediate value loading.

### Phase 3: The Polish (Advanced Execution & Stack Management)
The final phase turned the basic design into a fully capable processor.
* **Stack Operations:** Added hardware logic for pushing/popping from the stack (PSH, POP) and handling subroutine calls and returns (CALL, RET). 
* **Memory Operations:** Implemented explicit load/store operations (LDR, STR, LDA, STA, LDT).
* **Running Real Code:** To prove the architecture works, I wrote a custom assembly program that iterates through an array, processes data based on ALU flags, and stores results back to memory. I hand-assembled this program into machine code, loaded it into the ROM, and successfully executed it on the CPU.

## 🛠️ How to Run and Simulate

The entire system is verified using **Xilinx Vivado (2017.4)**. You can run the simulations using either the automated batch script or directly through the Vivado GUI to inspect the waveforms.

### Method A: Automated Batch Script (Quick Run)
1. Navigate to the folder containing the `.v` source and simulation files.
2. Open `Run.bat` in a text editor and ensure the first line points to your local Vivado `settings64.bat` path.
3. Execute `Run.bat` from your command prompt.
4. The script will compile the Verilog files, load `RAM.mem` and `ROM.mem`, and generate a `debug.txt` log showing the execution results and register states.

### Method B: Xilinx Vivado GUI (For Waveform Inspection)
If you want to look at the RTL schematics or inspect the timing diagrams:
1. Open Xilinx Vivado and create a new RTL Project.
2. Click **Add Sources** -> **Add or create design sources** and add all the `.v` source files (excluding simulation files).
3. Click **Add Sources** -> **Add or create simulation sources** and add the testbench files (e.g., `CPUSystemSimulation.v`).
4. **Important:** To load the memory, click **Add Sources** -> **Add or create design sources**, change the file filter to "All Files", and add the `RAM.mem` and `ROM.mem` files so they are included in the project hierarchy.
5. Set the desired testbench (e.g., `CPUSystemSimulation`) as the **Top Module**.
6. Click **Run Simulation** -> **Run Behavioral Simulation** to open the waveform viewer and observe the CPU cycles in action.
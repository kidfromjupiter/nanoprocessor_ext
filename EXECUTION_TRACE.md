# 8-Bit Microprogrammed Nanoprocessor - Detailed Execution Trace

## Example Program Overview

The Program ROM contains the following 9-instruction sequence:

```
Address  Opcode     Mnemonic         Operation
------   ------     --------         ---------
0        MOVI       MOVI R0, 5       R0 ← 5
1        MOVI       MOVI R1, 3       R1 ← 3
2        ADD        ADD R2, R0, R1   R2 ← R0 + R1 (5 + 3 = 8)
3        SUB        SUB R3, R2, R0   R3 ← R2 - R0 (8 - 5 = 3)
4        MUL        MUL R4, R1, R2   R4 ← R1 × R2 (3 × 8 = 24)
5        DIV        DIV R5, R4, R1   R5 ← R4 ÷ R1 (24 ÷ 3 = 8)
6        JZR        JZR R3           If R3 == 0, jump to address 15 (false)
7        JNZ        JNZ R0           If R0 != 0, jump to address 18 (true)
8        JMP        JMP 20           Jump to address 20
```

---

## Cycle-by-Cycle Execution

### **INSTRUCTION 0: MOVI R0, 5**

**Fetch Phase (Cycle 1-2):**
- **Cycle 1:**
  - `PC = 0` (initial state)
  - `Program_ROM[0]` outputs: `Opcode=MOVI, Rd=R0(000), Imm8=5(00000101)`
  - `Instruction_Decoder` decodes fields:
    - Opcode = 001 (MOVI)
    - Rd = 000 (Register 0)
    - Imm8 = 00000101 (5)
  - Control signals: `PC_Inc=1` (next fetch)

**Execute Phase (Cycle 2-3):**
- **Cycle 2:**
  - `microPC` jumps to microcode entry point: `ENTRY_MOVI = 12`
  - `Microcode_ROM[12]` outputs: `UOp=UOP_WRITE_IMM_RD, Next_Mode=NEXT_ABS, Next_Addr=0`
  - `Control_Unit` decodes `UOP_WRITE_IMM_RD`:
    ```
    Load_Select ← 000 (R0)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← WRITE_DATA_IMM (01)
    PC_Inc ← 1
    ```
  - **Write Data Mux Selection:** `Reg_Write_Data_Sel=01` → selects `Imm8=5`
  - `Reg_Data_In = 00000101` (5)

- **Cycle 3 (Rising Edge):**
  - `Reg_Bank_8` updates: `R0 ← 5`
  - `PC ← 1` (incremented from fetch)

**Result:** `R0 = 5`

---

### **INSTRUCTION 1: MOVI R1, 3**

**Fetch Phase (Cycle 3-4):**
- **Cycle 3:**
  - `PC = 1`
  - `Program_ROM[1]` outputs: `Opcode=MOVI, Rd=001, Imm8=3`
  - `Instruction_Decoder` decodes:
    - Opcode = 001 (MOVI)
    - Rd = 001 (Register 1)
    - Imm8 = 00000011 (3)

**Execute Phase (Cycle 4-5):**
- **Cycle 4:**
  - `microPC → ENTRY_MOVI (12)`
  - `Microcode_ROM[12]`: `UOp=UOP_WRITE_IMM_RD`
  - `Control_Unit`:
    ```
    Load_Select ← 001 (R1)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← 01 (WRITE_DATA_IMM)
    ```
  - `Reg_Data_In = 00000011` (3)

- **Cycle 5 (Rising Edge):**
  - `Reg_Bank_8` updates: `R1 ← 3`
  - `PC ← 2`

**Result:** `R1 = 3`

---

### **INSTRUCTION 2: ADD R2, R0, R1**

**Fetch Phase (Cycle 5-6):**
- **Cycle 5:**
  - `PC = 2`
  - `Program_ROM[2]` outputs: `Opcode=ADD, Rd=010, Rs=001, RT=000`
  - `Instruction_Decoder` decodes:
    - Opcode = 000 (ADD)
    - Rd = 010 (Register 2, destination)
    - Rs = 001 (Register 1, source operand B = 3)
    - RT = 000 (Register 0, source operand A = 5)

**Execute Phase (Cycle 6-8):**
- **Cycle 6:**
  - `microPC → ENTRY_ADD (4)` (from Microcode_ROM)
  - `Microcode_ROM[4]`: `UOp=UOP_LOAD_A_RD, Next_Mode=NEXT_SEQ, Next_Addr=0`
  - `Control_Unit` decodes `UOP_LOAD_A_RD`:
    ```
    Out_Select ← 000 (R0)
    Out_Reg ← 1 (enable register bank output to bus)
    Load_A ← 1 (capture bus into A_Latch on clock edge)
    ```
  - `Bus_Mux` selects: `Central_Bus = Reg_Bank_8[R0] = 5`
  - On clock edge: `A_Latch = 5` (latches the bus value)

- **Cycle 7 (Rising Edge):**
  - `A_Latch` updated at clock edge
  - `microPC → ENTRY_ADD + 1 = 5` (NEXT_SEQ)
  - `Microcode_ROM[5]`: `UOp=UOP_LOAD_B_RS, Next_Mode=NEXT_SEQ, Next_Addr=0`
  - `Control_Unit` decodes `UOP_LOAD_B_RS`:
    ```
    Out_Select ← 001 (R1)
    Out_Reg ← 1 (enable register bank output to bus)
    Load_B ← 1 (capture bus into B_Latch on clock edge)
    ```
  - `Bus_Mux` selects: `Central_Bus = Reg_Bank_8[R1] = 3`
  - On clock edge: `B_Latch = 3` (latches the bus value)

- **Cycle 8 (Rising Edge):**
  - `B_Latch` updated
  - `microPC → 6` (NEXT_SEQ)
  - `Microcode_ROM[6]`: `UOp=UOP_WRITE_ADD_RD, Next_Mode=NEXT_ABS, Next_Addr=0`
  - `Control_Unit` decodes `UOP_WRITE_ADD_RD`:
    ```
    ALU_Mode ← ADD
    Out_Add ← 1
    Load_Select ← 010 (R2)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← 00 (WRITE_DATA_BUS)
    PC_Inc ← 1
    ```
  - **ALU Operation:**
    - Input A = 5, Input B = 3
    - Mode = ADD (no operation mode set, pure addition via RCA)
    - `RCA_8` adds: 5 + 3 = 8
    - Output = 00001000
  - `Bus_Mux` selects: `Central_Bus = ALU_Output = 8`
  - `Reg_Data_In = 8`

- **Cycle 9 (Rising Edge):**
  - `Reg_Bank_8` updates: `R2 ← 8`
  - `PC ← 3`
  - `microPC → 0` (NEXT_ABS with Next_Addr=0, but PC_Inc causes dispatch)

**Result:** `R2 = 5 + 3 = 8`

---

### **INSTRUCTION 3: SUB R3, R2, R0**

**Fetch Phase (Cycle 9-10):**
- **Cycle 9:**
  - `PC = 3`
  - `Program_ROM[3]` outputs: `Opcode=SUB, Rd=011, Rs=000, RT=010`
  - `Instruction_Decoder` decodes:
    - Opcode = 010 (SUB)
    - Rd = 011 (Register 3, destination)
    - Rs = 000 (Register 0, source B = 5)
    - RT = 010 (Register 2, source A = 8)

**Execute Phase (Cycle 10-12):**
- **Cycle 10:**
  - `microPC → ENTRY_SUB (8)`
  - `Microcode_ROM[8]`: `UOp=UOP_LOAD_A_RD`
  - `Control_Unit`: Load R2 into A_Latch
    ```
    Out_Select ← 010 (R2)
    Out_Reg ← 1 (register bank output to bus)
    Load_A ← 1 (capture bus into A_Latch)
    ```
  - On clock edge: `A_Latch = 8`

- **Cycle 11 (Rising Edge):**
  - `microPC → 9`
  - `Microcode_ROM[9]`: `UOp=UOP_LOAD_B_RS`
  - `Control_Unit`: Load R0 into B_Latch
    ```
    Out_Select ← 000 (R0)
    Out_Reg ← 1 (register bank output to bus)
    Load_B ← 1 (capture bus into B_Latch)
    ```
  - On clock edge: `B_Latch = 5`

- **Cycle 12 (Rising Edge):**
  - `microPC → 10`
  - `Microcode_ROM[10]`: `UOp=UOP_WRITE_SUB_RD`
  - `Control_Unit` decodes `UOP_WRITE_SUB_RD`:
    ```
    ALU_Mode ← SUB
    Out_Add ← 1
    Load_Select ← 011 (R3)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← 00 (WRITE_DATA_BUS)
    PC_Inc ← 1
    ```
  - **ALU Operation:**
    - A = 8, B = 5
    - Mode = SUB (sets Sub_Sel to subtraction path)
    - RCA performs: 8 - 5 = 3
    - Output = 00000011
  - `Reg_Data_In = 3`

- **Cycle 13 (Rising Edge):**
  - `Reg_Bank_8` updates: `R3 ← 3`
  - `PC ← 4`

**Result:** `R3 = 8 - 5 = 3`

---

### **INSTRUCTION 4: MUL R4, R1, R2**

**Fetch Phase (Cycle 13-14):**
- **Cycle 13:**
  - `PC = 4`
  - `Program_ROM[4]` outputs: `Opcode=MUL, Rd=100, Rs=010, RT=001`
  - `Instruction_Decoder` decodes:
    - Opcode = 011 (MUL)
    - Rd = 100 (Register 4, destination)
    - Rs = 010 (Register 2, multiplicand B = 8)
    - RT = 001 (Register 1, multiplier A = 3)

**Execute Phase (Cycle 14-20) - Iterative:**

The MUL microcode sequence:
```
ENTRY_MUL = 20

20 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),          -- Load multiplier
21 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),          -- Load multiplicand
22 => Enc(UOP_START_MUL, NEXT_SEQ, 0),          -- Initialize accumulators
23 => Enc(UOP_STEP_MUL, NEXT_WAITDONE, 24),     -- Iterate until done
24 => Enc(UOP_WRITE_EXEC_RD, NEXT_ABS, 0)       -- Write result
```

- **Cycle 14:**
  - `microPC → 20`
  - `Microcode_ROM[20]`: `UOp=UOP_LOAD_A_RD`
  - Load R1 (multiplier=3): 
    ```
    Out_Select ← 001 (R1)
    Out_Reg ← 1
    Load_A ← 1
    ```
  - On clock edge: `A_Latch = 3`

- **Cycle 15 (Rising Edge):**
  - `microPC → 21`
  - `Microcode_ROM[21]`: `UOp=UOP_LOAD_B_RS`
  - Load R2 (multiplicand=8):
    ```
    Out_Select ← 010 (R2)
    Out_Reg ← 1
    Load_B ← 1
    ```
  - On clock edge: `B_Latch = 8`

- **Cycle 16 (Rising Edge):**
  - `microPC → 22`
  - `Microcode_ROM[22]`: `UOp=UOP_START_MUL`
  - `Control_Unit` decodes `UOP_START_MUL`:
    ```
    Mul_Acc ← 0
    Mul_Count ← 0
    Iter_Done ← 0
    ```
  - Initialize: `Mul_Acc = 0` (accumulator), `Mul_Count = 0` (iteration counter)

- **Cycle 17 (Rising Edge):**
  - `microPC → 23`
  - `Microcode_ROM[23]`: `UOp=UOP_STEP_MUL, Next_Mode=NEXT_WAITDONE, Next_Addr=24`
  - `Control_Unit` decodes `UOP_STEP_MUL`:
    ```
    Iteration: Add multiplicand to accumulator if bit is set
    Mul_Acc ← Mul_Acc + B_Latch (if LSB of multiplier = 1)
    Shift multiplier right
    Increment Mul_Count
    Set Iter_Done when Mul_Count == 8
    ```
  - **Iteration 1-3:** (simplified for brevity)
    - Iteration 1: Bit 0 = 1 → `Mul_Acc = 0 + 8 = 8`, `Mul_Count = 1`
    - Iteration 2: Bit 1 = 1 → `Mul_Acc = 8 + 8 = 16`, `Mul_Count = 2`
    - Iteration 3: Bit 2 = 0 → `Mul_Acc = 16` (no add), `Mul_Count = 3`

- **Cycle 18-23:** (Iterations continue in NEXT_WAITDONE mode)
  - microPC stays at 23, Control_Unit continues `UOP_STEP_MUL`
  - Each clock edge executes next iteration of multiply-and-accumulate
  - After 3 iterations (multiplier = 011 binary has only 2 bits set in positions 0,1):
    - Final `Mul_Acc = 24` (3 × 8)
    - `Iter_Done = 1`

- **Cycle 24 (Rising Edge):**
  - `Iter_Done` released, `Next_Mode=NEXT_WAITDONE` allows transition
  - `microPC → 24`
  - `Microcode_ROM[24]`: `UOp=UOP_WRITE_EXEC_RD`
  - `Control_Unit` decodes `UOP_WRITE_EXEC_RD`:
    ```
    Exec_Result ← Mul_Acc (24)
    Load_Select ← 100 (R4)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← 10 (WRITE_DATA_EXEC)
    PC_Inc ← 1
    ```
  - `Reg_Data_In = 24`

- **Cycle 25 (Rising Edge):**
  - `Reg_Bank_8` updates: `R4 ← 24`
  - `PC ← 5`

**Result:** `R4 = 3 × 8 = 24`

---

### **INSTRUCTION 5: DIV R5, R4, R1**

**Fetch Phase (Cycle 25-26):**
- **Cycle 25:**
  - `PC = 5`
  - `Program_ROM[5]` outputs: `Opcode=DIV, Rd=101, Rs=001, RT=100`
  - `Instruction_Decoder` decodes:
    - Opcode = 100 (DIV)
    - Rd = 101 (Register 5, destination)
    - Rs = 001 (Register 1, divisor = 3)
    - RT = 100 (Register 4, dividend = 24)

**Execute Phase (Cycle 26-38) - Iterative:**

The DIV microcode sequence:
```
ENTRY_DIV = 28

28 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),          -- Load dividend
29 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),          -- Load divisor
30 => Enc(UOP_START_DIV, NEXT_SEQ, 0),          -- Initialize
31 => Enc(UOP_STEP_DIV, NEXT_WAITDONE, 32),     -- Iterate
32 => Enc(UOP_WRITE_EXEC_RD, NEXT_ABS, 0)       -- Write quotient
```

- **Cycle 26:**
  - `microPC → 28`
  - `Microcode_ROM[28]`: `UOp=UOP_LOAD_A_RD`
  - Load R4 (dividend=24):
    ```
    Out_Select ← 100 (R4)
    Out_Reg ← 1
    Load_A ← 1
    ```
  - On clock edge: `A_Latch = 24`

- **Cycle 27 (Rising Edge):**
  - `microPC → 29`
  - `Microcode_ROM[29]`: `UOp=UOP_LOAD_B_RS`
  - Load R1 (divisor=3):
    ```
    Out_Select ← 001 (R1)
    Out_Reg ← 1
    Load_B ← 1
    ```
  - On clock edge: `B_Latch = 3`

- **Cycle 28 (Rising Edge):**
  - `microPC → 30`
  - `Microcode_ROM[30]`: `UOp=UOP_START_DIV`
  - `Control_Unit` decodes `UOP_START_DIV`:
    ```
    Div_Quotient ← 0
    Div_Remainder ← A_Latch (24)
    Div_Count ← 0
    Iter_Done ← 0
    ```

- **Cycle 29 (Rising Edge):**
  - `microPC → 31`
  - `Microcode_ROM[31]`: `UOp=UOP_STEP_DIV, Next_Mode=NEXT_WAITDONE`
  - `Control_Unit` decodes `UOP_STEP_DIV`:
    ```
    Long division loop:
    If Div_Remainder >= B_Latch:
        Div_Quotient ← Div_Quotient + 1
        Div_Remainder ← Div_Remainder - B_Latch
    Else:
        (quotient unchanged)
    Increment Div_Count
    Set Iter_Done when Div_Count == 8
    ```

- **Cycle 30-37:** (Iterations in NEXT_WAITDONE mode)
  - Iteration 1: Remainder=24 >= 3 → `Quotient=1, Remainder=21`
  - Iteration 2: Remainder=21 >= 3 → `Quotient=2, Remainder=18`
  - Iteration 3: Remainder=18 >= 3 → `Quotient=3, Remainder=15`
  - Iteration 4: Remainder=15 >= 3 → `Quotient=4, Remainder=12`
  - Iteration 5: Remainder=12 >= 3 → `Quotient=5, Remainder=9`
  - Iteration 6: Remainder=9 >= 3 → `Quotient=6, Remainder=6`
  - Iteration 7: Remainder=6 >= 3 → `Quotient=7, Remainder=3`
  - Iteration 8: Remainder=3 >= 3 → `Quotient=8, Remainder=0`
  - `Iter_Done = 1`

- **Cycle 38 (Rising Edge):**
  - `microPC → 32`
  - `Microcode_ROM[32]`: `UOp=UOP_WRITE_EXEC_RD`
  - `Control_Unit`:
    ```
    Exec_Result ← Div_Quotient (8)
    Load_Select ← 101 (R5)
    Reg_Write ← 1
    Reg_Write_Data_Sel ← 10 (WRITE_DATA_EXEC)
    PC_Inc ← 1
    ```
  - `Reg_Data_In = 8`

- **Cycle 39 (Rising Edge):**
  - `Reg_Bank_8` updates: `R5 ← 8`
  - `PC ← 6`

**Result:** `R5 = 24 ÷ 3 = 8`

---

### **INSTRUCTION 6: JZR R3** (Jump if R3 == 0)

**Fetch Phase (Cycle 39-40):**
- **Cycle 39:**
  - `PC = 6`
  - `Program_ROM[6]` outputs: `Opcode=JZR, Rd=011, (immediate address ignored)`
  - `Instruction_Decoder` decodes:
    - Opcode = 101 (JZR)
    - Rd = 011 (Register 3, test value = 3)

**Execute Phase (Cycle 40-41):**
- **Cycle 40:**
  - `microPC → ENTRY_JZR (16)`
  - `Microcode_ROM[16]`: `UOp=UOP_JZR_RD, Next_Mode=NEXT_ABS, Next_Addr=15`
  - `Control_Unit` decodes `UOP_JZR_RD`:
    ```
    Out_Select ← 011 (R3)
    Out_Reg ← 1 (put register on bus for test)
    Test: Is register value == 0?
    ```
  - `Central_Bus = Reg_Bank_8[R3] = 3`
  - Test result: `3 != 0` → **Jump NOT taken**
  - `PC_Inc ← 1` (normal sequential fetch)

- **Cycle 41 (Rising Edge):**
  - `PC ← 7` (sequential, not 15)

**Result:** R3 is not zero, so jump condition fails. PC advances normally.

---

### **INSTRUCTION 7: JNZ R0** (Jump if R0 != 0)

**Fetch Phase (Cycle 41-42):**
- **Cycle 41:**
  - `PC = 7`
  - `Program_ROM[7]` outputs: `Opcode=JNZ, Rd=000, (immediate address ignored)`
  - `Instruction_Decoder` decodes:
    - Opcode = 110 (JNZ)
    - Rd = 000 (Register 0, test value = 5)

**Execute Phase (Cycle 42-43):**
- **Cycle 42:**
  - `microPC → ENTRY_JNZ (18)`
  - `Microcode_ROM[18]`: `UOp=UOP_JNZ_RD, Next_Mode=NEXT_ABS, Next_Addr=18`
  - `Control_Unit` decodes `UOP_JNZ_RD`:
    ```
    Out_Select ← 000 (R0)
    Out_Reg ← 1 (put register on bus for test)
    Test: Is register value != 0?
    ```
  - `Central_Bus = Reg_Bank_8[R0] = 5`
  - Test result: `5 != 0` → **Jump TAKEN**
  - `PC ← Next_Addr = 18` (jump to address 18)

- **Cycle 43 (Rising Edge):**
  - `PC ← 18` (jump to address 18, skipping instruction 8)

**Result:** R0 is 5 (non-zero), so jump condition succeeds. PC jumps to address 18.

---

### **INSTRUCTION 8: JMP 20** (SKIPPED)

*This instruction is skipped due to the JNZ jump. The processor jumps directly from instruction 7 (address 7) to address 18.*

---

### **Final State After Execution**

```
Register Values:
  R0 = 5      (MOVI R0, 5)
  R1 = 3      (MOVI R1, 3)
  R2 = 8      (ADD R2, R0, R1 → 5+3)
  R3 = 3      (SUB R3, R2, R0 → 8-5)
  R4 = 24     (MUL R4, R1, R2 → 3×8)
  R5 = 8      (DIV R5, R4, R1 → 24÷3)
  R6 = 0      (unused)
  R7 = 0      (unused)

Program Counter:
  PC = 18     (jumped via JNZ R0, address 8 skipped)

Control State:
  microPC = 0 (dispatch state, ready for next instruction)
  Iter_Done = 1 (from last iterative operation)
```

---

## Key Design Insights

### **1. Microprogrammed Execution**
- Every instruction is broken into microinstructions (UOps) stored in Microcode_ROM
- Each UOp generates specific control signals for that micro-cycle
- Sequencing modes (NEXT_SEQ, NEXT_ABS, NEXT_WAITDONE) control microPC progression

### **2. Central Data Bus Architecture**
- All datapath operations route through a single 8-bit bus: `Central_Bus`
- Bus_Mux_4_to_1_8 selects between 4 sources:
  - `Out_A`: ALU input A (from A_Latch)
  - `Out_B`: ALU input B (from B_Latch)
  - `Out_Add`: ALU output (RCA result)
  - `Out_Reg`: Register bank read data

### **3. Write Data Multiplexing**
Three possible write sources for registers:
- **WRITE_DATA_BUS (00)**: Central_Bus (ALU results, register reads) → ADD, SUB, JZR, JNZ
- **WRITE_DATA_IMM (01)**: Imm8 field from instruction → MOVI
- **WRITE_DATA_EXEC (10)**: Iterative operation result → MUL, DIV result writes

### **4. Iterative MUL/DIV via NEXT_WAITDONE**
- MUL: Multiply-and-accumulate loop iterates up to 8 times
  - Loads multiplier/multiplicand from registers (2 cycles)
  - Initializes accumulators (1 cycle)
  - Each NEXT_WAITDONE iteration executes one "add and shift" step
  - Halts at microPC 23 until Iter_Done='1'
  - Writes quotient to destination register (1 cycle)

- DIV: Restoring division loop iterates up to 8 times
  - Loads dividend/divisor from registers (2 cycles)
  - Initializes quotient and remainder (1 cycle)
  - Each NEXT_WAITDONE iteration executes one subtraction attempt
  - If remainder >= divisor: subtract and increment quotient
  - If remainder < divisor: leave quotient unchanged
  - Halts at microPC 31 until Iter_Done='1'
  - Writes quotient to destination register (1 cycle)

### **5. Jump Instruction Zero/Non-Zero Tests**
- JZR/JNZ read a register onto Central_Bus
- Control_Unit tests if value equals zero (combinational comparison)
- If condition met: PC ← Next_Addr (from Microcode_ROM)
- If condition not met: PC ← PC + 1 (sequential advance via PC_Inc)

### **6. Instruction Fetch-Execute Decoupling**
- Program_ROM and Instruction_Decoder operate independently from execution
- Fetch side handles PC incrementing and instruction decoding
- Execute side handles microcode sequencing and datapath control
- Both synchronized through shared clock edge

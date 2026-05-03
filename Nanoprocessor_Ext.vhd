library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity Nanoprocessor_Ext is
    Port (
        Clk      : in STD_LOGIC;
        Reset    : in STD_LOGIC;
        Overflow : out STD_LOGIC;
        Zero     : out STD_LOGIC;
        Div_Zero : out STD_LOGIC;
        PC_Out   : out STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
        R0_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R1_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R2_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R3_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R4_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R5_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R6_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R7_Out   : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Nanoprocessor_Ext;

architecture Structural of Nanoprocessor_Ext is
    signal PC_Curr          : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal PC_Inc           : STD_LOGIC;
    signal PC_Load          : STD_LOGIC;
    signal PC_Target        : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal Instruction_Bus  : STD_LOGIC_VECTOR(INSTR_WIDTH - 1 downto 0);

    signal Opcode           : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0);
    signal Rd               : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Rs               : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Imm_Addr         : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal Imm8             : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

    signal Micro_Addr       : STD_LOGIC_VECTOR(MICRO_ADDR_WIDTH - 1 downto 0);
    signal UOp              : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0);
    signal Next_Mode        : STD_LOGIC_VECTOR(1 downto 0);
    signal Next_Addr_From_ROM : STD_LOGIC_VECTOR(MICRO_ADDR_WIDTH - 1 downto 0);
    signal Micro_Next_Addr  : STD_LOGIC_VECTOR(MICRO_ADDR_WIDTH - 1 downto 0);

    signal Out_A            : STD_LOGIC;
    signal Out_B            : STD_LOGIC;
    signal Out_Add          : STD_LOGIC;
    signal Out_Reg          : STD_LOGIC;
    signal Load_A           : STD_LOGIC;
    signal Load_B           : STD_LOGIC;
    signal Add_Sub_Sel      : STD_LOGIC;
    signal Out_Select       : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Load_Select      : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Reg_Write        : STD_LOGIC;
    signal Reg_Write_Data_Sel : STD_LOGIC_VECTOR(1 downto 0);
    signal Exec_Result      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Div_Zero_Int     : STD_LOGIC;

    signal Reg_Out_Sel      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Reg_Data_In      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal RegA_Q           : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal RegB_Q           : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Add_Out          : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Overflow_Int     : STD_LOGIC;
    signal Zero_Int         : STD_LOGIC;
    signal Central_Bus      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
begin
    PC: entity work.Program_Counter_7
        port map(
            Clk => Clk,
            Res => Reset,
            Inc => PC_Inc,
            Load => PC_Load,
            Load_Addr => PC_Target,
            Q => PC_Curr
        );

    ROM: entity work.Program_ROM_16
        port map(
            Address => PC_Curr,
            Data => Instruction_Bus
        );

    Decoder: entity work.Instruction_Decoder_16
        port map(
            Instruction => Instruction_Bus,
            Opcode => Opcode,
            Rd => Rd,
            Rs => Rs,
            Imm_Addr => Imm_Addr,
            Imm8 => Imm8
        );

    MPC: entity work.MicroPC
        port map(
            Clk => Clk,
            Res => Reset,
            Next_Addr => Micro_Next_Addr,
            Addr_Out => Micro_Addr
        );

    UROM: entity work.Microcode_ROM
        port map(
            UAddr => Micro_Addr,
            UOp => UOp,
            Next_Mode => Next_Mode,
            Next_Addr => Next_Addr_From_ROM
        );

    CU: entity work.Control_Unit
        port map(
            Clk => Clk,
            Res => Reset,
            Micro_Addr => Micro_Addr,
            UOp => UOp,
            Next_Mode => Next_Mode,
            Next_Addr_From_ROM => Next_Addr_From_ROM,
            Opcode => Opcode,
            Rd => Rd,
            Rs => Rs,
            Imm_Addr => Imm_Addr,
            Reg_Out => Reg_Out_Sel,
            A_Value => RegA_Q,
            B_Value => RegB_Q,
            Out_A => Out_A,
            Out_B => Out_B,
            Out_Add => Out_Add,
            Out_Reg => Out_Reg,
            Load_A => Load_A,
            Load_B => Load_B,
            Add_Sub_Sel => Add_Sub_Sel,
            Out_Select => Out_Select,
            Load_Select => Load_Select,
            Reg_Write => Reg_Write,
            Reg_Write_Data_Sel => Reg_Write_Data_Sel,
            PC_Inc => PC_Inc,
            PC_Load => PC_Load,
            PC_Target => PC_Target,
            Exec_Result => Exec_Result,
            Div_Zero => Div_Zero_Int,
            Micro_Next_Addr => Micro_Next_Addr
        );

    RegBank: entity work.Reg_Bank_8
        port map(
            Data_in => Reg_Data_In,
            Out_Select => Out_Select,
            Load_Select => Load_Select,
            Reg_Write => Reg_Write,
            Clk => Clk,
            Res => Reset,
            Reg_Out => Reg_Out_Sel,
            R0 => R0_Out,
            R1 => R1_Out,
            R2 => R2_Out,
            R3 => R3_Out,
            R4 => R4_Out,
            R5 => R5_Out,
            R6 => R6_Out,
            R7 => R7_Out
        );

    RegA: entity work.Reg_8
        port map(
            D => Central_Bus,
            En => Load_A,
            Clk => Clk,
            Res => Reset,
            Q => RegA_Q
        );

    RegB: entity work.Reg_8
        port map(
            D => Central_Bus,
            En => Load_B,
            Clk => Clk,
            Res => Reset,
            Q => RegB_Q
        );

    AddSub: entity work.Add_Sub_8
        port map(
            A => RegA_Q,
            B => RegB_Q,
            Add_Sub_Sel => Add_Sub_Sel,
            S => Add_Out,
            Overflow => Overflow_Int,
            Zero => Zero_Int
        );

    BusMux: entity work.Bus_Mux_4_to_1_8
        port map(
            A_in => RegA_Q,
            B_in => RegB_Q,
            Add_in => Add_Out,
            Reg_in => Reg_Out_Sel,
            Out_A => Out_A,
            Out_B => Out_B,
            Out_Add => Out_Add,
            Out_Reg => Out_Reg,
            Y => Central_Bus
        );

    with Reg_Write_Data_Sel select
        Reg_Data_In <= Central_Bus when WRITE_DATA_BUS,
                       Imm8 when WRITE_DATA_IMM,
                       Exec_Result when WRITE_DATA_EXEC,
                       Central_Bus when others;

    Overflow <= Overflow_Int;
    Zero <= Zero_Int;
    Div_Zero <= Div_Zero_Int;
    PC_Out <= PC_Curr;
end Structural;

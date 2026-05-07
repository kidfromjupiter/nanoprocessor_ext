library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Nanoprocessor_Mul_TB is
end Nanoprocessor_Mul_TB;

architecture Behavioral of Nanoprocessor_Mul_TB is
    signal Clk, Reset : STD_LOGIC := '0';
    signal Scenario : natural range 0 to 4 := 0;
    signal PC_Curr : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal PC_Inc, PC_Load : STD_LOGIC;
    signal PC_Target : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal Instruction_Bus : STD_LOGIC_VECTOR(INSTR_WIDTH - 1 downto 0);

    signal Opcode : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0);
    signal Rd, Rs : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Imm_Addr : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal Imm8 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

    signal Micro_Addr, Next_Addr_From_ROM, Micro_Next_Addr : STD_LOGIC_VECTOR(MICRO_ADDR_WIDTH - 1 downto 0);
    signal UOp : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0);
    signal Next_Mode : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0);
    signal Micro_Src_Select, Micro_Dst_Select : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Micro_ALU_Mode : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0);

    signal Out_A, Out_B, Out_Add, Out_Reg, Load_A, Load_B : STD_LOGIC;
    signal ALU_Mode : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0);
    signal Out_Select, Load_Select : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
    signal Reg_Write : STD_LOGIC;
    signal Reg_Write_Data_Sel : STD_LOGIC_VECTOR(1 downto 0);
    signal Exec_Result : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Div_Zero : STD_LOGIC;

    signal Reg_Out_Sel, Reg_Data_In, RegA_Q, RegB_Q, ALU_Out, Central_Bus : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Overflow, Zero : STD_LOGIC;
    signal R0_Out, R1_Out, R2_Out, R3_Out, R4_Out, R5_Out, R6_Out, R7_Out : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    function Movi(
        RegSel : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
        Value  : natural
    ) return STD_LOGIC_VECTOR is
    begin
        return OPCODE_MOVI & RegSel & "00" & STD_LOGIC_VECTOR(to_unsigned(Value, ADDR_WIDTH));
    end function;

    function RType(
        OpCodeVal : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0);
        Dst       : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
        Src       : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        return OpCodeVal & Dst & Src & "000000";
    end function;

    function Jmp(Target : natural) return STD_LOGIC_VECTOR is
    begin
        return OPCODE_JMP & "00000" & STD_LOGIC_VECTOR(to_unsigned(Target, ADDR_WIDTH));
    end function;

    function Program_Instruction(
        Case_Id : natural;
        Address : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0)
    ) return STD_LOGIC_VECTOR is
        variable Multiplicand : natural := 0;
        variable Multiplier : natural := 0;
    begin
        case Case_Id is
            when 0 =>
                Multiplicand := 5;
                Multiplier := 3;
            when 1 =>
                Multiplicand := 0;
                Multiplier := 7;
            when 2 =>
                Multiplicand := 7;
                Multiplier := 0;
            when 3 =>
                Multiplicand := 9;
                Multiplier := 1;
            when others =>
                Multiplicand := 16;
                Multiplier := 16;
        end case;

        case to_integer(unsigned(Address)) is
            when 0 => return Movi(REG_SEL_R1, Multiplicand);
            when 1 => return Movi(REG_SEL_R2, Multiplier);
            when 2 => return RType(OPCODE_MUL, REG_SEL_R1, REG_SEL_R2);
            when 3 => return Jmp(3);
            when others => return Jmp(3);
        end case;
    end function;
begin
    Instruction_Bus <= Program_Instruction(Scenario, PC_Curr);

    PC: entity work.Program_Counter_7
        port map(
            Clk => Clk,
            Res => Reset,
            Inc => PC_Inc,
            Load => PC_Load,
            Load_Addr => PC_Target,
            Q => PC_Curr
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
            Next_Addr => Next_Addr_From_ROM,
            Micro_Src_Select => Micro_Src_Select,
            Micro_Dst_Select => Micro_Dst_Select,
            Micro_ALU_Mode => Micro_ALU_Mode
        );

    CU: entity work.Control_Unit
        port map(
            Clk => Clk,
            Res => Reset,
            Micro_Addr => Micro_Addr,
            UOp => UOp,
            Next_Mode => Next_Mode,
            Next_Addr_From_ROM => Next_Addr_From_ROM,
            Micro_Src_Select => Micro_Src_Select,
            Micro_Dst_Select => Micro_Dst_Select,
            Micro_ALU_Mode => Micro_ALU_Mode,
            Opcode => Opcode,
            Rd => Rd,
            Rs => Rs,
            Imm_Addr => Imm_Addr,
            Reg_Out => Reg_Out_Sel,
            ALU_Zero => Zero,
            Out_A => Out_A,
            Out_B => Out_B,
            Out_Add => Out_Add,
            Out_Reg => Out_Reg,
            Load_A => Load_A,
            Load_B => Load_B,
            ALU_Mode => ALU_Mode,
            Out_Select => Out_Select,
            Load_Select => Load_Select,
            Reg_Write => Reg_Write,
            Reg_Write_Data_Sel => Reg_Write_Data_Sel,
            PC_Inc => PC_Inc,
            PC_Load => PC_Load,
            PC_Target => PC_Target,
            Exec_Result => Exec_Result,
            Div_Zero => Div_Zero,
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

    ALU: entity work.ALU_8
        port map(
            A => RegA_Q,
            B => RegB_Q,
            ALU_Mode => ALU_Mode,
            S => ALU_Out,
            Overflow => Overflow,
            Zero => Zero
        );

    BusMux: entity work.Bus_Mux_4_to_1_8
        port map(
            A_in => RegA_Q,
            B_in => RegB_Q,
            Add_in => ALU_Out,
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

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Stim_Process: process
        procedure Run_Case(
            Case_Id : natural;
            Expected_Product : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
            Expected_Multiplicand : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
            Name : string
        ) is
        begin
            Scenario <= Case_Id;
            Reset <= '1';
            wait for 20 ns;
            wait until rising_edge(Clk);
            Reset <= '0';

            wait for 3 us;

            assert R1_Out = Expected_Product report Name & ": product mismatch" severity error;
            assert R4_Out = Expected_Multiplicand report Name & ": multiplicand scratch mismatch" severity error;
            assert R5_Out = x"00" report Name & ": multiplier scratch did not decrement to zero" severity error;
            assert R6_Out = Expected_Product report Name & ": product scratch mismatch" severity error;
            assert R3_Out = x"01" report Name & ": R3 constant-one scratch mismatch" severity error;
            assert R7_Out = x"01" report Name & ": final zero-compare scratch mismatch" severity error;
            assert Div_Zero = '0' report Name & ": MUL unexpectedly changed divide-by-zero flag" severity error;
            assert PC_Curr = STD_LOGIC_VECTOR(to_unsigned(3, ADDR_WIDTH)) report Name & ": PC did not reach halt loop" severity error;
        end procedure;
    begin
        Run_Case(0, x"0F", x"05", "normal multiplication");
        Run_Case(1, x"00", x"00", "zero multiplicand");
        Run_Case(2, x"00", x"07", "zero multiplier");
        Run_Case(3, x"09", x"09", "multiply by one");
        Run_Case(4, x"00", x"10", "8-bit wraparound");

        wait;
    end process;
end Behavioral;

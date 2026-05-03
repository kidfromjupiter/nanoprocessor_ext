library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Control_Unit is
    Port (
     -- clk/reset
        Clk                : in STD_LOGIC;
        Res                : in STD_LOGIC;
    -- from micropc, microcode_ROM
        Micro_Addr         : in STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0);
        UOp                : in STD_LOGIC_VECTOR (UOP_WIDTH - 1 downto 0);
        Next_Mode          : in STD_LOGIC_VECTOR (1 downto 0);
        Next_Addr_From_ROM : in STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0);
    -- from instruction decoder
        Opcode             : in STD_LOGIC_VECTOR (OPCODE_WIDTH - 1 downto 0);
        Rd                 : in STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Rs                 : in STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Imm_Addr           : in STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
    -- from add/sub and associated registers
        Reg_Out            : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        A_Value            : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        B_Value            : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    -- control signals to bus mux
        Out_A              : out STD_LOGIC;
        Out_B              : out STD_LOGIC;
        Out_Add            : out STD_LOGIC;
        Out_Reg            : out STD_LOGIC;
    -- control for A/B registers
        Load_A             : out STD_LOGIC;
        Load_B             : out STD_LOGIC;
    -- control for add/sub
        Add_Sub_Sel        : out STD_LOGIC;
    -- to reg bank
        Out_Select         : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Load_Select        : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Reg_Write          : out STD_LOGIC;
        Reg_Write_Data_Sel : out STD_LOGIC_VECTOR (1 downto 0);
    -- to pc
        PC_Inc             : out STD_LOGIC;
        PC_Load            : out STD_LOGIC;
        PC_Target          : out STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
    -- status
        Exec_Result        : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Div_Zero           : out STD_LOGIC;
    -- to micropc
        Micro_Next_Addr    : out STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0)
    );
end Control_Unit;

architecture Behavioral of Control_Unit is
    signal Mul_Acc          : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Mul_Multiplicand : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Mul_Count        : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Div_Remainder    : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Div_Divisor      : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Div_Quotient     : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Exec_Result_Reg  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal Iter_Done        : STD_LOGIC := '0';
    signal Div_Zero_Reg     : STD_LOGIC := '0';

    function Dispatch_Entry(Op : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0)) return STD_LOGIC_VECTOR is
    -- a function to map opcode to microcode start address
    begin
        case Op is
            when OPCODE_ADD  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_ADD, MICRO_ADDR_WIDTH));
            when OPCODE_SUB  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_SUB, MICRO_ADDR_WIDTH));
            when OPCODE_MOVI => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_MOVI, MICRO_ADDR_WIDTH));
            when OPCODE_JMP  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_JMP, MICRO_ADDR_WIDTH));
            when OPCODE_JZR  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_JZR, MICRO_ADDR_WIDTH));
            when OPCODE_JNZ  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_JNZ, MICRO_ADDR_WIDTH));
            when OPCODE_MUL  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_MUL, MICRO_ADDR_WIDTH));
            when OPCODE_DIV  => return STD_LOGIC_VECTOR(to_unsigned(ENTRY_DIV, MICRO_ADDR_WIDTH));
            when others      => return STD_LOGIC_VECTOR(to_unsigned(0, MICRO_ADDR_WIDTH));
        end case;
    end function;
begin
    process(all)
    -- control signals for micro-ops
    begin
        Out_A <= '0';
        Out_B <= '0';
        Out_Add <= '0';
        Out_Reg <= '0';
        Load_A <= '0';
        Load_B <= '0';
        Add_Sub_Sel <= '0';
        Out_Select <= Rd;
        Load_Select <= Rd;
        Reg_Write <= '0';
        Reg_Write_Data_Sel <= WRITE_DATA_BUS;
        PC_Inc <= '0';
        PC_Load <= '0';
        PC_Target <= Imm_Addr;

        case UOp is
            when UOP_LOAD_A_RD =>
                Out_Reg <= '1';
                Out_Select <= Rd;
                Load_A <= '1';

            when UOP_LOAD_B_RS =>
                Out_Reg <= '1';
                Out_Select <= Rs;
                Load_B <= '1';

            when UOP_WRITE_ADD_RD =>
                Out_Add <= '1';
                Add_Sub_Sel <= '0';
                Load_Select <= Rd;
                Reg_Write <= '1';
                Reg_Write_Data_Sel <= WRITE_DATA_BUS;
                PC_Inc <= '1';

            when UOP_WRITE_SUB_RD =>
                Out_Add <= '1';
                Add_Sub_Sel <= '1';
                Load_Select <= Rd;
                Reg_Write <= '1';
                Reg_Write_Data_Sel <= WRITE_DATA_BUS;
                PC_Inc <= '1';

            when UOP_WRITE_IMM_RD =>
                Load_Select <= Rd;
                Reg_Write <= '1';
                Reg_Write_Data_Sel <= WRITE_DATA_IMM;
                PC_Inc <= '1';

            when UOP_JMP_IMM =>
                PC_Load <= '1';
                PC_Target <= Imm_Addr;

            when UOP_JZR_RD =>
                Out_Select <= Rd;
                if Reg_Out = x"00" then
                    PC_Load <= '1';
                    PC_Target <= Imm_Addr;
                else
                    PC_Inc <= '1';
                end if;

            when UOP_JNZ_RD =>
                Out_Select <= Rd;
                if Reg_Out /= x"00" then
                    PC_Load <= '1';
                    PC_Target <= Imm_Addr;
                else
                    PC_Inc <= '1';
                end if;

            when UOP_WRITE_EXEC_RD =>
                Load_Select <= Rd;
                Reg_Write <= '1';
                Reg_Write_Data_Sel <= WRITE_DATA_EXEC;
                PC_Inc <= '1';

            when others =>
                null;
        end case;

        case Next_Mode is
            when NEXT_SEQ =>
                Micro_Next_Addr <= STD_LOGIC_VECTOR(unsigned(Micro_Addr) + 1);
            when NEXT_ABS =>
                Micro_Next_Addr <= Next_Addr_From_ROM;
            when NEXT_DISPATCH =>
                Micro_Next_Addr <= Dispatch_Entry(Opcode);
            when NEXT_WAITDONE =>
                if Iter_Done = '1' then
                    Micro_Next_Addr <= Next_Addr_From_ROM;
                else
                    Micro_Next_Addr <= Micro_Addr;
                end if;
            when others =>
                Micro_Next_Addr <= (others => '0');
        end case;
    end process;

    process(Clk, Res)
    begin
        -- reset pathway
        if Res = '1' then
            Mul_Acc <= (others => '0');
            Mul_Multiplicand <= (others => '0');
            Mul_Count <= (others => '0');
            Div_Remainder <= (others => '0');
            Div_Divisor <= (others => '0');
            Div_Quotient <= (others => '0');
            Exec_Result_Reg <= (others => '0');
            Iter_Done <= '0';
            Div_Zero_Reg <= '0';
        elsif rising_edge(Clk) then
            case UOp is
                -- sync division/ multiplication. these are sync because they depend on intermediate values from registers and register 
                -- values are updated on rising edge. The rest of the micro-ops are async since they're all combinational logic and control signals
                when UOP_START_MUL =>
                    Mul_Acc <= (others => '0');
                    Mul_Multiplicand <= unsigned(A_Value);
                    Mul_Count <= unsigned(B_Value);
                    Exec_Result_Reg <= (others => '0');
                    Iter_Done <= '0';

                when UOP_STEP_MUL =>
                    if Mul_Count = 0 then
                        Exec_Result_Reg <= STD_LOGIC_VECTOR(Mul_Acc);
                        Iter_Done <= '1';
                    else
                        Mul_Acc <= Mul_Acc + Mul_Multiplicand;
                        Mul_Count <= Mul_Count - 1;
                        Iter_Done <= '0';
                    end if;

                when UOP_START_DIV =>
                    if B_Value = x"00" then
                        Exec_Result_Reg <= (others => '0');
                        Div_Zero_Reg <= '1';
                        Iter_Done <= '1';
                    else
                        Div_Remainder <= unsigned(A_Value);
                        Div_Divisor <= unsigned(B_Value);
                        Div_Quotient <= (others => '0');
                        Div_Zero_Reg <= '0';
                        Iter_Done <= '0';
                    end if;

                when UOP_STEP_DIV =>
                    if Div_Zero_Reg = '1' then
                        Iter_Done <= '1';
                    elsif Div_Remainder >= Div_Divisor then
                        Div_Remainder <= Div_Remainder - Div_Divisor;
                        Div_Quotient <= Div_Quotient + 1;
                        Iter_Done <= '0';
                    else
                        Exec_Result_Reg <= STD_LOGIC_VECTOR(Div_Quotient);
                        Iter_Done <= '1';
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    Exec_Result <= Exec_Result_Reg;
    Div_Zero <= Div_Zero_Reg;
end Behavioral;

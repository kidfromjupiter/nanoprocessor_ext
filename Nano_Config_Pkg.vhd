library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Nano_Config_Pkg is
    constant DATA_WIDTH       : natural := 8;
    constant REG_COUNT        : natural := 8;
    constant REG_SEL_WIDTH    : natural := 3;
    constant ADDR_WIDTH       : natural := 7;
    constant INSTR_WIDTH      : natural := 16;
    constant OPCODE_WIDTH     : natural := 4;
    constant MICRO_ADDR_WIDTH : natural := 7;
    constant UOP_WIDTH        : natural := 5;
    constant NEXT_MODE_WIDTH  : natural := 3;
    constant ALU_MODE_WIDTH   : natural := 3;

    constant MICRO_WORD_WIDTH : natural := UOP_WIDTH + NEXT_MODE_WIDTH + MICRO_ADDR_WIDTH +
                                            REG_SEL_WIDTH + REG_SEL_WIDTH + ALU_MODE_WIDTH;

    constant OPCODE_ADD   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0000";
    constant OPCODE_MOVI  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0001";
    constant OPCODE_SUB   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0010";
    constant OPCODE_DIV   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0011";
    constant OPCODE_MUL   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0100";
    constant OPCODE_JMP   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0101";
    constant OPCODE_JZR   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0110";
    constant OPCODE_JNZ   : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "0111";
    constant OPCODE_CMPEQ : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "1000";
    constant OPCODE_CMPLT : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "1001";
    constant OPCODE_CMPGT : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "1010";

    constant ALU_MODE_ADD   : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := "000";
    constant ALU_MODE_SUB   : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := "001";
    constant ALU_MODE_CMPEQ : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := "010";
    constant ALU_MODE_CMPLT : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := "011";
    constant ALU_MODE_CMPGT : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := "100";

    constant REG_SEL_R0 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "000";
    constant REG_SEL_R1 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "001";
    constant REG_SEL_R2 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "010";
    constant REG_SEL_R3 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "011";
    constant REG_SEL_R4 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "100";
    constant REG_SEL_R5 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "101";
    constant REG_SEL_R6 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "110";
    constant REG_SEL_R7 : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0) := "111";

    constant NEXT_SEQ        : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0) := "000";
    constant NEXT_ABS        : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0) := "001";
    constant NEXT_DISPATCH   : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0) := "010";
    constant NEXT_IF_ZERO    : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0) := "100";
    constant NEXT_IF_NONZERO : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0) := "101";

    constant UOP_NOP           : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00000";
    constant UOP_LOAD_A_RD     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00001";
    constant UOP_LOAD_B_RS     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00010";
    constant UOP_WRITE_ADD_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00011";
    constant UOP_WRITE_SUB_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00100";
    constant UOP_WRITE_IMM_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00101";
    constant UOP_JMP_IMM       : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00110";
    constant UOP_JZR_RD        : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00111";
    constant UOP_JNZ_RD        : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01000";
    constant UOP_WRITE_ALU_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01001";
    constant UOP_LOAD_A_MICRO_SRC      : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01010";
    constant UOP_LOAD_B_MICRO_SRC      : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01011";
    constant UOP_WRITE_ALU_MICRO_DST   : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01100";
    constant UOP_WRITE_IMM_MICRO_DST   : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01101";
    constant UOP_CLEAR_DIV_ZERO        : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01110";
    constant UOP_SET_DIV_ZERO          : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01111";

    constant ENTRY_ADD  : natural := 4;
    constant ENTRY_SUB  : natural := 8;
    constant ENTRY_MOVI : natural := 12;
    constant ENTRY_JMP  : natural := 14;
    constant ENTRY_JZR  : natural := 16;
    constant ENTRY_JNZ  : natural := 18;
    constant ENTRY_MUL  : natural := 20;
    constant ENTRY_DIV  : natural := 40;
    constant ENTRY_CMP  : natural := 68;

    constant WRITE_DATA_BUS  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant WRITE_DATA_IMM  : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant WRITE_DATA_EXEC : STD_LOGIC_VECTOR(1 downto 0) := "10";
end package;

package body Nano_Config_Pkg is
end package body;

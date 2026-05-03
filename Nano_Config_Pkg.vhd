library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Nano_Config_Pkg is
    constant DATA_WIDTH       : natural := 8;
    constant REG_COUNT        : natural := 8;
    constant REG_SEL_WIDTH    : natural := 3;
    constant ADDR_WIDTH       : natural := 7;
    constant INSTR_WIDTH      : natural := 16;
    constant OPCODE_WIDTH     : natural := 3;
    constant MICRO_ADDR_WIDTH : natural := 6;
    constant UOP_WIDTH        : natural := 5;

    constant MICRO_WORD_WIDTH : natural := UOP_WIDTH + 2 + MICRO_ADDR_WIDTH;

    constant OPCODE_ADD  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "000";
    constant OPCODE_MOVI : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "001";
    constant OPCODE_SUB  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "010";
    constant OPCODE_DIV  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "011";
    constant OPCODE_MUL  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "100";
    constant OPCODE_JMP  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "101";
    constant OPCODE_JZR  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "110";
    constant OPCODE_JNZ  : STD_LOGIC_VECTOR(OPCODE_WIDTH - 1 downto 0) := "111";

    constant NEXT_SEQ      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant NEXT_ABS      : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant NEXT_DISPATCH : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant NEXT_WAITDONE : STD_LOGIC_VECTOR(1 downto 0) := "11";

    constant UOP_NOP           : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00000";
    constant UOP_LOAD_A_RD     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00001";
    constant UOP_LOAD_B_RS     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00010";
    constant UOP_WRITE_ADD_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00011";
    constant UOP_WRITE_SUB_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00100";
    constant UOP_WRITE_IMM_RD  : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00101";
    constant UOP_JMP_IMM       : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00110";
    constant UOP_JZR_RD        : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "00111";
    constant UOP_JNZ_RD        : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01000";
    constant UOP_START_MUL     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01001";
    constant UOP_STEP_MUL      : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01010";
    constant UOP_START_DIV     : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01011";
    constant UOP_STEP_DIV      : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01100";
    constant UOP_WRITE_EXEC_RD : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0) := "01101";

    constant ENTRY_ADD  : natural := 4;
    constant ENTRY_SUB  : natural := 8;
    constant ENTRY_MOVI : natural := 12;
    constant ENTRY_JMP  : natural := 14;
    constant ENTRY_JZR  : natural := 16;
    constant ENTRY_JNZ  : natural := 18;
    constant ENTRY_MUL  : natural := 20;
    constant ENTRY_DIV  : natural := 28;

    constant WRITE_DATA_BUS  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant WRITE_DATA_IMM  : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant WRITE_DATA_EXEC : STD_LOGIC_VECTOR(1 downto 0) := "10";
end package;

package body Nano_Config_Pkg is
end package body;

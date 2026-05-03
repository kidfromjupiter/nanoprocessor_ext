library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Microcode_ROM is
    Port (
    -- from micropc
        UAddr     : in STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0);
    -- to control_unit
        UOp       : out STD_LOGIC_VECTOR (UOP_WIDTH - 1 downto 0);
        Next_Mode : out STD_LOGIC_VECTOR (1 downto 0);
        Next_Addr : out STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0)
    );
end Microcode_ROM;

architecture Behavioral of Microcode_ROM is
    function Enc(
        OpCodeVal : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0);
        ModeVal   : STD_LOGIC_VECTOR(1 downto 0);
        AddrVal   : natural
    ) return STD_LOGIC_VECTOR is
    begin
        return OpCodeVal & ModeVal & STD_LOGIC_VECTOR(to_unsigned(AddrVal, MICRO_ADDR_WIDTH));
    end function;

    type micro_rom_t is array (0 to (2 ** MICRO_ADDR_WIDTH) - 1) of STD_LOGIC_VECTOR(MICRO_WORD_WIDTH - 1 downto 0);
    constant ROM : micro_rom_t := (
        0  => Enc(UOP_NOP, NEXT_DISPATCH, 0),

        4  => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        5  => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        6  => Enc(UOP_WRITE_ADD_RD, NEXT_ABS, 0),

        8  => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        9  => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        10 => Enc(UOP_WRITE_SUB_RD, NEXT_ABS, 0),

        12 => Enc(UOP_WRITE_IMM_RD, NEXT_ABS, 0),
        14 => Enc(UOP_JMP_IMM, NEXT_ABS, 0),
        16 => Enc(UOP_JZR_RD, NEXT_ABS, 0),
        18 => Enc(UOP_JNZ_RD, NEXT_ABS, 0),

        20 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        21 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        22 => Enc(UOP_START_MUL, NEXT_SEQ, 0),
        23 => Enc(UOP_STEP_MUL, NEXT_WAITDONE, 24),
        24 => Enc(UOP_WRITE_EXEC_RD, NEXT_ABS, 0),

        28 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        29 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        30 => Enc(UOP_START_DIV, NEXT_SEQ, 0),
        31 => Enc(UOP_STEP_DIV, NEXT_WAITDONE, 32),
        32 => Enc(UOP_WRITE_EXEC_RD, NEXT_ABS, 0),

        others => Enc(UOP_NOP, NEXT_ABS, 0)
    );

    signal Word : STD_LOGIC_VECTOR(MICRO_WORD_WIDTH - 1 downto 0);
begin
    Word <= ROM(to_integer(unsigned(UAddr)));

    UOp <= Word(MICRO_WORD_WIDTH - 1 downto MICRO_WORD_WIDTH - UOP_WIDTH);
    Next_Mode <= Word(MICRO_ADDR_WIDTH + 1 downto MICRO_ADDR_WIDTH);
    Next_Addr <= Word(MICRO_ADDR_WIDTH - 1 downto 0);
end Behavioral;

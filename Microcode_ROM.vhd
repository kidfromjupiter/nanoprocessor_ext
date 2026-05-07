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
        Next_Mode : out STD_LOGIC_VECTOR (NEXT_MODE_WIDTH - 1 downto 0);
        Next_Addr : out STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0);
        Micro_Src_Select : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Micro_Dst_Select : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Micro_ALU_Mode   : out STD_LOGIC_VECTOR (ALU_MODE_WIDTH - 1 downto 0)
    );
end Microcode_ROM;

architecture Behavioral of Microcode_ROM is
    function Enc(
        OpCodeVal : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0);
        ModeVal   : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0);
        AddrVal   : natural;
        SrcVal    : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
        DstVal    : STD_LOGIC_VECTOR(REG_SEL_WIDTH - 1 downto 0);
        ALUVal    : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        return OpCodeVal & ModeVal & STD_LOGIC_VECTOR(to_unsigned(AddrVal, MICRO_ADDR_WIDTH)) &
               SrcVal & DstVal & ALUVal;
    end function;

    function Enc(
        OpCodeVal : STD_LOGIC_VECTOR(UOP_WIDTH - 1 downto 0);
        ModeVal   : STD_LOGIC_VECTOR(NEXT_MODE_WIDTH - 1 downto 0);
        AddrVal   : natural
    ) return STD_LOGIC_VECTOR is
    begin
        return Enc(OpCodeVal, ModeVal, AddrVal, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD);
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
        21 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        22 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R4, ALU_MODE_ADD),
        23 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        24 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        25 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R5, ALU_MODE_ADD),
        26 => Enc(UOP_WRITE_IMM_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R6, ALU_MODE_ADD),
        27 => Enc(UOP_WRITE_IMM_MICRO_DST, NEXT_SEQ, 1, REG_SEL_R0, REG_SEL_R3, ALU_MODE_ADD),
        28 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R5, REG_SEL_R0, ALU_MODE_ADD),
        29 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        30 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_IF_NONZERO, 37, REG_SEL_R0, REG_SEL_R7, ALU_MODE_CMPEQ),
        31 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R6, REG_SEL_R0, ALU_MODE_ADD),
        32 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R4, REG_SEL_R0, ALU_MODE_ADD),
        33 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R6, ALU_MODE_ADD),
        34 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R5, REG_SEL_R0, ALU_MODE_ADD),
        35 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R3, REG_SEL_R0, ALU_MODE_ADD),
        36 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_ABS, 28, REG_SEL_R0, REG_SEL_R5, ALU_MODE_SUB),
        37 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R6, REG_SEL_R0, ALU_MODE_ADD),
        38 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        39 => Enc(UOP_WRITE_ALU_RD, NEXT_ABS, 0),

        40 => Enc(UOP_CLEAR_DIV_ZERO, NEXT_SEQ, 0),
        41 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        42 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        43 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R4, ALU_MODE_ADD),
        44 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        45 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        46 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R5, ALU_MODE_ADD),
        47 => Enc(UOP_WRITE_IMM_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R6, ALU_MODE_ADD),
        48 => Enc(UOP_WRITE_IMM_MICRO_DST, NEXT_SEQ, 1, REG_SEL_R0, REG_SEL_R3, ALU_MODE_ADD),
        49 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R5, REG_SEL_R0, ALU_MODE_ADD),
        50 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        51 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_IF_NONZERO, 64, REG_SEL_R0, REG_SEL_R7, ALU_MODE_CMPEQ),

        52 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R4, REG_SEL_R0, ALU_MODE_ADD),
        53 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R5, REG_SEL_R0, ALU_MODE_ADD),
        54 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_IF_NONZERO, 61, REG_SEL_R0, REG_SEL_R7, ALU_MODE_CMPLT),
        55 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R4, REG_SEL_R0, ALU_MODE_ADD),
        56 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R5, REG_SEL_R0, ALU_MODE_ADD),
        57 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R4, ALU_MODE_SUB),
        58 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R6, REG_SEL_R0, ALU_MODE_ADD),
        59 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R3, REG_SEL_R0, ALU_MODE_ADD),
        60 => Enc(UOP_WRITE_ALU_MICRO_DST, NEXT_ABS, 52, REG_SEL_R0, REG_SEL_R6, ALU_MODE_ADD),

        61 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R6, REG_SEL_R0, ALU_MODE_ADD),
        62 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        63 => Enc(UOP_WRITE_ALU_RD, NEXT_ABS, 0),

        64 => Enc(UOP_SET_DIV_ZERO, NEXT_SEQ, 0),
        65 => Enc(UOP_LOAD_A_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        66 => Enc(UOP_LOAD_B_MICRO_SRC, NEXT_SEQ, 0, REG_SEL_R0, REG_SEL_R0, ALU_MODE_ADD),
        67 => Enc(UOP_WRITE_ALU_RD, NEXT_ABS, 0),

        68 => Enc(UOP_LOAD_A_RD, NEXT_SEQ, 0),
        69 => Enc(UOP_LOAD_B_RS, NEXT_SEQ, 0),
        70 => Enc(UOP_WRITE_ALU_RD, NEXT_ABS, 0),

        others => Enc(UOP_NOP, NEXT_ABS, 0)
    );

    signal Word : STD_LOGIC_VECTOR(MICRO_WORD_WIDTH - 1 downto 0);
begin
    Word <= ROM(to_integer(unsigned(UAddr)));

    UOp <= Word(MICRO_WORD_WIDTH - 1 downto MICRO_WORD_WIDTH - UOP_WIDTH);
    Next_Mode <= Word(MICRO_WORD_WIDTH - UOP_WIDTH - 1 downto
                      MICRO_WORD_WIDTH - UOP_WIDTH - NEXT_MODE_WIDTH);
    Next_Addr <= Word(ALU_MODE_WIDTH + (2 * REG_SEL_WIDTH) + MICRO_ADDR_WIDTH - 1 downto
                      ALU_MODE_WIDTH + (2 * REG_SEL_WIDTH));
    Micro_Src_Select <= Word(ALU_MODE_WIDTH + (2 * REG_SEL_WIDTH) - 1 downto
                             ALU_MODE_WIDTH + REG_SEL_WIDTH);
    Micro_Dst_Select <= Word(ALU_MODE_WIDTH + REG_SEL_WIDTH - 1 downto ALU_MODE_WIDTH);
    Micro_ALU_Mode <= Word(ALU_MODE_WIDTH - 1 downto 0);
end Behavioral;

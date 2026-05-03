library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Program_ROM_16 is
    Port (
    -- from program_counter_7
        Address : in STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
    -- to instruction_decoder_16
        Data    : out STD_LOGIC_VECTOR (INSTR_WIDTH - 1 downto 0)
    );
end Program_ROM_16;

architecture Behavioral of Program_ROM_16 is
    type rom_t is array (0 to (2 ** ADDR_WIDTH) - 1) of STD_LOGIC_VECTOR(INSTR_WIDTH - 1 downto 0);
    constant ROM : rom_t := (
        0  => "0010010000000101", -- MOVI R1, 5
        1  => "0010100000000011", -- MOVI R2, 3
        2  => "0000010100000000", -- ADD  R1, R2
        3  => "0100010100000000", -- SUB  R1, R2
        4  => "1000010100000000", -- MUL  R1, R2
        5  => "0110010100000000", -- DIV  R1, R2
        6  => "1100000000001000", -- JZR  R0, 8
        7  => "0010110000000001", -- MOVI R3, 1 (skipped)
        8  => "1110010000001010", -- JNZ  R1, 10
        9  => "0011000000000001", -- MOVI R4, 1 (skipped)
        10 => "1010000000001010", -- JMP  10
        others => (others => '0')
    );
begin
    Data <= ROM(to_integer(unsigned(Address)));
end Behavioral;

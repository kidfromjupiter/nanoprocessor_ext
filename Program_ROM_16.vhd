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
        0  => "0001001000000101", -- MOVI R1, 5
        1  => "0001010000000011", -- MOVI R2, 3
        2  => "0001101000000101", -- MOVI R5, 5
        3  => "0001110000000101", -- MOVI R6, 5
        4  => "1000101110000000", -- CMPEQ R5, R6
        5  => "0001101000000011", -- MOVI R5, 3
        6  => "1001101001000000", -- CMPLT R5, R1
        7  => "0001110000000101", -- MOVI R6, 5
        8  => "1010110010000000", -- CMPGT R6, R2
        9  => "0000001010000000", -- ADD  R1, R2
        10 => "0010001010000000", -- SUB  R1, R2
        11 => "0100001010000000", -- MUL  R1, R2
        12 => "0011001010000000", -- DIV  R1, R2
        13 => "0110000000001111", -- JZR  R0, 15
        14 => "0001011000000001", -- MOVI R3, 1 (skipped)
        15 => "0111001000010001", -- JNZ  R1, 17
        16 => "0001100000000001", -- MOVI R4, 1 (skipped)
        17 => "0101000000010001", -- JMP  17
        others => (others => '0')
    );
begin
    Data <= ROM(to_integer(unsigned(Address)));
end Behavioral;

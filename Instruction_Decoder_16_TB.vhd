library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Instruction_Decoder_16_TB is
end Instruction_Decoder_16_TB;

architecture Behavioral of Instruction_Decoder_16_TB is
    signal Instruction : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal Opcode : STD_LOGIC_VECTOR(2 downto 0);
    signal Rd, Rs : STD_LOGIC_VECTOR(2 downto 0);
    signal Imm_Addr : STD_LOGIC_VECTOR(6 downto 0);
    signal Imm8 : STD_LOGIC_VECTOR(7 downto 0);
begin
    UUT: entity work.Instruction_Decoder_16
        port map(
            Instruction => Instruction,
            Opcode => Opcode,
            Rd => Rd,
            Rs => Rs,
            Imm_Addr => Imm_Addr,
            Imm8 => Imm8
        );

    process
    begin
        Instruction <= "0010010000000101"; wait for 10 ns; -- MOVI R1,5
        assert Opcode = "001" and Rd = "001" and Rs = "000" and Imm_Addr = "0000101" and Imm8 = "00000101"
            report "Decoder MOVI case failed" severity error;

        Instruction <= "0000010100000000"; wait for 10 ns; -- ADD R1,R2
        assert Opcode = "000" and Rd = "001" and Rs = "010"
            report "Decoder ADD case failed" severity error;

        Instruction <= "1110010000001010"; wait for 10 ns; -- JNZ R1,10
        assert Opcode = "111" and Rd = "001" and Imm_Addr = "0001010"
            report "Decoder JNZ case failed" severity error;

        wait;
    end process;
end Behavioral;

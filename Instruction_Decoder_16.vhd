library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity Instruction_Decoder_16 is
    Port (
    -- from program_ROM_16
        Instruction : in STD_LOGIC_VECTOR (INSTR_WIDTH - 1 downto 0);
    -- to control_unit
        Opcode      : out STD_LOGIC_VECTOR (OPCODE_WIDTH - 1 downto 0);
        Rd          : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Rs          : out STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Imm_Addr    : out STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
    -- to immediate mux (register write data)
        Imm8        : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Instruction_Decoder_16;

architecture Behavioral of Instruction_Decoder_16 is
begin
    Opcode   <= Instruction(15 downto 13);
    Rd       <= Instruction(12 downto 10);
    Rs       <= Instruction(9 downto 7);
    Imm_Addr <= Instruction(6 downto 0);
    Imm8     <= '0' & Instruction(6 downto 0);
end Behavioral;

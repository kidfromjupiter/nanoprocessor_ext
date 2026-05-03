library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity MicroPC is
    Port (
    -- clk/reset
        Clk       : in STD_LOGIC;
        Res       : in STD_LOGIC;
    -- from control_unit (sequencing control)
        Next_Addr : in STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0);
    -- to microcode_ROM
        Addr_Out  : out STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0)
    );
end MicroPC;

architecture Behavioral of MicroPC is
    signal PC_Reg : STD_LOGIC_VECTOR (MICRO_ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
    process(Clk, Res)
    begin
        if Res = '1' then
            PC_Reg <= (others => '0');
        elsif rising_edge(Clk) then
            PC_Reg <= Next_Addr;
        end if;
    end process;

    Addr_Out <= PC_Reg;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Program_Counter_7 is
    Port (
    -- clk/reset
        Clk       : in STD_LOGIC;
        Res       : in STD_LOGIC;
    -- from control_unit
        Inc       : in STD_LOGIC;
        Load      : in STD_LOGIC;
        Load_Addr : in STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0);
    -- to program_ROM
        Q         : out STD_LOGIC_VECTOR (ADDR_WIDTH - 1 downto 0)
    );
end Program_Counter_7;

architecture Behavioral of Program_Counter_7 is
    signal PC_Reg : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
    process(Clk, Res)
    begin
        if Res = '1' then
            PC_Reg <= (others => '0');
        elsif rising_edge(Clk) then
            if Load = '1' then
                PC_Reg <= unsigned(Load_Addr);
            elsif Inc = '1' then
                PC_Reg <= PC_Reg + 1;
            end if;
        end if;
    end process;

    Q <= STD_LOGIC_VECTOR(PC_Reg);
end Behavioral;

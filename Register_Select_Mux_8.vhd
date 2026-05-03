library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity Register_Select_Mux_8 is
    Port (
        Sw_Select : in STD_LOGIC_VECTOR(REG_COUNT - 1 downto 0);
        R0        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R1        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R2        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R3        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R4        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R5        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R6        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        R7        : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        Y         : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
    );
end Register_Select_Mux_8;

architecture Behavioral of Register_Select_Mux_8 is
begin
    process(all)
    begin
        -- Lowest-numbered active switch has priority; no active switch displays R0.
        if Sw_Select(0) = '1' then
            Y <= R0;
        elsif Sw_Select(1) = '1' then
            Y <= R1;
        elsif Sw_Select(2) = '1' then
            Y <= R2;
        elsif Sw_Select(3) = '1' then
            Y <= R3;
        elsif Sw_Select(4) = '1' then
            Y <= R4;
        elsif Sw_Select(5) = '1' then
            Y <= R5;
        elsif Sw_Select(6) = '1' then
            Y <= R6;
        elsif Sw_Select(7) = '1' then
            Y <= R7;
        else
            Y <= R0;
        end if;
    end process;
end Behavioral;

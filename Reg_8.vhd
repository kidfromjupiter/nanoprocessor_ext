library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_8 is
    Port (
    -- from central_bus or external source
        D   : in STD_LOGIC_VECTOR (7 downto 0);
    -- from control_unit
        En  : in STD_LOGIC;
    -- clk/reset
        Clk : in STD_LOGIC;
        Res : in STD_LOGIC;
    -- to add_sub_8 and bus_mux_4_to_1_8
        Q   : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Reg_8;

architecture Behavioral of Reg_8 is
    signal Q_reg : STD_LOGIC_VECTOR (7 downto 0);
begin
    process (Clk, Res)
    begin
        if (Res = '1') then
            Q_reg <= (others => '0');
        elsif rising_edge(Clk) then
            if (En = '1') then
                Q_reg <= D;
            end if;
        end if;
    end process;

    Q <= Q_reg;
end Behavioral;

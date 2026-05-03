library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_Select_Mux_8_TB is
end Register_Select_Mux_8_TB;

architecture Behavioral of Register_Select_Mux_8_TB is
    signal Sw_Select : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Y         : STD_LOGIC_VECTOR(7 downto 0);
begin
    UUT: entity work.Register_Select_Mux_8
        port map(
            Sw_Select => Sw_Select,
            R0 => x"00",
            R1 => x"11",
            R2 => x"22",
            R3 => x"33",
            R4 => x"44",
            R5 => x"55",
            R6 => x"66",
            R7 => x"77",
            Y => Y
        );

    process
    begin
        Sw_Select <= "00000000"; wait for 10 ns;
        assert Y = x"00" report "No switch should default to R0" severity error;

        Sw_Select <= "00000001"; wait for 10 ns;
        assert Y = x"00" report "SW0 should select R0" severity error;

        Sw_Select <= "00000100"; wait for 10 ns;
        assert Y = x"22" report "SW2 should select R2" severity error;

        Sw_Select <= "10000000"; wait for 10 ns;
        assert Y = x"77" report "SW7 should select R7" severity error;

        Sw_Select <= "10101000"; wait for 10 ns;
        assert Y = x"33" report "Lowest active switch should have priority" severity error;

        wait;
    end process;
end Behavioral;

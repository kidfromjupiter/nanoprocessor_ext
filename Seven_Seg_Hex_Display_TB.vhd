library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seven_Seg_Hex_Display_TB is
end Seven_Seg_Hex_Display_TB;

architecture Behavioral of Seven_Seg_Hex_Display_TB is
    signal Clk     : STD_LOGIC := '0';
    signal Res     : STD_LOGIC := '1';
    signal Value   : STD_LOGIC_VECTOR(7 downto 0) := x"AF";
    signal Seg_Out : STD_LOGIC_VECTOR(6 downto 0);
    signal Anode   : STD_LOGIC_VECTOR(3 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.Seven_Seg_Hex_Display
        generic map(
            REFRESH_BITS => 2
        )
        port map(
            Clk => Clk,
            Res => Res,
            Value => Value,
            Seg_Out => Seg_Out,
            Anode => Anode
        );

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    process
    begin
        wait for 2 ns;
        Res <= '0';
        wait for 1 ns;
        assert Anode = "1110" report "Rightmost digit should be active first" severity error;
        assert Seg_Out = "0001110" report "Low nibble F segment pattern failed" severity error;

        wait until rising_edge(Clk); wait for 1 ns;
        assert Anode = "1101" report "Second digit should be active second" severity error;
        assert Seg_Out = "0001000" report "High nibble A segment pattern failed" severity error;

        wait until rising_edge(Clk); wait for 1 ns;
        assert Anode = "1111" report "Unused display digit should be disabled" severity error;
        assert Seg_Out = "1111111" report "Segments should be off when digit disabled" severity error;

        Value <= x"25";
        wait until rising_edge(Clk);
        wait until rising_edge(Clk); wait for 1 ns;
        assert Anode = "1110" report "Refresh should return to rightmost digit" severity error;
        assert Seg_Out = "0010010" report "Low nibble 5 segment pattern failed" severity error;

        wait until rising_edge(Clk); wait for 1 ns;
        assert Anode = "1101" report "Second digit should show high nibble" severity error;
        assert Seg_Out = "0100100" report "High nibble 2 segment pattern failed" severity error;

        wait;
    end process;
end Behavioral;

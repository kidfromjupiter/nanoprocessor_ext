library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Nanoprocessor_Ext_TB is
end Nanoprocessor_Ext_TB;

architecture Behavioral of Nanoprocessor_Ext_TB is
    signal Clk, Reset : STD_LOGIC := '0';
    signal Overflow, Zero, Div_Zero : STD_LOGIC;
    signal PC_Out : STD_LOGIC_VECTOR(6 downto 0);
    signal R0_Out, R1_Out, R2_Out, R3_Out, R4_Out, R5_Out, R6_Out, R7_Out : STD_LOGIC_VECTOR(7 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.Nanoprocessor_Ext
        port map(
            Clk => Clk,
            Reset => Reset,
            Overflow => Overflow,
            Zero => Zero,
            Div_Zero => Div_Zero,
            PC_Out => PC_Out,
            R0_Out => R0_Out,
            R1_Out => R1_Out,
            R2_Out => R2_Out,
            R3_Out => R3_Out,
            R4_Out => R4_Out,
            R5_Out => R5_Out,
            R6_Out => R6_Out,
            R7_Out => R7_Out
        );

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Stim_Process: process
    begin
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';

        wait for 3 us;

        assert R0_Out = x"00" report "R0 constant zero violated" severity error;
        assert R1_Out = x"05" report "Final R1 value mismatch" severity error;
        assert R2_Out = x"03" report "Final R2 value mismatch" severity error;
        assert R3_Out = x"00" report "JZR did not skip instruction at address 14" severity error;
        assert R4_Out = x"00" report "JNZ did not skip instruction at address 16" severity error;
        assert R5_Out = x"01" report "CMPLT did not write true boolean result" severity error;
        assert R6_Out = x"01" report "CMPGT did not write true boolean result" severity error;
        assert Div_Zero = '0' report "Unexpected divide-by-zero flag" severity error;
        assert PC_Out = "0010001" report "Final PC expected at jump loop address 17" severity error;

        wait;
    end process;
end Behavioral;

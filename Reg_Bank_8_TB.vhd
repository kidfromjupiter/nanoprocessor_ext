library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_Bank_8_TB is
end Reg_Bank_8_TB;

architecture Behavioral of Reg_Bank_8_TB is
    signal Data_in, Reg_Out : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Out_Select, Load_Select : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal Reg_Write, Clk, Res : STD_LOGIC := '0';
    signal R0, R1, R2, R3, R4, R5, R6, R7 : STD_LOGIC_VECTOR(7 downto 0);
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.Reg_Bank_8
        port map(
            Data_in => Data_in,
            Out_Select => Out_Select,
            Load_Select => Load_Select,
            Reg_Write => Reg_Write,
            Clk => Clk,
            Res => Res,
            Reg_Out => Reg_Out,
            R0 => R0, R1 => R1, R2 => R2, R3 => R3, R4 => R4, R5 => R5, R6 => R6, R7 => R7
        );

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Stim_Process: process
    begin
        Res <= '1'; Reg_Write <= '0'; wait for 12 ns;
        assert R0 = x"00" and R1 = x"00" and R2 = x"00" report "Reg_Bank_8 reset failed" severity error;

        Res <= '0';
        Data_in <= x"AA"; Load_Select <= "001"; Reg_Write <= '1';
        wait until rising_edge(Clk); wait for 1 ns;
        assert R1 = x"AA" report "Reg_Bank_8 write R1 failed" severity error;

        Data_in <= x"FF"; Load_Select <= "000"; Reg_Write <= '1';
        wait until rising_edge(Clk); wait for 1 ns;
        assert R0 = x"00" report "Reg_Bank_8 R0 should remain zero" severity error;

        Data_in <= x"55"; Load_Select <= "010"; Reg_Write <= '1';
        wait until rising_edge(Clk); wait for 1 ns;
        assert R2 = x"55" report "Reg_Bank_8 write R2 failed" severity error;

        Reg_Write <= '0';
        Out_Select <= "001"; wait for 1 ns;
        assert Reg_Out = x"AA" report "Reg_Bank_8 read R1 failed" severity error;

        Out_Select <= "010"; wait for 1 ns;
        assert Reg_Out = x"55" report "Reg_Bank_8 read R2 failed" severity error;

        wait;
    end process;
end Behavioral;

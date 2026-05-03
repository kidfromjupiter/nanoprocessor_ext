library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Program_Counter_7_TB is
end Program_Counter_7_TB;

architecture Behavioral of Program_Counter_7_TB is
    signal Clk, Res, Inc, Load : STD_LOGIC := '0';
    signal Load_Addr, Q : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.Program_Counter_7
        port map(
            Clk => Clk,
            Res => Res,
            Inc => Inc,
            Load => Load,
            Load_Addr => Load_Addr,
            Q => Q
        );

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Stim_Process: process
    begin
        Res <= '1'; Inc <= '0'; Load <= '0'; wait for 12 ns;
        assert Q = "0000000" report "PC reset failed" severity error;

        Res <= '0'; Inc <= '1'; wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "0000001" report "PC increment 1 failed" severity error;

        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "0000010" report "PC increment 2 failed" severity error;

        Inc <= '0'; Load <= '1'; Load_Addr <= "0001010";
        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "0001010" report "PC load failed" severity error;

        Load <= '0'; Inc <= '1';
        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "0001011" report "PC increment after load failed" severity error;

        wait;
    end process;
end Behavioral;

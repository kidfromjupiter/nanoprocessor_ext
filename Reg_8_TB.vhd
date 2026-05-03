library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_8_TB is
end Reg_8_TB;

architecture Behavioral of Reg_8_TB is
    component Reg_8
        Port (
            D   : in STD_LOGIC_VECTOR (7 downto 0);
            En  : in STD_LOGIC;
            Clk : in STD_LOGIC;
            Res : in STD_LOGIC;
            Q   : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal D, Q : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal En, Clk, Res : STD_LOGIC := '0';
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: Reg_8 port map (D => D, En => En, Clk => Clk, Res => Res, Q => Q);

    Clk_Process: process
    begin
        Clk <= '0'; wait for CLK_PERIOD / 2;
        Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Stim_Process: process
    begin
        Res <= '1'; En <= '0'; D <= (others => '0');
        wait for 12 ns;
        assert Q = "00000000" report "Reg_8 reset failed" severity error;

        Res <= '0'; En <= '1'; D <= "10101010";
        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "10101010" report "Reg_8 write-on-enable failed" severity error;

        En <= '0'; D <= "01010101";
        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "10101010" report "Reg_8 hold-on-disable failed" severity error;

        En <= '1'; D <= "00110011";
        wait until rising_edge(Clk); wait for 1 ns;
        assert Q = "00110011" report "Reg_8 second write failed" severity error;

        Res <= '1'; wait for 1 ns;
        assert Q = "00000000" report "Reg_8 async reset failed" severity error;

        wait;
    end process;
end Behavioral;

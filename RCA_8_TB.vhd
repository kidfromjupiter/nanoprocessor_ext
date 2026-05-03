library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RCA_8_TB is
end RCA_8_TB;

architecture Behavioral of RCA_8_TB is
    component RCA_8
        Port (
            A     : in STD_LOGIC_VECTOR (7 downto 0);
            B     : in STD_LOGIC_VECTOR (7 downto 0);
            C_in  : in STD_LOGIC;
            S     : out STD_LOGIC_VECTOR (7 downto 0);
            C_out : out STD_LOGIC
        );
    end component;

    signal A, B, S : STD_LOGIC_VECTOR(7 downto 0);
    signal C_in, C_out : STD_LOGIC;
begin
    UUT: RCA_8 port map (A => A, B => B, C_in => C_in, S => S, C_out => C_out);

    process
    begin
        A <= "00000011"; B <= "00000010"; C_in <= '0'; wait for 10 ns;
        assert (S = "00000101" and C_out = '0') report "RCA_8 case1 failed" severity error;

        A <= "11111111"; B <= "00000001"; C_in <= '0'; wait for 10 ns;
        assert (S = "00000000" and C_out = '1') report "RCA_8 case2 failed" severity error;

        A <= "10101010"; B <= "01010101"; C_in <= '1'; wait for 10 ns;
        assert (S = "00000000" and C_out = '1') report "RCA_8 case3 failed" severity error;

        wait;
    end process;
end Behavioral;

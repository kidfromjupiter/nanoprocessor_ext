library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Add_Sub_8_TB is
end Add_Sub_8_TB;

architecture Behavioral of Add_Sub_8_TB is
    component Add_Sub_8
        Port (
            A           : in STD_LOGIC_VECTOR (7 downto 0);
            B           : in STD_LOGIC_VECTOR (7 downto 0);
            Add_Sub_Sel : in STD_LOGIC;
            S           : out STD_LOGIC_VECTOR (7 downto 0);
            Overflow    : out STD_LOGIC;
            Zero        : out STD_LOGIC
        );
    end component;

    signal A, B, S : STD_LOGIC_VECTOR(7 downto 0);
    signal Add_Sub_Sel, Overflow, Zero : STD_LOGIC;
begin
    UUT: Add_Sub_8 port map (
        A => A,
        B => B,
        Add_Sub_Sel => Add_Sub_Sel,
        S => S,
        Overflow => Overflow,
        Zero => Zero
    );

    process
    begin
        A <= "00000011"; B <= "00000010"; Add_Sub_Sel <= '0'; wait for 10 ns;
        assert (S = "00000101" and Overflow = '0' and Zero = '0') report "Add_Sub_8 add case failed" severity error;

        A <= "00000101"; B <= "00000011"; Add_Sub_Sel <= '1'; wait for 10 ns;
        assert (S = "00000010" and Overflow = '1' and Zero = '0') report "Add_Sub_8 sub case failed" severity error;

        A <= "00000110"; B <= "00000110"; Add_Sub_Sel <= '1'; wait for 10 ns;
        assert (S = "00000000" and Zero = '1') report "Add_Sub_8 zero flag failed" severity error;

        A <= "11111111"; B <= "00000001"; Add_Sub_Sel <= '0'; wait for 10 ns;
        assert (S = "00000000" and Overflow = '1' and Zero = '1') report "Add_Sub_8 carry-out case failed" severity error;

        wait;
    end process;
end Behavioral;

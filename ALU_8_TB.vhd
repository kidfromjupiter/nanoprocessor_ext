library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity ALU_8_TB is
end ALU_8_TB;

architecture Behavioral of ALU_8_TB is
    signal A, B, S : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal ALU_Mode : STD_LOGIC_VECTOR(ALU_MODE_WIDTH - 1 downto 0) := ALU_MODE_ADD;
    signal Overflow, Zero : STD_LOGIC;
begin
    UUT: entity work.ALU_8
        port map(
            A => A,
            B => B,
            ALU_Mode => ALU_Mode,
            S => S,
            Overflow => Overflow,
            Zero => Zero
        );

    process
    begin
        A <= x"03"; B <= x"02"; ALU_Mode <= ALU_MODE_ADD; wait for 10 ns;
        assert S = x"05" and Overflow = '0' and Zero = '0'
            report "ALU add case failed" severity error;

        A <= x"05"; B <= x"03"; ALU_Mode <= ALU_MODE_SUB; wait for 10 ns;
        assert S = x"02" and Overflow = '1' and Zero = '0'
            report "ALU sub case failed" severity error;

        A <= x"06"; B <= x"06"; ALU_Mode <= ALU_MODE_CMPEQ; wait for 10 ns;
        assert S = x"01" and Overflow = '0' and Zero = '0'
            report "ALU compare equal true failed" severity error;

        A <= x"06"; B <= x"07"; ALU_Mode <= ALU_MODE_CMPEQ; wait for 10 ns;
        assert S = x"00" and Overflow = '0' and Zero = '1'
            report "ALU compare equal false failed" severity error;

        A <= x"06"; B <= x"07"; ALU_Mode <= ALU_MODE_CMPLT; wait for 10 ns;
        assert S = x"01" and Overflow = '0' and Zero = '0'
            report "ALU compare less-than true failed" severity error;

        A <= x"FF"; B <= x"01"; ALU_Mode <= ALU_MODE_CMPGT; wait for 10 ns;
        assert S = x"01" and Overflow = '0' and Zero = '0'
            report "ALU unsigned greater-than true failed" severity error;

        A <= x"01"; B <= x"FF"; ALU_Mode <= ALU_MODE_CMPGT; wait for 10 ns;
        assert S = x"00" and Overflow = '0' and Zero = '1'
            report "ALU unsigned greater-than false failed" severity error;

        wait;
    end process;
end Behavioral;

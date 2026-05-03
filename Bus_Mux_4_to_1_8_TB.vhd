library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Bus_Mux_4_to_1_8_TB is
end Bus_Mux_4_to_1_8_TB;

architecture Behavioral of Bus_Mux_4_to_1_8_TB is
    signal A_in, B_in, Add_in, Reg_in, Y : STD_LOGIC_VECTOR(7 downto 0);
    signal Out_A, Out_B, Out_Add, Out_Reg : STD_LOGIC := '0';
begin
    UUT: entity work.Bus_Mux_4_to_1_8
        port map(
            A_in => A_in, B_in => B_in, Add_in => Add_in, Reg_in => Reg_in,
            Out_A => Out_A, Out_B => Out_B, Out_Add => Out_Add, Out_Reg => Out_Reg,
            Y => Y
        );

    process
    begin
        A_in <= x"11"; B_in <= x"22"; Add_in <= x"33"; Reg_in <= x"44";

        Out_A <= '1'; Out_B <= '0'; Out_Add <= '0'; Out_Reg <= '0'; wait for 10 ns;
        assert Y = x"11" report "Bus mux A select failed" severity error;

        Out_A <= '0'; Out_B <= '1'; wait for 10 ns;
        assert Y = x"22" report "Bus mux B select failed" severity error;

        Out_B <= '0'; Out_Add <= '1'; wait for 10 ns;
        assert Y = x"33" report "Bus mux Add select failed" severity error;

        Out_Add <= '0'; Out_Reg <= '1'; wait for 10 ns;
        assert Y = x"44" report "Bus mux Reg select failed" severity error;

        Out_Reg <= '0'; wait for 10 ns;
        assert Y = x"00" report "Bus mux idle output failed" severity error;

        wait;
    end process;
end Behavioral;

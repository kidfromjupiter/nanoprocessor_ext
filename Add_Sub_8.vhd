library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Add_Sub_8 is
    Port (
    -- from reg_8 (RegA and RegB latches)
        A           : in STD_LOGIC_VECTOR (7 downto 0);
        B           : in STD_LOGIC_VECTOR (7 downto 0);
    -- from control_unit
        Add_Sub_Sel : in STD_LOGIC;
    -- to bus_mux_4_to_1_8
        S           : out STD_LOGIC_VECTOR (7 downto 0);
    -- to top-level (flags)
        Overflow    : out STD_LOGIC;
        Zero        : out STD_LOGIC
    );
end Add_Sub_8;

architecture Behavioral of Add_Sub_8 is
    component RCA_8
        Port (
            A     : in STD_LOGIC_VECTOR (7 downto 0);
            B     : in STD_LOGIC_VECTOR (7 downto 0);
            C_in  : in STD_LOGIC;
            S     : out STD_LOGIC_VECTOR (7 downto 0);
            C_out : out STD_LOGIC
        );
    end component;

    signal B_XOR     : STD_LOGIC_VECTOR (7 downto 0);
    signal S_int     : STD_LOGIC_VECTOR (7 downto 0);
    signal C_out_int : STD_LOGIC;
begin
    B_XOR <= B xor (7 downto 0 => Add_Sub_Sel);

    RCA: RCA_8 port map(
        A => A,
        B => B_XOR,
        C_in => Add_Sub_Sel,
        S => S_int,
        C_out => C_out_int
    );

    S <= S_int;
    Overflow <= C_out_int;
    Zero <= '1' when S_int = "00000000" else '0';
end Behavioral;

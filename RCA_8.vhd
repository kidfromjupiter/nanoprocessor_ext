library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RCA_8 is
    Port (
    -- from add_sub_8
        A     : in STD_LOGIC_VECTOR (7 downto 0);
        B     : in STD_LOGIC_VECTOR (7 downto 0);
        C_in  : in STD_LOGIC;
    -- to add_sub_8
        S     : out STD_LOGIC_VECTOR (7 downto 0);
        C_out : out STD_LOGIC
    );
end RCA_8;

architecture Behavioral of RCA_8 is
    signal Sum_ext : unsigned(8 downto 0);
    signal Cin_ext : unsigned(8 downto 0);
begin
    Cin_ext <= (8 downto 1 => '0') & C_in;
    Sum_ext <= ('0' & unsigned(A)) + ('0' & unsigned(B)) + Cin_ext;

    S <= STD_LOGIC_VECTOR(Sum_ext(7 downto 0));
    C_out <= Sum_ext(8);
end Behavioral;

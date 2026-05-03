library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Seven_Seg_Hex_Display is
    Generic (
        REFRESH_BITS : natural := 16
    );
    Port (
        Clk       : in STD_LOGIC;
        Res       : in STD_LOGIC;
        Value     : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
        Seg_Out   : out STD_LOGIC_VECTOR(6 downto 0);
        Anode     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Seven_Seg_Hex_Display;

architecture Behavioral of Seven_Seg_Hex_Display is
    signal Refresh_Counter : unsigned(REFRESH_BITS - 1 downto 0) := (others => '0');
    signal Digit_Select    : STD_LOGIC_VECTOR(1 downto 0);
    signal Nibble          : STD_LOGIC_VECTOR(3 downto 0);

    function Hex_To_Seven_Seg(Hex : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case Hex is
            when x"0" => return "1000000";
            when x"1" => return "1111001";
            when x"2" => return "0100100";
            when x"3" => return "0110000";
            when x"4" => return "0011001";
            when x"5" => return "0010010";
            when x"6" => return "0000010";
            when x"7" => return "1111000";
            when x"8" => return "0000000";
            when x"9" => return "0010000";
            when x"A" => return "0001000";
            when x"B" => return "0000011";
            when x"C" => return "1000110";
            when x"D" => return "0100001";
            when x"E" => return "0000110";
            when x"F" => return "0001110";
            when others => return "1000000";
        end case;
    end function;
begin
    process(Clk, Res)
    begin
        if Res = '1' then
            Refresh_Counter <= (others => '0');
        elsif rising_edge(Clk) then
            Refresh_Counter <= Refresh_Counter + 1;
        end if;
    end process;

    Digit_Select <= STD_LOGIC_VECTOR(Refresh_Counter(REFRESH_BITS - 1 downto REFRESH_BITS - 2));

    process(all)
    begin
        case Digit_Select is
            when "00" =>
                Anode <= "1110";
                Nibble <= Value(3 downto 0);
            when "01" =>
                Anode <= "1101";
                Nibble <= Value(7 downto 4);
            when others =>
                Anode <= "1111";
                Nibble <= (others => '0');
        end case;
    end process;

    Seg_Out <= Hex_To_Seven_Seg(Nibble) when Anode /= "1111" else "1111111";
end Behavioral;

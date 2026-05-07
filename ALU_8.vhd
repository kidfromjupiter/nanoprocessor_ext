library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity ALU_8 is
    Port (
        A        : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        B        : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        ALU_Mode : in STD_LOGIC_VECTOR (ALU_MODE_WIDTH - 1 downto 0);
        S        : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Overflow : out STD_LOGIC;
        Zero     : out STD_LOGIC
    );
end ALU_8;

architecture Behavioral of ALU_8 is
    signal Add_Sub_Sel : STD_LOGIC;
    signal Add_Sub_Out : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Result      : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Add_Overflow : STD_LOGIC;
begin
    Add_Sub_Sel <= '1' when ALU_Mode = ALU_MODE_SUB else '0';

    AddSub: entity work.Add_Sub_8
        port map(
            A => A,
            B => B,
            Add_Sub_Sel => Add_Sub_Sel,
            S => Add_Sub_Out,
            Overflow => Add_Overflow,
            Zero => open
        );

    process(A, B, ALU_Mode, Add_Sub_Out)
    begin
        Result <= Add_Sub_Out;

        case ALU_Mode is
            when ALU_MODE_CMPEQ =>
                if A = B then
                    Result <= x"01";
                else
                    Result <= x"00";
                end if;

            when ALU_MODE_CMPLT =>
                if unsigned(A) < unsigned(B) then
                    Result <= x"01";
                else
                    Result <= x"00";
                end if;

            when ALU_MODE_CMPGT =>
                if unsigned(A) > unsigned(B) then
                    Result <= x"01";
                else
                    Result <= x"00";
                end if;

            when others =>
                Result <= Add_Sub_Out;
        end case;
    end process;

    S <= Result;
    Overflow <= Add_Overflow when ALU_Mode = ALU_MODE_ADD or ALU_Mode = ALU_MODE_SUB else '0';
    Zero <= '1' when Result = x"00" else '0';
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Nano_Config_Pkg.ALL;

entity Reg_Bank_8 is
    Port (
    -- from register write data mux (immediate/bus/exec_result)
        Data_in     : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    -- from control_unit
        Out_Select  : in STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Load_Select : in STD_LOGIC_VECTOR (REG_SEL_WIDTH - 1 downto 0);
        Reg_Write   : in STD_LOGIC;
    -- clk/reset
        Clk         : in STD_LOGIC;
        Res         : in STD_LOGIC;
    -- to control_unit (operand feedback)
        Reg_Out     : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    -- to top-level (debug/monitoring outputs)
        R0          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R1          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R2          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R3          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R4          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R5          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R6          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        R7          : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Reg_Bank_8;

architecture Behavioral of Reg_Bank_8 is
    type reg_array_t is array (0 to REG_COUNT - 1) of STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Regs : reg_array_t := (others => (others => '0'));
begin
    process(Clk, Res)
        variable write_idx : integer range 0 to REG_COUNT - 1;
    begin
        if Res = '1' then
            for i in 1 to REG_COUNT - 1 loop
                Regs(i) <= (others => '0');
            end loop;
        elsif rising_edge(Clk) then
            write_idx := to_integer(unsigned(Load_Select));
            if Reg_Write = '1' and write_idx /= 0 then
                Regs(write_idx) <= Data_in;
            end if;
        end if;
    end process;

    with Out_Select select
        Reg_Out <= (others => '0') when "000",
                   Regs(1) when "001",
                   Regs(2) when "010",
                   Regs(3) when "011",
                   Regs(4) when "100",
                   Regs(5) when "101",
                   Regs(6) when "110",
                   Regs(7) when others;

    R0 <= (others => '0');
    R1 <= Regs(1);
    R2 <= Regs(2);
    R3 <= Regs(3);
    R4 <= Regs(4);
    R5 <= Regs(5);
    R6 <= Regs(6);
    R7 <= Regs(7);
end Behavioral;

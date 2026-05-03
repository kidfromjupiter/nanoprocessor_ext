library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity Nanoprocessor_Basys3 is
    Port (
        Clk       : in STD_LOGIC;
        Reset     : in STD_LOGIC;
        Sw        : in STD_LOGIC_VECTOR(15 downto 0);
        Btn_Step  : in STD_LOGIC;
        Led       : out STD_LOGIC_VECTOR(15 downto 0);
        Seg_Out   : out STD_LOGIC_VECTOR(6 downto 0);
        Anode     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Nanoprocessor_Basys3;

architecture Structural of Nanoprocessor_Basys3 is
    signal Cpu_Clk       : STD_LOGIC;
    signal Overflow_Int  : STD_LOGIC;
    signal Zero_Int      : STD_LOGIC;
    signal Div_Zero_Int  : STD_LOGIC;
    signal PC_Out_Int    : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
    signal R0_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R1_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R2_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R3_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R4_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R5_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R6_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal R7_Out_Int    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
    signal Selected_Reg  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
begin
    ClockControl: entity work.Manual_Clock_Controller
        port map(
            Sys_Clk => Clk,
            Res => Reset,
            Manual_Mode => Sw(15),
            Step_Button => Btn_Step,
            Cpu_Clk => Cpu_Clk
        );

    Core: entity work.Nanoprocessor_Ext
        port map(
            Clk => Cpu_Clk,
            Reset => Reset,
            Overflow => Overflow_Int,
            Zero => Zero_Int,
            Div_Zero => Div_Zero_Int,
            PC_Out => PC_Out_Int,
            R0_Out => R0_Out_Int,
            R1_Out => R1_Out_Int,
            R2_Out => R2_Out_Int,
            R3_Out => R3_Out_Int,
            R4_Out => R4_Out_Int,
            R5_Out => R5_Out_Int,
            R6_Out => R6_Out_Int,
            R7_Out => R7_Out_Int
        );

    DisplayMux: entity work.Register_Select_Mux_8
        port map(
            Sw_Select => Sw(7 downto 0),
            R0 => R0_Out_Int,
            R1 => R1_Out_Int,
            R2 => R2_Out_Int,
            R3 => R3_Out_Int,
            R4 => R4_Out_Int,
            R5 => R5_Out_Int,
            R6 => R6_Out_Int,
            R7 => R7_Out_Int,
            Y => Selected_Reg
        );

    Display: entity work.Seven_Seg_Hex_Display
        port map(
            Clk => Clk,
            Res => Reset,
            Value => Selected_Reg,
            Seg_Out => Seg_Out,
            Anode => Anode
        );

    Led(7 downto 0) <= Sw(7 downto 0);
    Led(8) <= Overflow_Int;
    Led(9) <= Zero_Int;
    Led(10) <= Div_Zero_Int;
    Led(14 downto 11) <= (others => '0');
    Led(15) <= Sw(15);
end Structural;

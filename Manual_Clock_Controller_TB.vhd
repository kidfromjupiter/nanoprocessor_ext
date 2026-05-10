library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Manual_Clock_Controller_TB is
end Manual_Clock_Controller_TB;

architecture Behavioral of Manual_Clock_Controller_TB is
    signal Sys_Clk     : STD_LOGIC := '0';
    signal Res         : STD_LOGIC := '1';
    signal Manual_Mode : STD_LOGIC := '0';
    signal Step_Button : STD_LOGIC := '0';
    signal Cpu_Clk     : STD_LOGIC;
    signal Pulse_Count : integer := 0;
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.Manual_Clock_Controller
        generic map(
            DEBOUNCE_CYCLES => 2,
            AUTO_HALF_PERIOD_CYCLES => 3
        )
        port map(
            Sys_Clk => Sys_Clk,
            Res => Res,
            Manual_Mode => Manual_Mode,
            Step_Button => Step_Button,
            Cpu_Clk => Cpu_Clk
        );

    Sys_Clk_Process: process
    begin
        Sys_Clk <= '0'; wait for CLK_PERIOD / 2;
        Sys_Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    Count_Process: process(Cpu_Clk)
    begin
        if rising_edge(Cpu_Clk) and Manual_Mode = '1' and Res = '0' then
            Pulse_Count <= Pulse_Count + 1;
        end if;
    end process;

    process
        variable Start_Count : integer;
    begin
        wait for 27 ns;
        Res <= '0';

        Manual_Mode <= '0';
        wait for 20 ns;
        assert Cpu_Clk = '0' report "Auto mode should hold divided clock low before half period" severity error;
        wait for 20 ns;
        assert Cpu_Clk = '1' report "Auto mode should toggle divided clock after half period" severity error;
        wait for 30 ns;
        assert Cpu_Clk = '0' report "Auto mode should toggle divided clock after full half period" severity error;

        Manual_Mode <= '1';
        wait until Sys_Clk = '0';
        wait for 1 ns;
        assert Cpu_Clk = '0' report "Manual mode should hold CPU clock low without step" severity error;
        wait for 60 ns;
        assert Pulse_Count = 0 report "Manual mode should not free-run" severity error;

        Start_Count := Pulse_Count;
        Step_Button <= '1';
        wait for 80 ns;
        Step_Button <= '0';
        wait for 80 ns;
        assert Pulse_Count = Start_Count + 1 report "One button press should create one CPU clock pulse" severity error;

        Start_Count := Pulse_Count;
        wait for 80 ns;
        assert Pulse_Count = Start_Count report "Released button should not create extra pulses" severity error;

        wait;
    end process;
end Behavioral;

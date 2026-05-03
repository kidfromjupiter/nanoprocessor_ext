library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Manual_Clock_Controller is
    Generic (
        DEBOUNCE_CYCLES : natural := 1000000
    );
    Port (
        Sys_Clk     : in STD_LOGIC;
        Res         : in STD_LOGIC;
        Manual_Mode : in STD_LOGIC;
        Step_Button : in STD_LOGIC;
        Cpu_Clk     : out STD_LOGIC
    );
end Manual_Clock_Controller;

architecture Behavioral of Manual_Clock_Controller is
    signal Button_Sync_0  : STD_LOGIC := '0';
    signal Button_Sync_1  : STD_LOGIC := '0';
    signal Button_Stable  : STD_LOGIC := '0';
    signal Button_Prev    : STD_LOGIC := '0';
    signal Step_Pulse     : STD_LOGIC := '0';
    signal Debounce_Count : natural range 0 to DEBOUNCE_CYCLES := 0;
begin
    process(Sys_Clk, Res)
    begin
        if Res = '1' then
            Button_Sync_0 <= '0';
            Button_Sync_1 <= '0';
            Button_Stable <= '0';
            Button_Prev <= '0';
            Step_Pulse <= '0';
            Debounce_Count <= 0;
        elsif rising_edge(Sys_Clk) then
            Button_Sync_0 <= Step_Button;
            Button_Sync_1 <= Button_Sync_0;
            Step_Pulse <= '0';

            if Button_Sync_1 = Button_Stable then
                Debounce_Count <= 0;
            elsif Debounce_Count = DEBOUNCE_CYCLES then
                Button_Stable <= Button_Sync_1;
                Debounce_Count <= 0;
            else
                Debounce_Count <= Debounce_Count + 1;
            end if;

            Button_Prev <= Button_Stable;
            if Button_Stable = '1' and Button_Prev = '0' then
                Step_Pulse <= '1';
            end if;
        end if;
    end process;

    Cpu_Clk <= Sys_Clk when Manual_Mode = '0' else Step_Pulse;
end Behavioral;

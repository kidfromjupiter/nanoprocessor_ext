library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Nano_Config_Pkg.ALL;

entity Bus_Mux_4_to_1_8 is
    Port (
    -- data inputs from datapath
        A_in    : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        B_in    : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Add_in  : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Reg_in  : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    -- select signals from control_unit
        Out_A   : in STD_LOGIC;
        Out_B   : in STD_LOGIC;
        Out_Add : in STD_LOGIC;
        Out_Reg : in STD_LOGIC;
    -- to central_bus (reg_8 latches and reg_bank_8 write input)
        Y       : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Bus_Mux_4_to_1_8;

architecture Behavioral of Bus_Mux_4_to_1_8 is
begin
    process(A_in, B_in, Add_in, Reg_in, Out_A, Out_B, Out_Add, Out_Reg)
    begin
        Y <= (others => '0');
        if Out_A = '1' then
            Y <= A_in;
        elsif Out_B = '1' then
            Y <= B_in;
        elsif Out_Add = '1' then
            Y <= Add_in;
        elsif Out_Reg = '1' then
            Y <= Reg_in;
        end if;
    end process;
end Behavioral;

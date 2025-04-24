library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    Port ( CLK_IN1 : in STD_LOGIC;
           CLK_OUT1 : out std_logic);
end clk_div;

architecture Behavioral of clk_div is
component clk_wiz_0
port
(-- Clock in ports
    CLK_IN1 : in std_logic;
    -- Clock out ports
    CLK_OUT1 : out std_logic
);
end component;

begin
    clk_wiz_0_inst : clk_wiz_0
        port map (
            CLK_IN1 => CLK_IN1,
            CLK_OUT1 => CLK_OUT1
        );
end Behavioral;
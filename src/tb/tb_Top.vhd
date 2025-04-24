library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
    -- Testbench has no ports
end tb_top;

architecture sim of tb_top is

    -- Component under test (CUT)
    component top
        Port (
            CLK_I     : in  STD_LOGIC;
            SEL       : in STD_LOGIC_VECTOR(2 downto 0);
            VGA_HS_O  : out STD_LOGIC;
            VGA_VS_O  : out STD_LOGIC;
            VGA_R     : out STD_LOGIC_VECTOR(3 downto 0);
            VGA_B     : out STD_LOGIC_VECTOR(3 downto 0);
            VGA_G     : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Signals for driving and monitoring
    signal CLK_I     : STD_LOGIC := '0';
    signal SEL       : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal VGA_HS_O  : STD_LOGIC;
    signal VGA_VS_O  : STD_LOGIC;
    signal VGA_R     : STD_LOGIC_VECTOR(3 downto 0);
    signal VGA_B     : STD_LOGIC_VECTOR(3 downto 0);
    signal VGA_G     : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz input clock

begin

    -- Instantiate the unit under test
    uut: top
        port map (
            CLK_I     => CLK_I,
            SEL       => SEL,
            VGA_HS_O  => VGA_HS_O,
            VGA_VS_O  => VGA_VS_O,
            VGA_R     => VGA_R,
            VGA_B     => VGA_B,
            VGA_G     => VGA_G
        );

    -- Generate input clock
    clk_process : process
    begin
        while true loop
            CLK_I <= '0';
            wait for CLK_PERIOD / 2;
            CLK_I <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Simulation process: change SEL value over time
    sim_process : process
    begin
        -- Let system stabilize
        wait for 100 ns;

        -- Cycle through selector values
        for i in 0 to 7 loop
            SEL <= std_logic_vector(to_unsigned(i, 3));
            wait for 1 ms;  -- Each char displays for 1ms
        end loop;

        report "Simulation finished." severity note;
        wait;
    end process;

end sim;

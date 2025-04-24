library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity vga_display_tb is
end vga_display_tb;

architecture Behavioral of vga_display_tb is

    component vga_display is
        Port (
            clk         : in std_logic;
            active      : in std_logic;
            screen_x    : in std_logic_vector(11 downto 0);
            screen_y    : in std_logic_vector(11 downto 0);
            char_select : in std_logic_vector(7 downto 0);
            vga_red     : out std_logic_vector(3 downto 0);
            vga_green   : out std_logic_vector(3 downto 0);
            vga_blue    : out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk         : std_logic := '0';
    signal active      : std_logic := '0';
    signal screen_x    : std_logic_vector(11 downto 0) := (others => '0');
    signal screen_y    : std_logic_vector(11 downto 0) := (others => '0');
    signal char_select : std_logic_vector(7 downto 0) := x"41";

    signal vga_red    : std_logic_vector(3 downto 0);
    signal vga_green  : std_logic_vector(3 downto 0);
    signal vga_blue   : std_logic_vector(3 downto 0);

    constant clk_period : time := 10 ns;

    function is_black(color : std_logic_vector(3 downto 0)) return boolean is
    begin
        return color = (others => '0');
    end function;

    function is_white(color : std_logic_vector(3 downto 0)) return boolean is
    begin
        return color = (others => '1');
    end function;

    constant NOTE_WIDTH  : integer := 48;
    constant NOTE_HEIGHT : integer := 48;
    constant char_x_val : integer := 940;

begin

    uut: vga_display
        port map(
            clk => clk,
            active => active,
            screen_x => screen_x,
            screen_y => screen_y,
            char_select => char_select,
            vga_red => vga_red,
            vga_green => vga_green,
            vga_blue => vga_blue
        );

    clk_process: process
    begin
        while true loop
            clk <= '0'; wait for clk_period / 2;
            clk <= '1'; wait for clk_period / 2;
        end loop;
    end process;

    stim_process: process
        variable pass_all : boolean := true;
    begin
        wait for 4 * clk_period;

        -- Inactive disables colors
        active <= '0';
        screen_x <= std_logic_vector(to_unsigned(char_x_val, 12));
        screen_y <= (others => '0');
        char_select <= x"41";
        wait for clk_period;

        if (vga_red /= (others => '0')) or (vga_green /= (others => '0')) or (vga_blue /= (others => '0')) then
            report "FAIL: inactive active='0' RGB outputs not zero" severity error;
            pass_all := false;
        else
            report "PASS: inactive RGB outputs zero" severity note;
        end if;

        -- Background white outside note and staff
        active <= '1';
        screen_x <= std_logic_vector(to_unsigned(char_x_val - 10, 12));
        screen_y <= std_logic_vector(to_unsigned(0, 12));
        wait for clk_period;

        if (not is_white(vga_red)) or (not is_white(vga_green)) or (not is_white(vga_blue)) then
            report "FAIL: background color expected white" severity error;
            pass_all := false;
        else
            report "PASS: background color white" severity note;
        end if;

        -- Staff line black
        active <= '1';
        screen_x <= std_logic_vector(to_unsigned(char_x_val - 10, 12));
        screen_y <= std_logic_vector(to_unsigned(360, 12));
        wait for clk_period;

        if (not is_black(vga_red)) or (not is_black(vga_green)) or (not is_black(vga_blue)) then
            report "FAIL: staff line color expected black" severity error;
            pass_all := false;
        else
            report "PASS: staff line color black" severity note;
        end if;

        -- Note pixel where ROM bit = '1' (expected black)
        screen_y <= std_logic_vector(to_unsigned(396, 12));
        screen_x <= std_logic_vector(to_unsigned(964, 12)); -- char_x + 6*4
        char_select <= x"41";
        wait for clk_period;

        if (not is_black(vga_red)) or (not is_black(vga_green)) or (not is_black(vga_blue)) then
            report "FAIL: note pixel (ROM=1) expected black" severity error;
            pass_all := false;
        else
            report "PASS: note pixel (ROM=1) black" severity note;
        end if;

        -- Note pixel where ROM bit = '0' (expected white)
        screen_x <= std_logic_vector(to_unsigned(940, 12)); -- char_x + 6*0
        screen_y <= std_logic_vector(to_unsigned(396, 12));
        wait for clk_period;

        if (not is_white(vga_red)) or (not is_white(vga_green)) or (not is_white(vga_blue)) then
            report "FAIL: note pixel (ROM=0) expected white" severity error;
            pass_all := false;
        else
            report "PASS: note pixel (ROM=0) white" severity note;
        end if;

        if pass_all then
            report "All vga_display tests PASSED." severity note;
        else
            report "Some vga_display tests FAILED." severity error;
        end if;

        wait;
    end process;

end Behavioral;

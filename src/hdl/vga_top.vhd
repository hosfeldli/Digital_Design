library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_top is
    Port (
        CLK_I : in STD_LOGIC;
        NOTE : in STD_LOGIC_VECTOR(7 downto 0);
        VGA_HS_O : out STD_LOGIC;
        VGA_VS_O : out STD_LOGIC;
        VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
        VGA_B : out STD_LOGIC_VECTOR (3 downto 0);
        VGA_G : out STD_LOGIC_VECTOR (3 downto 0)
    );
end vga_top;

architecture Behavioral of vga_top is
    signal pxl_clk : std_logic;
    signal active : std_logic;
    signal screen_x : STD_LOGIC_VECTOR(11 downto 0);
    signal screen_y : STD_LOGIC_VECTOR(11 downto 0);
    signal h_cntr_reg, v_cntr_reg : std_logic_vector(11 downto 0);
    signal char_select : STD_LOGIC_VECTOR(7 downto 0);
begin

    decoder_inst : entity work.decoder
        port map (
            note => NOTE,
            char_enable => char_select
        );

    clk_div_inst : entity work.clk_div
        port map (
            CLK_IN1 => CLK_I,
            CLK_OUT1 => pxl_clk
        );

    sync_gen_inst : entity work.sync_gen
        port map (
            pxl_clk => pxl_clk,
            VGA_HS_O => VGA_HS_O,
            VGA_VS_O => VGA_VS_O,
            active => active,
            screen_x => screen_x,
            screen_y => screen_y,
            h_cntr_reg => h_cntr_reg,
            v_cntr_reg => v_cntr_reg
        );

    vga_display_inst : entity work.vga_display
        port map (
            clk => pxl_clk,
            screen_x => screen_x,
            screen_y => screen_y,
            char_select => char_select,
            active => active,
            vga_red => VGA_R,
            vga_green => VGA_G,
            vga_blue => VGA_B
        );

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity sync_gen is
    Port ( 
        pxl_clk : in std_logic;
        VGA_HS_O : out std_logic;
        VGA_VS_O : out std_logic;
        active : inout std_logic;
        screen_x : out std_logic_vector(11 downto 0);
        screen_y : out std_logic_vector(11 downto 0);
        h_cntr_reg : buffer std_logic_vector(11 downto 0);
        v_cntr_reg : buffer std_logic_vector(11 downto 0)
    );
end sync_gen;

architecture Behavioral of sync_gen is
    -- Sync generation constants
    constant FRAME_WIDTH : natural := 1920;
    constant FRAME_HEIGHT : natural := 1080;
    constant H_FP : natural := 88;
    constant H_PW : natural := 44;
    constant H_MAX : natural := 2200;
    constant V_FP : natural := 4;
    constant V_PW : natural := 5;
    constant V_MAX : natural := 1125;
    constant H_POL : std_logic := '1';
    constant V_POL : std_logic := '1';

    signal h_sync_reg : std_logic := not(H_POL);
    signal v_sync_reg : std_logic := not(V_POL);

    -- Screen position during active video
    -- signal screen_x : std_logic_vector(11 downto 0) := (others => '0');
    -- signal screen_y : std_logic_vector(11 downto 0) := (others => '0');

begin

    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if (h_cntr_reg = (H_MAX - 1)) then
                h_cntr_reg <= (others => '0');
            else
                h_cntr_reg <= h_cntr_reg + 1;
            end if;
        end if;
    end process;

    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
                v_cntr_reg <= (others => '0');
            elsif (h_cntr_reg = (H_MAX - 1)) then
                v_cntr_reg <= v_cntr_reg + 1;
            end if;
        end if;
    end process;

    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
                h_sync_reg <= H_POL;
            else
                h_sync_reg <= not(H_POL);
            end if;
        end if;
    end process;

    process (pxl_clk)
    begin
        if (rising_edge(pxl_clk)) then
            if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
                v_sync_reg <= V_POL;
            else
                v_sync_reg <= not(V_POL);
            end if;
        end if;
    end process;

    -- Active video region detection
    active <= '1' when ((h_cntr_reg < FRAME_WIDTH) and (v_cntr_reg < FRAME_HEIGHT)) else '0';

    -- Screen coordinates tracking
    process(pxl_clk)
    begin
        if rising_edge(pxl_clk) then
            if (active = '1') then
                screen_x <= h_cntr_reg;
                screen_y <= v_cntr_reg;
            else
                screen_x <= (others => '0');
                screen_y <= (others => '0');
            end if;
        end if;
    end process;

    VGA_HS_O <= h_sync_reg;
    VGA_VS_O <= v_sync_reg;

end Behavioral;

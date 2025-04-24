library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_display is
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
end vga_display;

architecture Behavioral of vga_display is

    component Memory
        Port (
            clk       : in STD_LOGIC;
            reset     : in STD_LOGIC;
            index     : in STD_LOGIC_VECTOR(7 downto 0);
            sub_index : in STD_LOGIC_VECTOR(2 downto 0);
            data_out  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal x, y : unsigned(11 downto 0);

    signal sprite_row    : std_logic_vector(2 downto 0);
    signal rom_pixel_row : std_logic_vector(7 downto 0);
    signal reset         : std_logic := '0';

    signal sprite_x_offset : integer range 0 to 7;
    signal sprite_y_offset : integer range 0 to 7;

    constant NOTE_WIDTH  : integer := 48;
    constant NOTE_HEIGHT : integer := 48;

    constant char_x : unsigned(11 downto 0) := to_unsigned(940, 12);

    constant STAFF_TOP     : unsigned(11 downto 0) := to_unsigned(360, 12);
    constant STAFF_SPACING : integer := 24;
    constant NOTE_SPACING : integer := 12;
    constant STAFF_HEIGHT  : integer := 2;
    constant OFFSET : integer := NOTE_SPACING * 16;

    -- Note vertical position
    function note_y_pos(sel : std_logic_vector(7 downto 0)) return unsigned is
    begin
        case sel is
            when x"45" => return STAFF_TOP - to_unsigned(8 * NOTE_SPACING, 12) + OFFSET; -- E (bottom line)
            when x"46" => return STAFF_TOP - to_unsigned(9 * NOTE_SPACING, 12) + OFFSET; -- F
            when x"47" => return STAFF_TOP - to_unsigned(10 * NOTE_SPACING, 12) + OFFSET; -- G
            when x"41" => return STAFF_TOP - to_unsigned(11 * NOTE_SPACING, 12) + OFFSET; -- A
            when x"42" => return STAFF_TOP - to_unsigned(12 * NOTE_SPACING, 12) + OFFSET; -- B
            when x"43" => return STAFF_TOP - to_unsigned(6 * NOTE_SPACING, 12) + OFFSET; -- C (above staff)
            when x"44" => return STAFF_TOP - to_unsigned(7 * NOTE_SPACING, 12) + OFFSET; -- D
            when others => return STAFF_TOP - to_unsigned(6 * NOTE_SPACING, 12) + OFFSET;
        end case;
    end function;

    signal char_y : unsigned(11 downto 0);

begin

    x <= unsigned(screen_x);
    y <= unsigned(screen_y);
    char_y <= note_y_pos(char_select) - to_unsigned(NOTE_HEIGHT / 2, 12);

    sprite_y_offset <= to_integer((y - char_y) / 6); -- scale to match sprite
    sprite_row <= std_logic_vector(to_unsigned(sprite_y_offset, 3));

    char_rom_inst: Memory
        port map (
            clk       => clk,
            reset     => reset,
            index     => char_select,
            sub_index => sprite_row,
            data_out  => rom_pixel_row
        );

    process (clk)
        variable draw_note_char : boolean;
        variable draw_staff     : boolean;
        variable pixel_x_offset : integer;
    begin
        if rising_edge(clk) then
            if active = '1' then
                draw_note_char := false;
                draw_staff     := false;

                -- Sprite pixel (within ROM)
                if x >= char_x and x < char_x + NOTE_WIDTH and
                   y >= char_y and y < char_y + NOTE_HEIGHT then
                    pixel_x_offset := to_integer((x - char_x) / 6);
                    if rom_pixel_row(pixel_x_offset) = '1' then
                        draw_note_char := true;
                    end if;
                end if;

                -- Staff lines
                for i in 0 to 4 loop
                    if to_integer(y) >= to_integer(STAFF_TOP) + i * STAFF_SPACING and
                       to_integer(y) < to_integer(STAFF_TOP) + i * STAFF_SPACING + STAFF_HEIGHT then
                        draw_staff := true;
                    end if;
                end loop;

                if draw_note_char then
                    vga_red   <= (others => '0');
                    vga_green <= (others => '0');
                    vga_blue  <= (others => '0');
                elsif draw_staff then
                    vga_red   <= (others => '0');
                    vga_green <= (others => '0');
                    vga_blue  <= (others => '0');
                else
                    vga_red   <= (others => '1');
                    vga_green <= (others => '1');
                    vga_blue  <= (others => '1');
                end if;

            else
                vga_red   <= (others => '0');
                vga_green <= (others => '0');
                vga_blue  <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;

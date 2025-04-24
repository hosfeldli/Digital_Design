library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        index      : in  STD_LOGIC_VECTOR(7 downto 0);
        sub_index  : in  STD_LOGIC_VECTOR(2 downto 0);
        data_out   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Memory;

architecture Behavioral of Memory is

    type rom_array_type is array (0 to 2047) of STD_LOGIC_VECTOR(7 downto 0);

    signal rom : rom_array_type := (
        -- Character 65 ('A')
        520 => "00001100",
        521 => "00011110",
        522 => "00110011",
        523 => "00110011",
        524 => "00111111",
        525 => "00110011",
        526 => "00110011",
        527 => "00000000",

        -- Character 66 ('B')
        528 => "00111111",
        529 => "01100110",
        530 => "01100110",
        531 => "00111110",
        532 => "01100110",
        533 => "01100110",
        534 => "00111111",
        535 => "00000000",

        -- Character 67 ('C')
        536 => "00111100",
        537 => "01100110",
        538 => "00000011",
        539 => "00000011",
        540 => "00000011",
        541 => "01100110",
        542 => "00111100",
        543 => "00000000",

        -- Character 68 ('D')
        544 => "00011111",
        545 => "00110110",
        546 => "01100110",
        547 => "01100110",
        548 => "01100110",
        549 => "00110110",
        550 => "00011111",
        551 => "00000000",

        -- Character 69 ('E')
        552 => "01111111",
        553 => "01000011",
        554 => "00010011",
        555 => "00011111",
        556 => "00010011",
        557 => "01000011",
        558 => "01111111",
        559 => "00000000",

        -- Character 70 ('F')
        560 => "01111111",
        561 => "01000011",
        562 => "00010011",
        563 => "00011111",
        564 => "00010011",
        565 => "00000011",
        566 => "00000011",
        567 => "00000000",

        -- Character 71 ('G')
        568 => "00111100",
        569 => "01100110",
        570 => "00000011",
        571 => "01110011",
        572 => "01110011",
        573 => "01100110",
        574 => "01111100",
        575 => "00000000",

        -- Character 99 ('c')
        792 => "00000000",
        793 => "00000000",
        794 => "00111110",
        795 => "01100011",
        796 => "00000011",
        797 => "01100011",
        798 => "00111110",
        799 => "00000000",

        -- Default everything else to 0
        others => (others => '0')
    );

    -- Vivado hint for BRAM must come AFTER signal declaration
    attribute ram_style : string;
    attribute ram_style of rom : signal is "block";

    signal addr : integer range 0 to 2047;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_out <= (others => '0');
            else
                addr <= to_integer(unsigned(index)) * 8 + to_integer(unsigned(sub_index));
                data_out <= rom(addr);
            end if;
        end if;
    end process;

end Behavioral;

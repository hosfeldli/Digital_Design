library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
    Port (
        note : in std_logic_vector(7 downto 0);         
        char_enable : out std_logic_vector(7 downto 0)
    );
end decoder;

architecture Behavioral of decoder is
begin
    process(note)
    begin
        case note is
            when "01000101" => -- A
                char_enable <= std_logic_vector(to_unsigned(65, 8));
            when "01000111" => -- B
                char_enable <= std_logic_vector(to_unsigned(66, 8));
            when "00111100" => -- C
                char_enable <= std_logic_vector(to_unsigned(67, 8));
            when "00111110" => -- D
                char_enable <= std_logic_vector(to_unsigned(68, 8));
            when "01000000" => -- E
                char_enable <= std_logic_vector(to_unsigned(69, 8));
            when "01000001" => -- F
                char_enable <= std_logic_vector(to_unsigned(70, 8));
            when "01000011" => -- G
                char_enable <= std_logic_vector(to_unsigned(71, 8));
            when "00111101" => -- c
                char_enable <= std_logic_vector(to_unsigned(99, 8));
            when others =>
                char_enable <= (others => '0');
        end case;
    end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity decoder_tb is
-- Testbench has no ports
end decoder_tb;

architecture Behavioral of decoder_tb is

    -- Component declaration for the DUT
    component decoder is
        Port (
            note : in std_logic_vector(7 downto 0);
            char_enable : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals to connect to DUT
    signal note       : std_logic_vector(7 downto 0) := (others => '0');
    signal char_enable: std_logic_vector(7 downto 0);

    -- Test vector type
    type test_vector is record
        input_note   : std_logic_vector(7 downto 0);
        expected_out : std_logic_vector(7 downto 0);
        description  : string(1 to 20);
    end record;

    -- Test vectors array
    type test_array is array (natural range <>) of test_vector;

    constant tests : test_array := (
        (input_note => "01000101", expected_out => std_logic_vector(to_unsigned(65, 8)), description => "Test A (65)"),
        (input_note => "01000111", expected_out => std_logic_vector(to_unsigned(66, 8)), description => "Test B (66)"),
        (input_note => "00111100", expected_out => std_logic_vector(to_unsigned(67, 8)), description => "Test C (67)"),
        (input_note => "00111110", expected_out => std_logic_vector(to_unsigned(68, 8)), description => "Test D (68)"),
        (input_note => "01000000", expected_out => std_logic_vector(to_unsigned(69, 8)), description => "Test E (69)"),
        (input_note => "01000001", expected_out => std_logic_vector(to_unsigned(70, 8)), description => "Test F (70)"),
        (input_note => "01000011", expected_out => std_logic_vector(to_unsigned(71, 8)), description => "Test G (71)"),
        (input_note => "00111101", expected_out => std_logic_vector(to_unsigned(99, 8)), description => "Test c (99)"),
        (input_note => "11111111", expected_out => (others => '0'),                  description => "Test others = 0")
    );

begin

    -- Instantiate the DUT
    uut: decoder
        port map(
            note => note,
            char_enable => char_enable
        );

    -- Process to apply test vectors and self-check output
    stim_proc: process
        variable all_passed : boolean := true;
    begin
        for i in tests'range loop
            -- Apply input
            note <= tests(i).input_note;
            wait for 10 ns;  -- wait for signals to propagate

            -- Check the output
            if char_enable /= tests(i).expected_out then
                report "FAIL: " & tests(i).description
                     & " Input: " & to_hstring(tests(i).input_note)
                     & " Expected: " & to_hstring(tests(i).expected_out)
                     & " Got: " & to_hstring(char_enable)
                     severity error;
                all_passed := false;
            else
                report "PASS: " & tests(i).description severity note;
            end if;
        end loop;

        if all_passed then
            report "All tests passed!" severity note;
        else
            report "Some tests failed." severity error;
        end if;

        wait;
    end process;

end Behavioral;

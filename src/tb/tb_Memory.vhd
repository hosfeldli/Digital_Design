library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity Memory_tb is
end Memory_tb;

architecture Behavioral of Memory_tb is

    -- Component declaration
    component Memory is
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            index     : in  STD_LOGIC_VECTOR(7 downto 0);
            sub_index : in  STD_LOGIC_VECTOR(2 downto 0);
            data_out  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals to connect to DUT
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal index     : std_logic_vector(7 downto 0);
    signal sub_index : std_logic_vector(2 downto 0);
    signal data_out  : std_logic_vector(7 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Test vector type
    type test_vector is record
        index       : std_logic_vector(7 downto 0);
        sub_index   : std_logic_vector(2 downto 0);
        expected_out: std_logic_vector(7 downto 0);
        description : string(1 to 50);
    end record;

    -- Define expected ROM contents matching the Memory code
    -- Note: address = index * 8 + sub_index
    constant test_vectors : array (natural range <>) of test_vector := (
        -- Character 65 ('A'), ROM addresses 520 - 527
        ( index => std_logic_vector(to_unsigned(65,8)), sub_index => "000", expected_out => "00001100", description => "A, line 0"),
        ( index => std_logic_vector(to_unsigned(65,8)), sub_index => "001", expected_out => "00011110", description => "A, line 1"),
        ( index => std_logic_vector(to_unsigned(65,8)), sub_index => "010", expected_out => "00110011", description => "A, line 2"),
        ( index => std_logic_vector(to_unsigned(65,8)), sub_index => "111", expected_out => "00000000", description => "A, line 7"),

        -- Character 66 ('B'), addresses 528 - 535
        ( index => std_logic_vector(to_unsigned(66,8)), sub_index => "000", expected_out => "00111111", description => "B, line 0"),
        ( index => std_logic_vector(to_unsigned(66,8)), sub_index => "011", expected_out => "00111110", description => "B, line 3"),

        -- Character 99 ('c'), addresses 792 - 799
        ( index => std_logic_vector(to_unsigned(99,8)), sub_index => "010", expected_out => "00111110", description => "c, line 2"),
        ( index => std_logic_vector(to_unsigned(99,8)), sub_index => "110", expected_out => "00111110", description => "c, line 6"),

        -- Test reset behaviour: expects all zeros
        ( index => (others => '0'), sub_index => (others => '0'), expected_out => (others => '0'), description => "Reset output zero")
    );

begin

    -- Instantiate DUT
    uut: Memory
        port map(
            clk => clk,
            reset => reset,
            index => index,
            sub_index => sub_index,
            data_out => data_out
        );

    -- Clock generation process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stimulus: process
        variable all_passed: boolean := true;
        variable test_idx : integer := 0;
    begin
        -- Release reset after one clock cycle
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Apply each test vector
        for i in test_vectors'range loop
            -- For reset test vector, assert reset
            if test_vectors(i).description = "Reset output zero" then
                reset <= '1';
            else
                reset <= '0';
            end if;

            index <= test_vectors(i).index;
            sub_index <= test_vectors(i).sub_index;

            wait for clk_period; -- Wait for rising edge + output valid

            -- Check output
            if data_out /= test_vectors(i).expected_out then
                report "FAIL: " & test_vectors(i).description &
                    " Index=" & integer'image(to_integer(unsigned(test_vectors(i).index))) &
                    " Sub_index=" & integer'image(to_integer(unsigned(test_vectors(i).sub_index))) &
                    " Expected=" & to_hstring(test_vectors(i).expected_out) &
                    " Got=" & to_hstring(data_out)
                    severity error;
                all_passed := false;
            else
                report "PASS: " & test_vectors(i).description severity note;
            end if;

            test_idx := test_idx + 1;
        end loop;

        if all_passed then
            report "All Memory tests passed successfully." severity note;
        else
            report "Some Memory tests failed." severity error;
        end if;

        wait; -- stop simulation
    end process;

end Behavioral;

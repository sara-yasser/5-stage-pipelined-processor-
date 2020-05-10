LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity CCR IS
port(
    clk, rst :   in  STD_LOGIC;
    input_vec   :   in std_logic_vector(2 downto 0);
    output_vec  :   out std_logic_vector(2 downto 0)

    );
end entity;

architecture CCR_arc of CCR is

    begin
        process (clk) is
            begin
                if rst = '1' then
                    output_vec <= (others => '0');

                elsif rst = '0' then
                    if rising_edge(clk) then
                        output_vec <= input_vec;
                    end if;
                end if;

        end process;

end architecture;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity IF_ID_buff IS
port(
    clk, rst, stall_sig :   in  STD_LOGIC;
    input_vec   :   in std_logic_vector(47 downto 0);
    output_vec  :   out std_logic_vector(47 downto 0)
    );
end entity;

architecture IF_ID_buff_arc of IF_ID_buff is

    signal nop_sig : std_logic_vector(15 downto 0) := "1111000000011100";

    begin
        process (clk) is
            begin
                if rst = '1' then
                    output_vec(47 downto 16) <= (others => '0');
                    output_vec(15 downto 0) <= nop_sig;

                elsif rst = '0' then
                    -- we need to fix rising edge with input, for not to waste a whole cycle to read data
                    if rising_edge(clk) then
                        if stall_sig = '0' then
                            output_vec <= input_vec;
                        elsif stall_sig = '1' then
                            output_vec(15 downto 0) <= nop_sig;
                        end if;
                    end if;
                end if;

        end process;

end architecture;

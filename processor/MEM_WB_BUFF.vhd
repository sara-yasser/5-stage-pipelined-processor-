LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity MEM_WB_buff IS
generic (n : integer := 32);
port
(
    clk, rst, stall_sig :   in  STD_LOGIC;
    input_vec   :   in std_logic_vector(n - 1 downto 0);
    output_vec  :   out std_logic_vector(n - 1 downto 0)

    );
end entity;

architecture MEM_WB_buff_arc of MEM_WB_buff is

    begin
        output_vec <= (others => '0') when rst = '1'
        else input_vec when stall_sig = '0';
        -- process (clk) is
        --     begin
        --         if rst = '1' then
        --             output_vec <= (others => '0');

        --         elsif rst = '0' then
        --             if rising_edge(clk) then
        --                 if stall_sig = '0' then
        --                     output_vec <= input_vec;
        --                 end if;
        --             end if;
        --         end if;

        -- end process;

end architecture;


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity file_reg IS
port(
    clk, wr_in_pc_sig, reg_wr_sig, swap_sig, rst, inc_sp, dec_sp :          in  STD_LOGIC;
    rd_address1, rd_address2    :   in std_logic_vector(2 downto 0);
    wr_address1, wr_address2  :   in std_logic_vector(2 downto 0);
    wr_data, swap_data2 :   in std_logic_vector(31 downto 0);
    rd_data1, rd_data2, sp  :   out std_logic_vector(31 downto 0)
    );
end entity;

architecture file_reg_arc of file_reg is
    -- from 0 to 7 => general purpose registers
    -- 8 => pc
    -- 9 => sp
    type reg_type is array (9 downto 0) of std_logic_vector(31 downto 0);
    
    signal registers : reg_type;

    begin
        process (clk) is
            begin
                if rst = '1' then
                    for i in 9 downto 0 loop            
                        registers(i) <= (others => '0');
                    end loop;
                    rd_data1 <= (others => '0');
                    rd_data2 <= (others => '0');
                    sp <= (others => '1');

                elsif rst = '0' then
                    if falling_edge(clk) then
                        -- this two lines might need some look
                        rd_data1 <= registers(to_integer(unsigned(rd_address1)));
                        rd_data2 <= registers(to_integer(unsigned(rd_address2)));
                        -- every write must be in rising edge -- modifie this
                        if reg_wr_sig = '1' then
                            registers(to_integer(unsigned(wr_address1))) <= wr_data;

                        elsif wr_in_pc_sig = '1' then
                            registers(8) <= wr_data;

                        elsif inc_sp = '1' then
                            registers(9) <= std_logic_vector(unsigned(registers(9))+1);

                        elsif dec_sp = '1' then
                            registers(9) <= std_logic_vector(unsigned(registers(9))-1);

                        elsif swap_sig = '1' then
                            registers(to_integer(unsigned(wr_address1))) <= swap_data2;
                            registers(to_integer(unsigned(wr_address2))) <= wr_data;

                        end if;
                    end if;
                end if;

        end process;

end architecture;

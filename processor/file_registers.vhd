LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity file_reg IS
port(
    clk, reg_wr_sig, swap_sig, rst : in  STD_LOGIC;
    rd_address1, rd_address2, R_dst    :   in std_logic_vector(2 downto 0);
    wr_address1, wr_address2  :   in std_logic_vector(2 downto 0);
    wr_data, swap_data2 :   in std_logic_vector(31 downto 0);
    rd_data1, rd_data2, data_branch :   out std_logic_vector(31 downto 0);
    -- these just for testing, delet them after finishing
    R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(31 downto 0) ------------------ testing
    );
end entity;

architecture file_reg_arc of file_reg is
    -- from 0 to 7 => general purpose registers
    -- 8 => sp
    type reg_type is array (8 downto 0) of std_logic_vector(31 downto 0);
    
    signal registers : reg_type;

    begin
        data_branch <= registers(to_integer(unsigned(R_dst)));
        ---------------------- testing ---------------------------------
        R0 <= registers(0);
        R1 <= registers(1);
        R2 <= registers(2);
        R3 <= registers(3);
        R4 <= registers(4);
        R5 <= registers(5);
        R6 <= registers(6);
        R7 <= registers(7);
        ---------------------- testing ---------------------------------
        process (clk) is
            begin
                if rst = '1' then
                    for i in 7 downto 0 loop            
                        registers(i) <= (others => '0');
                    end loop;
                    rd_data1 <= (others => '0');
                    rd_data2 <= (others => '0');

                elsif rst = '0' then
                    if (clk'event and clk='0') then
                        -- this two lines might need some look
                        rd_data1 <= registers(to_integer(unsigned(rd_address1)));
                        rd_data2 <= registers(to_integer(unsigned(rd_address2)));
                        
                    elsif (clk'event and clk='1') then
                                
                        if reg_wr_sig = '1' then
                            registers(to_integer(unsigned(wr_address1))) <= wr_data;

                        elsif swap_sig = '1' then
                            registers(to_integer(unsigned(wr_address1))) <= swap_data2;
                            registers(to_integer(unsigned(wr_address2))) <= wr_data;
                        end if;

                    end if;
                end if;

        end process;

end architecture;

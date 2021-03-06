LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity branch_p is
    port(
        clk, rst :   in std_logic;
        first_four_bits :    in  STD_LOGIC_VECTOR(3 DOWNTO 0);
		last_six_bits :      in  STD_LOGIC_VECTOR(5 DOWNTO 0);
        curr_pc : in std_logic_vector(31 downto 0);
        R_dst : in std_logic_vector(31 downto 0);
        branch : out std_logic
    );
end entity;

architecture branch_p_arc of branch_p is
    signal BE, B, branch_E, branch_seg: std_logic:='0';
    begin
        B <= '1' when first_four_bits = "1111"
        else '0';

        BE <= '1' when last_six_bits = "111000" and B = '1'
        else '0';

        branch_E <= '1' when curr_pc > R_dst and BE = '1'
        else '0';

        branch_seg <= '1' when last_six_bits = "111100" and B ='1'
        else '0';

        branch <= '1' when branch_seg = '1' or branch_E = '1'
        else '0';

        -- process(clk)
        -- begin
	    -- if (rst = '1') then
        --     branch <= '0';
	    -- else
        --     -- if (clk'event and clk='1') then
        --     if (clk='1' or clk='0') then
        --         if first_four_bits = "1111" then
        --             if last_six_bits = "111000" then
        --                 if curr_pc > R_dst then branch <= '1'; else branch <= '0'; end if;
        --             elsif last_six_bits = "111100" then branch <= '1';
        --             else branch <= '0';    
        --             end if;
        --         else branch <= '0';
        --         end if;
        --     end if;
	    -- end if;
        -- end process;

end architecture;
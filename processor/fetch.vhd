LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity fetch is
    port(
        clk, rst, write_in_pc   : in std_logic;
        data_branch, write_data                 : in std_logic_vector(31 downto 0);
        int_address                             : out std_logic_vector(31 downto 0);
        R_dst                                   : out std_logic_vector(2 downto 0);
        IF_ID_instruction                       : out std_logic_vector(15 downto 0);
        IF_ID_pc_incremented                    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture fetch_arc of fetch is
    
    signal instruction : std_logic_vector(15 downto 0):=(others => '0');
    signal branch_seg, e : std_logic:='0';
    signal pc_incremented, init_pc, int_addr, curr_pc, pc_in, pc_data_in, pc_branch_result, pc_dec : std_logic_vector(31 downto 0):=(others => '0');
    

    begin
        inst_mem_com:  entity work.inst_mem port map(clk, rst, curr_pc, instruction, init_pc, int_addr);
        branch_p_com:  entity work.branch_p port map(clk, rst, instruction(15 downto 12), instruction(5 downto 0), curr_pc, data_branch, branch_seg);
        inc_dec_com:  entity work.inc_dec port map('0', '0', curr_pc, pc_incremented);
        pc_register_com:  entity work.pc_register port map(clk, rst, e, pc_data_in, curr_pc);
        dec_com:  entity work.inc_dec port map('1', '0', pc_in, pc_dec);

        e <= '1';


        -- muxes
        pc_data_in <= pc_in when write_in_pc = '0'
        else write_data;

        --pc_data_in <= pc_branch_result when read_same_inst = '0'
        --else pc_dec;


        int_address <= int_addr;
        R_dst <= instruction(11 downto 9);
        
        process(clk)
        begin
            if rst = '1' then
                pc_in <= init_pc;
            
            elsif (rising_edge(CLK)) then
                if branch_seg = '1' then
                    pc_in <= data_branch;
                else
                    pc_in <= pc_incremented;
                end if;

            end if;
        end process;

        IF_ID_instruction <= instruction;
        IF_ID_pc_incremented <= pc_incremented;
end architecture;

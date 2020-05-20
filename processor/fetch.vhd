LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity fetch is
    port(
        clk, rst :   in std_logic;
        data_branch : in std_logic_vector(31 downto 0);
        int_address: out std_logic_vector(31 downto 0);
        R_dst : out std_logic_vector(2 downto 0);
        IF_ID_instruction : out std_logic_vector(15 downto 0);
        IF_ID_pc_incremented : out std_logic_vector(31 downto 0)
    );
end entity;

architecture fetch_arc of fetch is
    component inst_mem is
        port(
            clk, rst :   in std_logic;
            addr : in std_logic_vector(31 downto 0);
            dout : out std_logic_vector(15 downto 0);
            initial_pc, int_address: out std_logic_vector(31 downto 0)
        );
    end component;

    component branch_p is
        port(
            clk, rst :   in std_logic;
            first_four_bits :    in  STD_LOGIC_VECTOR(3 DOWNTO 0);
            last_six_bits :      in  STD_LOGIC_VECTOR(5 DOWNTO 0);
            curr_pc : in std_logic_vector(31 downto 0);
            R_dst : in std_logic_vector(31 downto 0);
            branch : out std_logic
        );
    end component;

    component inc_dec is
        port(
            sel : std_logic;   -- 0 inc, 1 dec
            num : std_logic;   -- 0 by 1, 1 by 2
            A: in std_logic_vector(31 downto 0);
            c: out std_logic_vector(31 downto 0)
            );
    end component;

    component pc_register IS
        PORT( clk, rst, e : IN std_logic;
                d : IN std_logic_vector(31 DOWNTO 0);
                q : OUT std_logic_vector(31 DOWNTO 0)
        );
    end component;
    
    signal instruction : std_logic_vector(15 downto 0);
    signal branch_seg, e : std_logic;
    signal pc_incremented, init_pc, int_addr, curr_pc, pc_in : std_logic_vector(31 downto 0):=(others => '0');
    

    begin
        inst_mem_com: inst_mem port map(clk, rst, curr_pc, instruction, init_pc, int_addr);
        branch_p_com: branch_p port map(clk, rst, instruction(15 downto 12), instruction(5 downto 0), curr_pc, data_branch, branch_seg);
        inc_dec_com: inc_dec port map('0', '0', curr_pc, pc_incremented);
        pc_register_com: pc_register port map(clk, rst, e, pc_in, curr_pc);

        e <= '1';

        -- pc_in <= init_pc when rst = '1'
        -- else data_branch when branch_seg = '1' 
        -- else comp_logic;

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

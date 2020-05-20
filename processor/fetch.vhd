LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity fetch is
    port(
        clk, rst :   in std_logic;
        curr_pc : in std_logic_vector(31 downto 0);
        R_dst, comp_logic : in std_logic_vector(31 downto 0);
        initial_pc, int_address: out std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0);
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
    
    signal instruction : std_logic_vector(15 downto 0);
    signal branch_seg : std_logic;
    signal pc_incremented, pc_val, init_pc, int_addr : std_logic_vector(31 downto 0);
    

    begin
        inst_mem_com: inst_mem port map(clk, rst, curr_pc, instruction, init_pc, int_addr);
        branch_p_com: branch_p port map(clk, rst, instruction(15 downto 12), instruction(5 downto 0), curr_pc, R_dst, branch_seg);
        inc_dec_com: inc_dec port map('0', '0', curr_pc, pc_incremented);

        pc_val <= R_dst when branch_seg = '1' 
        else comp_logic;

        initial_pc <= init_pc;
        int_address <= int_addr;
        
        -- process(clk)
        -- begin
            
        --     if (clk='1') then
        --         IF_ID(15 downto 0) <= instruction;
        --         IF_ID(47 downto 16) <= pc_incremented;

                
        --     end if;
        -- end process;

        IF_ID_instruction <= instruction;
        IF_ID_pc_incremented <= pc_incremented;
        pc_out <= pc_val;
end architecture;

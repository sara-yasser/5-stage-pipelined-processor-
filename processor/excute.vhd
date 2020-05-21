LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity excute is
	port(
        clk, rst                    : in  STD_LOGIC;
        
        ID_EX_registers_addr        : in STD_LOGIC_VECTOR (8  DOWNTO 0);
        ID_EX_b_20_bits             : in STD_LOGIC_VECTOR(19 downto 0);
        ID_EX_r_data2_in            : in STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_r_data1_in            : in STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_sp                    : in STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_pc_inc                : in STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_write_back_signals    : in STD_LOGIC_VECTOR(3 downto 0);
        ID_EX_memory_signals        : in STD_LOGIC_VECTOR(5 downto 0);
        ID_EX_excute_signals        : in STD_LOGIC_VECTOR(9 downto 0);

        res_f                       : in STD_LOGIC;                      -- from write back
        flag_reg                    : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
        in_port                     : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port                    : out STD_LOGIC_VECTOR(31 DOWNTO 0);
        z                           : out  STD_LOGIC;
        
        EX_MEM_registers_addr       : out STD_LOGIC_VECTOR(8 downto 0);
        EX_MEM_r_data1_in           : out STD_LOGIC_VECTOR(31 downto 0);
        EX_MEM_b_20_bits            : out STD_LOGIC_VECTOR(19 downto 0);
        EX_MEM_write_data           : out STD_LOGIC_VECTOR(31 downto 0);
        EX_MEM_alu_out              : out STD_LOGIC_VECTOR(31 downto 0);
        EX_MEM_sp                   : out STD_LOGIC_VECTOR(31 downto 0);
        EX_MEM_in_data              : out STD_LOGIC_VECTOR(31 downto 0);
        EX_MEM_write_back_signals   : out STD_LOGIC_VECTOR(3 downto 0);
        EX_MEM_memory_signals       : out STD_LOGIC_VECTOR(5 downto 0)

	);
end entity;

architecture excute_arc of excute is

    component ALU IS
        PORT(
            ALU_signals : in STD_LOGIC_VECTOR (3  DOWNTO 0);
            a,b : in STD_LOGIC_VECTOR (31  DOWNTO 0);
            flag_in : in STD_LOGIC_VECTOR (2  DOWNTO 0);
            ALU_out : out STD_LOGIC_VECTOR (31 DOWNTO 0);
            flag_out : out STD_LOGIC_VECTOR (2  DOWNTO 0)
            );
    end component;

    component sign_extend is
        port(
            A: in std_logic_vector(15 downto 0);
            c: out std_logic_vector(31 downto 0)
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

    component CCR IS       -- flag reg
    port(
        clk, rst :   in  STD_LOGIC;
        input_vec   :   in std_logic_vector(2 downto 0);
        output_vec  :   out std_logic_vector(2 downto 0)

        );
    end component;

    signal sign_extend_in : std_logic_vector(15 downto 0);
    signal sign_extend_out, r_data1_in, r_data2_in, alu1_in, alu2_in, alu_out, sp, pc_inc, pc, write_data, flag_reg_out, in_data, out_data : std_logic_vector(31 downto 0);
    signal src1, src2, in_seg, out_seg : std_logic;
    signal ALU_signals : std_logic_vector(3 downto 0);
    signal flag_in, flag_out, flag_reg_in : std_logic_vector(2 downto 0);

    signal b_20_bits : std_logic_vector(19 downto 0);
    signal excute_signals :      STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal memory_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal write_back_signals :  STD_LOGIC_VECTOR(3 DOWNTO 0);

    signal WDS :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    
begin
    sign_extend_com: sign_extend port map(sign_extend_in, sign_extend_out);
    inc_dec_com: inc_dec port map('1','0',pc_inc, pc);
    ALU_com: ALU port map(ALU_signals, alu1_in, alu2_in, flag_in, alu_out, flag_out);
    CCR_com: CCR port map(clk, rst, flag_reg_in, flag_in);
    -- initializations
    b_20_bits          <= ID_EX_b_20_bits;
    r_data2_in         <= ID_EX_r_data2_in;
    r_data1_in         <= ID_EX_r_data1_in;
    sp                 <= ID_EX_sp;
    pc_inc             <= ID_EX_pc_inc;
    write_back_signals <= ID_EX_write_back_signals;
    memory_signals     <= ID_EX_memory_signals;
    excute_signals     <= ID_EX_excute_signals;

    sign_extend_in <= b_20_bits(19 downto 4);
    flag_reg_out(31 downto 3) <= (others => '0');
    flag_reg_out(2 downto 0) <= flag_in;

    in_seg <= excute_signals(9);
    out_seg <= excute_signals(8);
    WDS <= excute_signals(7 downto 6);
    src1 <= excute_signals(5);
    src2 <= excute_signals(4);
    ALU_signals <= excute_signals(3 downto 0);

    -- muxes
    alu1_in <= r_data1_in when src1 = '0'
    else sign_extend_out;

    alu2_in <= r_data2_in when src2 = '0'
    else sign_extend_out;

    flag_reg_in <= flag_out when res_f = '0'
    else flag_reg(2 downto 0);

    write_data <= r_data2_in when WDS = "00"
    else pc when WDS = "01"
    else pc_inc when WDS = "10"
    else flag_reg_out;

    -- in port
    in_data <= in_port when in_seg = '1'
    else (others => '0');

    -- out port
    out_data <= alu2_in when out_seg = '1'
    else (others => '0');

    -- zero flag
    z <= flag_out(0);

    EX_MEM_registers_addr     <= ID_EX_registers_addr;
    EX_MEM_r_data1_in         <= r_data1_in;
    EX_MEM_b_20_bits          <= b_20_bits;
    EX_MEM_write_data         <= write_data;
    EX_MEM_alu_out            <= alu_out;
    EX_MEM_sp                 <= sp;
    EX_MEM_in_data            <= in_data;
    EX_MEM_write_back_signals <= write_back_signals;
    EX_MEM_memory_signals     <= memory_signals;
    out_port <= out_data;

    -- process (clk) is
    --     begin
    --         if rst = '1' then
    --             EX_MEM <= (others => '0');
    --             out_port <= (others => '0');
    --         else
    --             if falling_edge(clk) then
    --                 EX_MEM_registers_addr <= ID_EX_registers_addr;
    --                 EX_MEM(40 downto 9) <= r_data1_in;
    --                 EX_MEM(60 downto 41) <= b_20_bits;
    --                 EX_MEM(92 downto 61) <= write_data;
    --                 EX_MEM(124 downto 93) <= alu_out;
    --                 EX_MEM(156 downto 125) <= sp;
    --                 EX_MEM(188 downto 157) <= in_data;
    --                 EX_MEM(192 downto 189) <= write_back_signals;
    --                 EX_MEM(198 downto 193) <= memory_signals;
    --                 out_port <= out_data;
    --             end if;
    --         end if;
    --     end process;

end architecture;

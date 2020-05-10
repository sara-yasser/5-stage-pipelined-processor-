LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity excute is
	port(
		clk :                in  STD_LOGIC;
        ID_EX :              in STD_LOGIC_VECTOR (176  DOWNTO 0);
        rst :                in STD_LOGIC;
        res_f :              in STD_LOGIC;                      -- from write back
        flag_reg             in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
        in_port              in STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port             out STD_LOGIC_VECTOR(31 DOWNTO 0);
        EX_MEM :             out STD_LOGIC_VECTOR (198 DOWNTO 0)
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
    signal sign_extend_out, r_data1_in, r_data2_in, alu1_in, alu2_in, alu_out, sp, pc_inc, pc, write_data, flag_reg_out : std_logic_vector(31 downto 0);
    signal src1, src2 : std_logic;
    signal ALU_signals : std_logic_vector(3 downto 0);
    signal flag_in, flag_out, flag_reg_in : std_logic_vector(2 downto 0);
    signal 20_bits : std_logic_vector(19 downto 0);

    signal excute_signals :      STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal memory_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal write_back_signals :  STD_LOGIC_VECTOR(3 DOWNTO 0);

    signal WDS :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    
begin
    sign_extend_com: sign_extend port map(sign_extend_in, sign_extend_out);
    inc_dec_com: inc_dec port map(pc_inc, pc);
    ALU_com: ALU port map(ALU_signals, alu1_in, alu2_in, flag_in, alu_out, flag_out);
    CCR_com: CCR port map(clk, rst, flag_reg_in, flag_in);
    -- initializations
    20_bits            <= ID_EX(28 downto 9);
    r_data2_in         <= ID_EX(60 downto 29);
    r_data1_in         <= ID_EX(92 downto 61);
    sp                 <= ID_EX(124 downto 93);
    pc_inc             <= ID_EX(156 downto 125);
    write_back_signals <= ID_EX(160 downto 157);
    memory_signals     <= ID_EX(166 downto 161);
    excute_signals     <= ID_EX(176 downto 167);

    sign_extend_in <= 20_bits(19 downto 4);
    flag_reg_out(31 downto 3) <= (others => '0');
    flag_reg_out(2 downto 0) <= flag_in;

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

end architecture;

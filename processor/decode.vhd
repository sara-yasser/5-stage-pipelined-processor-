LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity decode IS
    PORT(
        clk                         : in  STD_LOGIC;
        rst, inc_sp, dec_sp, z      : in STD_LOGIC;
        WB_signals                  : in STD_LOGIC_VECTOR(1 DOWNTO 0);   -- from write back
        w_addr1, w_addr2            : in STD_LOGIC_VECTOR(2 DOWNTO 0);   -- from write back
        w_data1, w_data2            : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
        R_dst                       : in STD_LOGIC_VECTOR(2 DOWNTO 0);

        IF_ID_instruction           : in std_logic_vector(15 downto 0);
        IF_ID_pc_incremented        : in std_logic_vector(31 downto 0);

        data_branch                 : out STD_LOGIC_VECTOR(31 downto 0);

        ID_EX_dst_src               : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_src2                  : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_src1                  : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_decoder_out           : out STD_LOGIC_VECTOR(19 downto 0);
        ID_EX_rd_data2              : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_rd_data1              : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_sp                    : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_pc                    : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_write_back_signals    : out STD_LOGIC_VECTOR(3 downto 0);
        ID_EX_memory_signals        : out STD_LOGIC_VECTOR(5 downto 0);
        ID_EX_excute_signals        : out STD_LOGIC_VECTOR(9 downto 0)
        );
end entity;

architecture decode_arc of decode is
    component control_unit IS
    port(
        clk, rst :           in  STD_LOGIC;
		first_four_bits :    in  STD_LOGIC_VECTOR(3 DOWNTO 0);
		last_six_bits :      in  STD_LOGIC_VECTOR(5 DOWNTO 0);
		decode_signals :     out STD_LOGIC_VECTOR(4 DOWNTO 0);
		excute_signals :     out STD_LOGIC_VECTOR(9 DOWNTO 0);
		memory_signals :     out STD_LOGIC_VECTOR(5 DOWNTO 0);
		write_back_signals : out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;

    component decoder IS
    port(
		clk, rst, E, T, C :          in  STD_LOGIC;
		data_in :      in  STD_LOGIC_VECTOR(11 DOWNTO 0);
		data_out :     out STD_LOGIC_VECTOR(19 DOWNTO 0)
        );
    end component;

    component file_reg IS
    port(
        clk, reg_wr_sig, swap_sig, rst, inc_sp, dec_sp : in  STD_LOGIC;
        rd_address1, rd_address2, R_dst    :   in std_logic_vector(2 downto 0);
        wr_address1, wr_address2  :   in std_logic_vector(2 downto 0);
        wr_data, swap_data2 :   in std_logic_vector(31 downto 0);
        rd_data1, rd_data2, data_branch, sp  :   out std_logic_vector(31 downto 0)
        );
    end component;

signal last_6_bits : STD_LOGIC_VECTOR(5 DOWNTO 0);
signal op_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal dst_src, src1, src2, ETC : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal IMM_EA : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal src, BE, branch_seg : STD_LOGIC:= '0';  -- need to look at later

signal decode_signals :      STD_LOGIC_VECTOR(4 DOWNTO 0);
signal excute_signals :      STD_LOGIC_VECTOR(9 DOWNTO 0);
signal memory_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
signal write_back_signals :  STD_LOGIC_VECTOR(3 DOWNTO 0);

signal decoder_out :  STD_LOGIC_VECTOR(19 DOWNTO 0);

signal read_addr2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal rd_data1, rd_data2, sp, IF_ID_pc, ID_EX_pc_in : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin
    control_unit_com: control_unit port map (clk, rst, op_code, last_6_bits, decode_signals, excute_signals, memory_signals, 
                                            write_back_signals);

    decoder_com: decoder port map           (clk, rst, ETC(2), ETC(1), ETC(0), IMM_EA, decoder_out);
    
    file_reg_com: file_reg port map         (clk, WB_signals(1), WB_signals(0), rst, inc_sp, dec_sp, src1, read_addr2, 
                                            R_dst, w_addr1, w_addr2, w_data1, w_data2, rd_data1, rd_data2, 
                                            data_branch, sp);

    --intializations
    last_6_bits <=   IF_ID_instruction (5 downto 0);
    op_code     <=   IF_ID_instruction (15 downto 12);
    dst_src     <=   IF_ID_instruction (11 downto 9);
    src1        <=   IF_ID_instruction (8 downto 6);
    src2        <=   IF_ID_instruction (5 downto 3);
    IMM_EA      <=   IF_ID_instruction (11 downto 0);
    IF_ID_pc    <=   IF_ID_pc_incremented;

    ETC         <=   decode_signals (2 downto 0);
    src         <=   decode_signals (3);
    BE          <=   decode_signals (4);


    -- muxes
    read_addr2 <= src2 when src = '0'
    else dst_src;

    ID_EX_pc_in <= rd_data2 when branch_seg = '1'
    else IF_ID_pc;

    -- and gate
    branch_seg <= z and BE;
    -- out buff

    ID_EX_dst_src            <= dst_src;
    ID_EX_src2               <= src2;
    ID_EX_src1               <= src1;
    ID_EX_decoder_out        <= decoder_out;
    ID_EX_rd_data2           <= rd_data2;
    ID_EX_rd_data1           <= rd_data1;
    ID_EX_sp                 <= sp;
    ID_EX_pc                 <= ID_EX_pc_in;
    ID_EX_write_back_signals <= write_back_signals;
    ID_EX_memory_signals     <= memory_signals;
    ID_EX_excute_signals     <= excute_signals;

    -- process (clk) is
    -- begin
    --     if rst = '1' then
    --         ID_EX <= (others => '0');
    --     else
    --         if falling_edge(clk) then
    --             ID_EX(2 downto 0) <= dst_src;
    --             ID_EX(5 downto 3) <= src2;
    --             ID_EX(8 downto 6) <= src1;
    --             ID_EX(28 downto 9) <= decoder_out;
    --             ID_EX(60 downto 29) <= rd_data2;
    --             ID_EX(92 downto 61) <= rd_data1;
    --             ID_EX(124 downto 93) <= sp;
    --             ID_EX(156 downto 125) <= pc;
    --             ID_EX(160 downto 157) <= write_back_signals;
    --             ID_EX(166 downto 161) <= memory_signals;
    --             ID_EX(176 downto 167) <= excute_signals;
    --         end if;
    --     end if;
    -- end process;

end architecture;
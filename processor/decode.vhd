LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity decode IS
    PORT(
        clk                         : in  STD_LOGIC;
        rst, z      : in STD_LOGIC;
        WB_signals                  : in STD_LOGIC_VECTOR(1 DOWNTO 0);   -- from write back
        w_addr1, w_addr2            : in STD_LOGIC_VECTOR(2 DOWNTO 0);   -- from write back
        w_data1, w_data2            : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
        R_dst                       : in STD_LOGIC_VECTOR(2 DOWNTO 0);

        IF_ID_instruction           : in std_logic_vector(15 downto 0);
        IF_ID_pc_incremented        : in std_logic_vector(31 downto 0);

        data_branch_out             : out STD_LOGIC_VECTOR(31 downto 0);
        branch_seg_out              : out STD_LOGIC;

        ID_EX_dst_src               : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_src2                  : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_src1                  : out STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_decoder_out           : out STD_LOGIC_VECTOR(19 downto 0);
        ID_EX_rd_data2              : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_rd_data1              : out STD_LOGIC_VECTOR(31 downto 0);
        -- ID_EX_sp                    : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_pc                    : out STD_LOGIC_VECTOR(31 downto 0);
        ID_EX_write_back_signals    : out STD_LOGIC_VECTOR(3 downto 0);
        ID_EX_memory_signals        : out STD_LOGIC_VECTOR(5 downto 0);
        ID_EX_excute_signals        : out STD_LOGIC_VECTOR(9 downto 0);
        -- these just for testing, delet them after finishing
        R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(31 downto 0) ------------------ testing
        );
end entity;

architecture decode_arc of decode is

signal last_6_bits : STD_LOGIC_VECTOR(5 DOWNTO 0);
signal op_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal dst_src, src1, src2, ETC : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal IMM_EA : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal src, BE, B, branch_seg : STD_LOGIC:= '0';  -- need to look at later

signal decode_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
signal excute_signals :      STD_LOGIC_VECTOR(9 DOWNTO 0);
signal memory_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
signal write_back_signals :  STD_LOGIC_VECTOR(3 DOWNTO 0);

signal decoder_out :  STD_LOGIC_VECTOR(19 DOWNTO 0);

signal read_addr2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal rd_data1, rd_data2, sp, IF_ID_pc, ID_EX_pc_in, data_branch : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin
    control_unit_com:  entity work.control_unit port map (clk, rst, op_code, last_6_bits, decode_signals, excute_signals, memory_signals, 
                                            write_back_signals);

    decoder_com:  entity work.decoder port map           (clk, rst, ETC(2), ETC(1), ETC(0), IMM_EA, decoder_out);
    
    file_reg_com:  entity work.file_reg port map         (clk, WB_signals(1), WB_signals(0), rst, src1, read_addr2, 
                                            R_dst, w_addr1, w_addr2, w_data1, w_data2, rd_data1, rd_data2, 
                                            data_branch,
                                            -- these just for testing, delet them after finishing
                                            R0, R1, R2, R3, R4, R5, R6, R7 ------------------ testing
                                            );

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
    B           <=   decode_signals (5);


    data_branch_out <= data_branch;
    branch_seg_out <= branch_seg;
    -- muxes
    read_addr2 <= src2 when src = '0'
    else dst_src;

    -- ID_EX_pc_in <= data_branch when branch_seg = '1'
    -- else IF_ID_pc;

    -- branch signal
    branch_seg <= (z and BE) or B;
    -- out buff

    ID_EX_dst_src            <= dst_src;
    ID_EX_src2               <= read_addr2;
    ID_EX_src1               <= src1;
    ID_EX_decoder_out        <= decoder_out;
    ID_EX_rd_data2           <= rd_data2;
    ID_EX_rd_data1           <= rd_data1;
    ID_EX_pc                 <= IF_ID_pc;
    ID_EX_write_back_signals <= write_back_signals;
    ID_EX_memory_signals     <= memory_signals;
    ID_EX_excute_signals     <= excute_signals;

end architecture;
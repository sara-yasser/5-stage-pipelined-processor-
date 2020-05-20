LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity pipeline IS
port(
    clk, rst :                   in  STD_LOGIC;
    -- in_port : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- out_port : out STD_LOGIC_VECTOR(31 DOWNTO 0)
    inc_sp_in, dec_sp_in, z, write_in_pc_in : in STD_LOGIC;        -- remove this
    WB_signals_in : in STD_LOGIC_VECTOR(1 DOWNTO 0);      -- from write back
    w_addr1_in, w_addr2_in : in STD_LOGIC_VECTOR(2 DOWNTO 0);   -- from write back
    w_data1_in, w_data2_in : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
    interrupt : out STD_LOGIC_VECTOR(31 DOWNTO 0)  -- remove this
    );
end entity;

architecture pipeline_arc of pipeline is
    component fetch is
        port(
            clk, rst, write_in_pc   : in std_logic;
            data_branch, write_data : in std_logic_vector(31 downto 0);
            int_address             : out std_logic_vector(31 downto 0);
            R_dst                   : out std_logic_vector(2 downto 0);
            IF_ID_instruction       : out std_logic_vector(15 downto 0);
            IF_ID_pc_incremented    : out std_logic_vector(31 downto 0)
        );
    end component;

    component IF_ID_buff IS
        port(
            clk, rst, stall_sig :    in  STD_LOGIC;
            input_vec   :            in std_logic_vector(47 downto 0);
            output_vec  :            out std_logic_vector(47 downto 0)
            );
    end component;

    component decode is
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
    end component;

    component stage_buff IS
        generic (n : integer := 32);
        port(
            clk, rst, stall_sig :    in  STD_LOGIC;
            input_vec   :            in std_logic_vector(n - 1 downto 0);
            output_vec  :            out std_logic_vector(n - 1 downto 0)
            );
    end component;

    component excute is
        port(
            clk, rst                  : in  STD_LOGIC;
            
            ID_EX_registers_addr      : in STD_LOGIC_VECTOR (8  DOWNTO 0);
            ID_EX_b_20_bits           : in STD_LOGIC_VECTOR(19 downto 0);
            ID_EX_r_data2_in          : in STD_LOGIC_VECTOR(31 downto 0);
            ID_EX_r_data1_in          : in STD_LOGIC_VECTOR(31 downto 0);
            ID_EX_sp                  : in STD_LOGIC_VECTOR(31 downto 0);
            ID_EX_pc_inc              : in STD_LOGIC_VECTOR(31 downto 0);
            ID_EX_write_back_signals  : in STD_LOGIC_VECTOR(3 downto 0);
            ID_EX_memory_signals      : in STD_LOGIC_VECTOR(5 downto 0);
            ID_EX_excute_signals      : in STD_LOGIC_VECTOR(9 downto 0);

            res_f                     : in STD_LOGIC;                      -- from write back
            flag_reg                  : in STD_LOGIC_VECTOR(31 DOWNTO 0);  -- from write back
            in_port                   : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_port                  : out STD_LOGIC_VECTOR(31 DOWNTO 0);
            
            EX_MEM_registers_addr     : out STD_LOGIC_VECTOR(8 downto 0);
            EX_MEM_r_data1_in         : out STD_LOGIC_VECTOR(31 downto 0);
            EX_MEM_b_20_bits          : out STD_LOGIC_VECTOR(19 downto 0);
            EX_MEM_write_data         : out STD_LOGIC_VECTOR(31 downto 0);
            EX_MEM_alu_out            : out STD_LOGIC_VECTOR(31 downto 0);
            EX_MEM_sp                 : out STD_LOGIC_VECTOR(31 downto 0);
            EX_MEM_in_data            : out STD_LOGIC_VECTOR(31 downto 0);
            EX_MEM_write_back_signals : out STD_LOGIC_VECTOR(3 downto 0);
            EX_MEM_memory_signals     : out STD_LOGIC_VECTOR(5 downto 0)

        );
    end component;

    component mem is
        port(
            clk, rst                  :   in std_logic;

            EX_MEM_first_40_bits      : in std_logic_vector(40 DOWNTO 0);
            EX_MEM_b_20_bits          : in std_logic_vector(19 downto 0);
            EX_MEM_data_mem_in        : in std_logic_vector(31 downto 0);
            EX_MEM_ALU_out            : in std_logic_vector(31 downto 0);
            EX_MEM_sp                 : in std_logic_vector(31 downto 0);
            EX_MEM_in_port_data       : in std_logic_vector(31 downto 0);
            EX_MEM_write_back_signals : in std_logic_vector(3 downto 0);
            EX_MEM_memory_signals     : in std_logic_vector(5 downto 0);

            inc_sp, dec_sp            : out std_logic;
            
            MEM_WB_first_40_bits      : out std_logic_vector(40 downto 0);
            MEM_WB_wb_result          : out std_logic_vector(31 downto 0);
            MEM_WB_write_back_signals : out std_logic_vector(3 downto 0)
        );
    end component;

    -- buffers
        signal IF_ID_in, IF_ID_out   : std_logic_vector(47 downto 0):=(others => '0');
        signal ID_EX_in, ID_EX_out   : std_logic_vector(176  DOWNTO 0):=(others => '0');
        signal EX_MEM_in, EX_MEM_out : std_logic_vector(198 downto 0):=(others => '0');
        signal MEM_WB_in, MEM_WB_out : std_logic_vector(76  DOWNTO 0):=(others => '0');

    --fetch
        signal pc_out, IF_ID_in_pc_incremented : std_logic_vector(31 downto 0):=(others => '0');
        signal IF_ID_in_instruction : std_logic_vector(15 downto 0):=(others => '0');

    -- IF/ID
        signal stall_IF_ID : std_logic:='0';

    -- decode
        signal IF_ID_out_pc_incremented : std_logic_vector(31 downto 0):=(others => '0');
        signal IF_ID_out_instruction : std_logic_vector(15 downto 0):=(others => '0');

        signal ID_EX_in_dst_src            : STD_LOGIC_VECTOR(2 downto 0):=(others => '0');
        signal ID_EX_in_src2               : STD_LOGIC_VECTOR(2 downto 0):=(others => '0');
        signal ID_EX_in_src1               : STD_LOGIC_VECTOR(2 downto 0):=(others => '0');
        signal ID_EX_in_decoder_out        : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal ID_EX_in_rd_data2           : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_in_rd_data1           : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_in_sp                 : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_in_pc                 : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_in_write_back_signals : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal ID_EX_in_memory_signals     : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');
        signal ID_EX_in_excute_signals     : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');

    -- execute
        signal res_f                            : STD_LOGIC:='0';                      -- from write back
        signal flag_reg                         : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');  -- from write back
        signal in_port_data                     : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');
        signal out_port_data                    : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');

        signal ID_EX_out_registers_addr         : STD_LOGIC_VECTOR (8  DOWNTO 0):=(others => '0');
        signal ID_EX_out_b_20_bits              : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal ID_EX_out_r_data2_in             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_out_r_data1_in             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_out_sp                     : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_out_pc_inc                 : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_out_write_back_signals     : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal ID_EX_out_memory_signals         : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');
        signal ID_EX_out_excute_signals         : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');

        signal EX_MEM_in_registers_addr         : STD_LOGIC_VECTOR(8 downto 0):=(others => '0');
        signal EX_MEM_in_r_data1_in             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_b_20_bits              : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal EX_MEM_in_write_data             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_alu_out                : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_sp                     : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_in_data                : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_write_back_signals     : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal EX_MEM_in_memory_signals         : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');

    -- memory
        signal EX_MEM_out_first_40_bits         : STD_LOGIC_VECTOR(40 downto 0):=(others => '0');
        signal EX_MEM_out_b_20_bits             : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal EX_MEM_out_data_mem_in           : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_out_ALU_out               : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_out_sp                    : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_out_in_port_data          : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_out_write_back_signals    : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal EX_MEM_out_memory_signals        : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');

        signal MEM_WB_in_first_40_bits          : std_logic_vector(40 downto 0):=(others => '0');
        signal MEM_WB_in_wb_result              : std_logic_vector(31 downto 0):=(others => '0');
        signal MEM_WB_in_write_back_signals     : std_logic_vector(3 downto 0):=(others => '0');

    -- write back
        signal w_addr1, w_addr2 : STD_LOGIC_VECTOR(2 DOWNTO 0):=(others => '0');
        signal w_data1, w_data2 : STD_LOGIC_VECTOR(31 DOWNTO 0):=(others => '0');

    -- general
        signal stall, inc_sp, dec_sp, write_in_pc : std_logic:='0';
        signal curr_pc_ID, curr_pc_IF : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal data_branch, int_address, write_data  : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal R_dst : STD_LOGIC_VECTOR(2 downto 0);
        signal WB_signals : STD_LOGIC_VECTOR(1 downto 0);

    begin
        fetch_com      : fetch                          port map(clk, rst, write_in_pc, data_branch, write_data, int_address,
                                                        R_dst, IF_ID_in_instruction, IF_ID_in_pc_incremented);
        IF_ID_buff_com : IF_ID_buff                     port map(clk, rst, stall_IF_ID, IF_ID_in, IF_ID_out);
        decode_com     : decode                         port map(clk, rst, inc_sp, dec_sp, z, WB_signals, w_addr1, w_addr2, 
                                                        w_data1, w_data2, R_dst,
                                                        IF_ID_out_instruction, IF_ID_out_pc_incremented, data_branch,
                                                        ID_EX_in_dst_src, ID_EX_in_src2, ID_EX_in_src1, ID_EX_in_decoder_out,
                                                        ID_EX_in_rd_data2, ID_EX_in_rd_data1, ID_EX_in_sp, ID_EX_in_pc,
                                                        ID_EX_in_write_back_signals, ID_EX_in_memory_signals, ID_EX_in_excute_signals);
        ID_EX_buff_com : stage_buff generic map (177)   port map(clk, rst, stall, ID_EX_in, ID_EX_out);
        
        -- comminting the rest to test fetch and decode only
            -- excute_com     : excute                         port map(clk, rst, ID_EX_out_registers_addr, ID_EX_out_b_20_bits, ID_EX_out_r_data2_in,
            --                                                 ID_EX_out_r_data1_in, ID_EX_out_sp, ID_EX_out_pc_inc, ID_EX_out_write_back_signals,
            --                                                 ID_EX_out_memory_signals, ID_EX_out_excute_signals,
            --                                                 res_f, flag_reg, in_port_data, out_port_data,
            --                                                 EX_MEM_in_registers_addr, EX_MEM_in_r_data1_in, EX_MEM_in_b_20_bits,
            --                                                 EX_MEM_in_write_data, EX_MEM_in_alu_out, EX_MEM_in_sp, EX_MEM_in_in_data,
            --                                                 EX_MEM_in_write_back_signals, EX_MEM_in_memory_signals);
            -- EX_MEM_buff_com: stage_buff generic map (199)   port map(clk, rst, stall, EX_MEM_in, EX_MEM_out);
            -- mem_com        : mem                            port map(clk, rst, EX_MEM_out_first_40_bits, EX_MEM_out_b_20_bits,
            --                                                 EX_MEM_out_data_mem_in, EX_MEM_out_ALU_out, EX_MEM_out_sp, EX_MEM_out_in_port_data,
            --                                                 EX_MEM_out_write_back_signals, EX_MEM_out_memory_signals,
            --                                                 inc_sp, dec_sp,
            --                                                 MEM_WB_in_first_40_bits, MEM_WB_in_wb_result, MEM_WB_in_write_back_signals);

            -- MEM_WB_buff_com: stage_buff generic map (77)    port map(clk, rst, stall, MEM_WB_in, MEM_WB_out);
        
        -- IF_ID in buff
            IF_ID_in(15 downto 0) <= IF_ID_in_instruction;
            IF_ID_in(47 downto 16) <= IF_ID_in_pc_incremented;

        -- IF_ID out buff
            IF_ID_out_instruction <= IF_ID_out(15 downto 0);
            IF_ID_out_pc_incremented <= IF_ID_out(47 downto 16);

        -- ID_EX in buff
            ID_EX_in(2 downto 0)            <= ID_EX_in_dst_src;
            ID_EX_in(5 downto 3)            <= ID_EX_in_src2;
            ID_EX_in(8 downto 6)            <= ID_EX_in_src1;
            ID_EX_in(28 downto 9)           <= ID_EX_in_decoder_out;
            ID_EX_in(60 downto 29)          <= ID_EX_in_rd_data2;
            ID_EX_in(92 downto 61)          <= ID_EX_in_rd_data1;
            ID_EX_in(124 downto 93)         <= ID_EX_in_sp;
            ID_EX_in(156 downto 125)        <= ID_EX_in_pc;
            ID_EX_in(160 downto 157)        <= ID_EX_in_write_back_signals;
            ID_EX_in(166 downto 161)        <= ID_EX_in_memory_signals;
            ID_EX_in(176 downto 167)        <= ID_EX_in_excute_signals;


        -- comminting the rest to test fetch and decode only

            -- -- ID_EX out buff
            --     ID_EX_out_registers_addr        <= ID_EX_out(8  DOWNTO 0);
            --     ID_EX_out_b_20_bits             <= ID_EX_out(28 downto 9);
            --     ID_EX_out_r_data2_in            <= ID_EX_out(60 downto 29);
            --     ID_EX_out_r_data1_in            <= ID_EX_out(92 downto 61);
            --     ID_EX_out_sp                    <= ID_EX_out(124 downto 93);
            --     ID_EX_out_pc_inc                <= ID_EX_out(156 downto 125);
            --     ID_EX_out_write_back_signals    <= ID_EX_out(160 downto 157);
            --     ID_EX_out_memory_signals        <= ID_EX_out(166 downto 161);
            --     ID_EX_out_excute_signals        <= ID_EX_out(176 downto 167);

            -- -- EX_MEM in buff
            --     EX_MEM_in(8 downto 0)           <= EX_MEM_in_registers_addr;
            --     EX_MEM_in(40 downto 9)          <= EX_MEM_in_r_data1_in;
            --     EX_MEM_in(60 downto 41)         <= EX_MEM_in_b_20_bits;
            --     EX_MEM_in(92 downto 61)         <= EX_MEM_in_write_data;
            --     EX_MEM_in(124 downto 93)        <= EX_MEM_in_alu_out;
            --     EX_MEM_in(156 downto 125)       <= EX_MEM_in_sp;
            --     EX_MEM_in(188 downto 157)       <= EX_MEM_in_in_data;
            --     EX_MEM_in(192 downto 189)       <= EX_MEM_in_write_back_signals;
            --     EX_MEM_in(198 downto 193)       <= EX_MEM_in_memory_signals;

            -- -- EX_MEM out buff
            --     EX_MEM_out_first_40_bits        <= EX_MEM_out(40 downto 0);
            --     EX_MEM_out_b_20_bits            <= EX_MEM_out(60 downto 41);
            --     EX_MEM_out_data_mem_in          <= EX_MEM_out(92 downto 61);
            --     EX_MEM_out_ALU_out              <= EX_MEM_out(124 downto 93);
            --     EX_MEM_out_sp                   <= EX_MEM_out(156 downto 125);
            --     EX_MEM_out_in_port_data         <= EX_MEM_out(188 downto 157);
            --     EX_MEM_out_write_back_signals   <= EX_MEM_out(192 downto 189);
            --     EX_MEM_out_memory_signals       <= EX_MEM_out(198 downto 193);

            -- -- MEM_WB in buff
            --     MEM_WB_in(40 downto 0) <= MEM_WB_in_first_40_bits;
            --     MEM_WB_in(72 downto 41) <= MEM_WB_in_wb_result;
            --     MEM_WB_in(76 downto 73) <= MEM_WB_in_write_back_signals;


        


        
        -- testing part will be removed
        interrupt <= int_address;
        inc_sp <= inc_sp_in;
        dec_sp <= dec_sp_in;
        WB_signals <= WB_signals_in;
        write_in_pc <= write_in_pc_in;

        w_addr1 <= w_addr1_in;
        w_addr2 <= w_addr2_in;
        w_data1 <= w_data1_in;
        w_data2 <= w_data2_in;

end architecture;


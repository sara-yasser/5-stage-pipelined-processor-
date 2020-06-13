LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity pipeline IS
port(
    clk, rst, forward_E, hazard_E, interrupt_sig, read_same_inst :                   in  STD_LOGIC;
    in_port : in STD_LOGIC_VECTOR(31 DOWNTO 0);
    out_port : out STD_LOGIC_VECTOR(31 DOWNTO 0);
    interrupt : out STD_LOGIC_VECTOR(31 DOWNTO 0)  -- remove this
    );
end entity;

architecture pipeline_arc of pipeline is

    -- buffers
        signal IF_ID_in, IF_ID_out   : std_logic_vector(47 downto 0):=(others => '0');
        signal ID_EX_in, ID_EX_out   : std_logic_vector(144  DOWNTO 0):=(others => '0');
        signal EX_MEM_in, EX_MEM_out : std_logic_vector(166 downto 0):=(others => '0');
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
        signal ID_EX_out_pc_inc                 : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal ID_EX_out_write_back_signals     : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal ID_EX_out_memory_signals         : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');
        signal ID_EX_out_excute_signals         : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');

        signal EX_MEM_in_registers_addr         : STD_LOGIC_VECTOR(8 downto 0):=(others => '0');
        signal EX_MEM_in_r_data1_in             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_b_20_bits              : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal EX_MEM_in_write_data             : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_alu_out                : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_in_data                : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_in_write_back_signals     : STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
        signal EX_MEM_in_memory_signals         : STD_LOGIC_VECTOR(5 downto 0):=(others => '0');

    -- memory
        signal EX_MEM_out_first_40_bits         : STD_LOGIC_VECTOR(40 downto 0):=(others => '0');
        signal EX_MEM_out_b_20_bits             : STD_LOGIC_VECTOR(19 downto 0):=(others => '0');
        signal EX_MEM_out_data_mem_in           : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal EX_MEM_out_ALU_out               : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
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
        signal stall, write_in_pc, z : std_logic:='0';
        signal curr_pc_ID, curr_pc_IF : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal data_branch, int_address  : STD_LOGIC_VECTOR(31 downto 0):=(others => '0');
        signal R_dst : STD_LOGIC_VECTOR(2 downto 0);
        signal WB_signals : STD_LOGIC_VECTOR(1 downto 0);

    -- forwarding unit
        signal forward_enable : std_logic:= '0';
        signal F_mem_to_IF, F_WB_to_IF, F_MEM_to_EX1, F_WB_to_EX1, F_MEM_to_EX2, F_WB_to_EX2: std_logic:= '0';
        signal IF_op_code  : STD_LOGIC_VECTOR(3 downto 0);
        signal IF_last_6_bits : STD_LOGIC_VECTOR(5 downto 0);
        signal IF_Rdst, EX_src2, EX_src1, EX_dst, MEM_dst, MEM_src, WB_dst : STD_LOGIC_VECTOR(2 downto 0);
        signal EX_MR, EX_read_from_stack, MEM_RW, MEM_swap, MEM_MR, WB_RW : std_logic;
        signal MEM_WB_seg : STD_LOGIC_VECTOR(1 downto 0);

        signal F_src1_sel, F_src2_sel                  : STD_LOGIC_VECTOR(1 downto 0);

        signal F_WB_in, F_WB_out : STD_LOGIC_VECTOR(35 downto 0);
        signal temp_data : STD_LOGIC_VECTOR(31 downto 0);

    -- hazard
        signal dec_stall, hazard_enable, EX_RW : std_logic:='0';
        signal stall_int : integer:=0;
    -- these just for testing, delet them after finishing
        signal R0, R1, R2, R3, R4, R5, R6, R7, sp : std_logic_vector(31 downto 0); ------------------ testing
        signal flags_z_n_c : STD_LOGIC_VECTOR(2 downto 0); ------------------ testing
        signal inc_sp, dec_sp : std_logic;

    begin
        
        fetch_com      :  entity work.fetch port map(                        
            clk, rst, write_in_pc, read_same_inst, data_branch, w_data1, int_address,
            R_dst, IF_ID_in_instruction, IF_ID_in_pc_incremented
            );
        IF_ID_buff_com :  entity work.IF_ID_buff port map(
            clk, rst, read_same_inst, IF_ID_in, IF_ID_out
            );

        decode_com     :  entity work.decode port map(
            clk, rst, z, WB_signals, w_addr1, w_addr2, w_data1, w_data2, R_dst, IF_ID_out_instruction, IF_ID_out_pc_incremented, 
            data_branch, ID_EX_in_dst_src, ID_EX_in_src2, ID_EX_in_src1, ID_EX_in_decoder_out, ID_EX_in_rd_data2, ID_EX_in_rd_data1, 
            ID_EX_in_pc, ID_EX_in_write_back_signals, ID_EX_in_memory_signals, ID_EX_in_excute_signals,
            -- these just for testing, delet them after finishing
            R0, R1, R2, R3, R4, R5, R6, R7 ------------------ testing
            );
        ID_EX_buff_com :  entity work.stage_buff generic map (145) port map(
            clk, rst, stall, ID_EX_in, ID_EX_out
            );
        
        excute_com     :  entity work.excute port map(
            clk, rst, ID_EX_out_registers_addr, ID_EX_out_b_20_bits, ID_EX_out_r_data2_in, ID_EX_out_r_data1_in, ID_EX_out_pc_inc, 
            ID_EX_out_write_back_signals, ID_EX_out_memory_signals, ID_EX_out_excute_signals, EX_MEM_out_ALU_out, temp_data, 
            EX_MEM_out_in_port_data, F_src1_sel, F_src2_sel, res_f, flag_reg, in_port_data, out_port_data, z, EX_MEM_in_registers_addr, 
            EX_MEM_in_r_data1_in, EX_MEM_in_b_20_bits, EX_MEM_in_write_data, EX_MEM_in_alu_out, EX_MEM_in_in_data,
            EX_MEM_in_write_back_signals, EX_MEM_in_memory_signals,
            -- these just for testing, delet them after finishing
            flags_z_n_c  ------------------ testing
            );
        EX_MEM_buff_com:  entity work.stage_buff generic map (167) port map(
            clk, rst, stall, EX_MEM_in, EX_MEM_out
            );

            
        mem_com        :  entity work.mem port map(
            clk, rst, EX_MEM_out_first_40_bits, EX_MEM_out_b_20_bits, EX_MEM_out_data_mem_in, EX_MEM_out_ALU_out, 
            EX_MEM_out_in_port_data, EX_MEM_out_write_back_signals, EX_MEM_out_memory_signals,
            MEM_WB_in_first_40_bits, MEM_WB_in_wb_result, MEM_WB_in_write_back_signals,
            -- these just for testing, delet them after finishing
            inc_sp, dec_sp, sp  ------------------ testing
            );

        MEM_WB_buff_com:  entity work.MEM_WB_buff generic map (77) port map(
            clk, rst, stall, MEM_WB_in, MEM_WB_out
            );
        
        -------------------------------------------- forwarding unit -------------------------------------------------
        forward_unit_com:  entity work.forward_unit port map(
            clk, rst, forward_enable, F_mem_to_IF, F_WB_to_IF, F_MEM_to_EX1, F_WB_to_EX1, F_MEM_to_EX2, F_WB_to_EX2,
            IF_op_code, IF_last_6_bits, IF_Rdst, EX_MR, EX_read_from_stack, EX_src2, EX_src1, EX_dst,
            MEM_dst, MEM_src, MEM_RW, MEM_swap, MEM_MR, MEM_WB_seg, WB_dst, WB_RW
            );

        forward_WB_Buff_com:  entity work.stage_buff generic map (36) port map(
            clk, rst, stall, F_WB_in, F_WB_out
            );

        -- forward initializations
            F_src1_sel(0) <= F_MEM_to_EX1;
            F_src1_sel(1) <= F_WB_to_EX1;
            F_src2_sel(0) <= F_MEM_to_EX2;
            F_src2_sel(1) <= F_WB_to_EX2;

            forward_enable <= forward_E;

            IF_op_code <= IF_ID_in_instruction(15 downto 12);
            IF_last_6_bits <= IF_ID_in_instruction(5 downto 0);
            IF_Rdst <= IF_ID_in_instruction(11 downto 9);

            EX_MR <= ID_EX_out_memory_signals(5);
            EX_read_from_stack <= ID_EX_out_memory_signals(2);
            EX_src2 <= ID_EX_out_registers_addr(5 downto 3);
            EX_src1 <= ID_EX_out_registers_addr(8 downto 6);
            EX_dst <= ID_EX_out_registers_addr(2 downto 0);

            MEM_dst <= EX_MEM_out_first_40_bits(2 downto 0);
            MEM_src <= EX_MEM_out_first_40_bits(8 downto 6);
            MEM_RW <= EX_MEM_out_write_back_signals(1);
            MEM_swap <= EX_MEM_out_write_back_signals(0);
            MEM_MR <= EX_MEM_out_memory_signals(5);
            MEM_WB_seg <= EX_MEM_out_memory_signals(1 downto 0);

            -- WB_dst <= w_addr1;
            -- WB_RW <= WB_signals(1);

            F_WB_in(2 downto 0) <= w_addr1;
            F_WB_in(3) <= WB_signals(1);
            F_WB_in(35 downto 4) <= w_data1;

            WB_dst <= F_WB_out(2 downto 0);
            WB_RW <= F_WB_out(3);
            temp_data <= F_WB_out(35 downto 4);

        --------------------------------------------------------------------------------------------------------
        ---------------- hazard detection unit ---------------------
        --hazard_enable <= hazard_E;
        --hazard_detection_unit_com:  entity work.hazard_detection_unit port map (
        --      clk, dec_stall,
        --      hazard_enable, EX_RW, EX_read_from_stack, EX_MR, WB_RW, '0', '0', MEM_RW ,
        --      MEM_MR,
        --      interrupt_sig,
        --      EX_dst, IF_ID_out_instruction(8 downto 6), IF_ID_out_instruction(5 downto 3), IF_ID_out_instruction(11 downto 9),
        --      IF_Rdst, MEM_dst, IF_op_code, IF_last_6_bits, stall_int
        --    );

        --stall <= '1' when (stall_int > 0)
        --else'0';
        ---------------------------------------------------------------------------------------------------------
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
            ID_EX_in(124 downto 93)         <= ID_EX_in_pc;
            ID_EX_in(128 downto 125)        <= ID_EX_in_write_back_signals;
            ID_EX_in(134 downto 129)        <= ID_EX_in_memory_signals;
            ID_EX_in(144 downto 135)        <= ID_EX_in_excute_signals;


        

        -- ID_EX out buff
            ID_EX_out_registers_addr        <= ID_EX_out(8  DOWNTO 0);
            ID_EX_out_b_20_bits             <= ID_EX_out(28 downto 9);
            ID_EX_out_r_data2_in            <= ID_EX_out(60 downto 29);
            ID_EX_out_r_data1_in            <= ID_EX_out(92 downto 61);
            -- ID_EX_out_sp                    <= ID_EX_out(124 downto 93);
            ID_EX_out_pc_inc                <= ID_EX_out(124 downto 93);
            ID_EX_out_write_back_signals    <= ID_EX_out(128 downto 125);
            ID_EX_out_memory_signals        <= ID_EX_out(134 downto 129);
            ID_EX_out_excute_signals        <= ID_EX_out(144 downto 135);

        -- EX_MEM in buff
            EX_MEM_in(8 downto 0)           <= EX_MEM_in_registers_addr;
            EX_MEM_in(40 downto 9)          <= EX_MEM_in_r_data1_in;
            EX_MEM_in(60 downto 41)         <= EX_MEM_in_b_20_bits;
            EX_MEM_in(92 downto 61)         <= EX_MEM_in_write_data;
            EX_MEM_in(124 downto 93)        <= EX_MEM_in_alu_out;
            EX_MEM_in(156 downto 125)       <= EX_MEM_in_in_data;
            EX_MEM_in(160 downto 157)       <= EX_MEM_in_write_back_signals;
            EX_MEM_in(166 downto 161)       <= EX_MEM_in_memory_signals;

        -- EX_MEM out buff
            EX_MEM_out_first_40_bits        <= EX_MEM_out(40 downto 0);
            EX_MEM_out_b_20_bits            <= EX_MEM_out(60 downto 41);
            EX_MEM_out_data_mem_in          <= EX_MEM_out(92 downto 61);
            EX_MEM_out_ALU_out              <= EX_MEM_out(124 downto 93);
            EX_MEM_out_in_port_data         <= EX_MEM_out(156 downto 125);
            EX_MEM_out_write_back_signals   <= EX_MEM_out(160 downto 157);
            EX_MEM_out_memory_signals       <= EX_MEM_out(166 downto 161);

        -- MEM_WB in buff
            MEM_WB_in(40 downto 0)          <= MEM_WB_in_first_40_bits;
            MEM_WB_in(72 downto 41)         <= MEM_WB_in_wb_result;
            MEM_WB_in(76 downto 73)         <= MEM_WB_in_write_back_signals;

        -- MEM_WB out buff
            w_addr1                         <= MEM_WB_out(2 downto 0);
            w_addr2                         <= MEM_WB_out(8 downto 6);
            w_data2                         <= MEM_WB_out(40 downto 9);
            w_data1                         <= MEM_WB_out(72 downto 41);
            WB_signals                      <= MEM_WB_out(74 downto 73);
            write_in_pc                     <= MEM_WB_out(75);
            res_f                           <= MEM_WB_out(76);

        -- genral
        in_port_data    <= in_port;
        out_port        <= out_port_data;
        -- testing part will be removed
        interrupt <= int_address; --output

end architecture;


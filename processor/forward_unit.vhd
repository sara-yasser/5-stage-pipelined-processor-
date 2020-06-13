LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

-- fifth video of the discussion
-- around minute 3:00, before slightly

entity forward_unit is
    port (
        clk, rst :   in std_logic;

        enable_forward : in std_logic;
        forward_ex_mem_out_to_if, forward_mem_wb_out_to_if, forward_ex_mem_out_to_ex1, 
        forward_mem_wb_out_to_ex1, forward_ex_mem_out_to_ex2, forward_mem_wb_out_to_ex2  : out std_logic;

        -- inputs of signals and address
        IF_ID_in_op_code    :   in std_logic_vector(3 downto 0);         --jump
        IF_ID_in_last_6_bits    :   in std_logic_vector(5 downto 0);     --jump
        jump_Rdst :   in std_logic_vector(2 downto 0);                   --jump

        ID_EX_out_memory_read_5, ID_EX_out_read_from_stack_2:   in std_logic;
        ID_EX_out_registers_addr_Rsrc2, ID_EX_out_registers_addr_Rsrc1, ID_EX_out_Rdst  :   in std_logic_vector(2 downto 0);

        EX_MEM_out_Rdst, EX_MEM_out_Rsrc1   :   in std_logic_vector(2 downto 0);
        EX_MEM_out_write_back_signals_RW_1, EX_MEM_out_write_back_signals_swap_0, EX_MEM_out_memory_signals_MR_5 :   in std_logic;
        EX_MEM_memory_signal_WB : in std_logic_vector(1 downto 0);

        MEM_WB_out_Rdst  :   in std_logic_vector(2 downto 0);
        MEM_WB_out_write_back_signals_RW_1 :   in std_logic;
        forward_imm1, forward_imm2 : out std_logic
      ) ;
end entity;

architecture forward_unit_arch of forward_unit is

begin

    forward_detection : process( clk )
        begin
            -- forward detection unit
            forward_ex_mem_out_to_if    <= '0';
            forward_mem_wb_out_to_if    <= '0';
            forward_ex_mem_out_to_ex1   <= '0';
            forward_mem_wb_out_to_ex1   <= '0'; 
            forward_ex_mem_out_to_ex2   <= '0';
            forward_mem_wb_out_to_ex2   <= '0';
            forward_imm1                <= '0';
            forward_imm2                <= '0';
            if enable_forward = '1' then
                -- load
                -- if (ID_EX_out_memory_read_5 = '1' or ID_EX_out_read_from_stack_2 = '1') and 
                if MEM_WB_out_write_back_signals_RW_1 = '1' then
                    -- if_id_in_Rdst = id_ex_out_Rsrc2
                    if MEM_WB_out_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_mem_wb_out_to_ex2 <= '1';
                    end if;
                    -- if_id_in_Rdst = id_ex_out_Rsrc1
                    if MEM_WB_out_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_mem_wb_out_to_ex1 <= '1';
                    end if ;
                
                -------------------------------------------------------------------
                -- jump after R-type
                elsif EX_MEM_out_write_back_signals_RW_1 = '1' and 
                -- fitch_op_code = jump
                (IF_ID_in_op_code = "1111" and IF_ID_in_last_6_bits = "111100") and 
                EX_MEM_out_memory_signals_MR_5 = '0' then
                    -- ex_mem_out_Rdst = jump_Rdst
                    if ex_mem_out_Rdst = jump_Rdst then
                        forward_ex_mem_out_to_if <= '1';
                    end if ;
                
                -------------------------------------------------------------------
                -- jump after load
                elsif mem_wb_out_write_back_signals_RW_1 = '1' and 
                -- fitch_op_code = jump 
                (IF_ID_in_op_code = "1111" and IF_ID_in_last_6_bits = "111100") then
                    if mem_wb_out_Rdst = jump_Rdst then
                        forward_mem_wb_out_to_if <= '1';
                    end if ;
                    
                -------------------------------------------------------------------
                -- swap
                elsif ex_mem_out_write_back_signals_swap_0 = '1' then
                    -- registers of ex_mem = id_ex_out_Rsrc2
                    if (EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc2) or (EX_MEM_out_Rsrc1 = ID_EX_out_registers_addr_Rsrc2) then
                        forward_ex_mem_out_to_ex2 <= '1';
                    else
                        forward_ex_mem_out_to_ex2 <= '0';
                    end if;
                    -- registers of ex_mem = id_ex_out_Rsrc1 or 
                    if (EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc1) or (EX_MEM_out_Rsrc1 = ID_EX_out_registers_addr_Rsrc1) then
                        forward_ex_mem_out_to_ex1 <= '1';
                    else
                        forward_ex_mem_out_to_ex1 <= '0';
                    end if;
                
                -------------------------------------------------------------------
                -- ALU to ALU
                elsif (EX_MEM_out_write_back_signals_RW_1 = '1') then
                    -- ex_mem_out_Rdst = id_ex_out_Rsrc2
                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_ex_mem_out_to_ex2 <= '1';
                    else
                        forward_ex_mem_out_to_ex2 <= '0';
                    end if ;
                    -- ex_mem_out_Rdst = id_ex_out_Rsrc1
                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_ex_mem_out_to_ex1 <= '1';
                    else
                        forward_ex_mem_out_to_ex1 <= '0';
                    end if ;
                
                -------------------------------------------------------------------
                -- IN PORT
                elsif (EX_MEM_memory_signal_WB = "00") and (EX_MEM_out_write_back_signals_RW_1 = '1') then --in port
                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_ex_mem_out_to_ex2 <= '1';
                        forward_mem_wb_out_to_ex2 <= '1';
                    else
                        forward_ex_mem_out_to_ex2 <= '0';
                        forward_mem_wb_out_to_ex2 <= '0';
                    end if ;

                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_ex_mem_out_to_ex1 <= '1';
                        forward_mem_wb_out_to_ex1 <= '1';
                    else
                        forward_ex_mem_out_to_ex1 <= '0';
                        forward_mem_wb_out_to_ex1 <= '0';
                    end if ;
                
                -------------------------------------------------------------------
                -- LDM
                elsif (EX_MEM_memory_signal_WB = "11") then
                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_imm2 <= '1';
                    else
                        forward_imm2 <= '0';
                    end if ;
                    
                    if EX_MEM_out_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_imm1 <= '1';
                    else
                        forward_imm1 <= '0';
                    end if ;
                end if;
                -------------------------------------------------------------------
                if rst = '1' then
                    forward_ex_mem_out_to_if <= '0';
                    forward_mem_wb_out_to_if <= '0';
                    forward_ex_mem_out_to_ex1 <= '0';
                    forward_mem_wb_out_to_ex1 <= '0'; 
                    forward_ex_mem_out_to_ex2 <= '0';
                    forward_mem_wb_out_to_ex2 <= '0';
                    forward_imm1 <= '0';
                    forward_imm2 <= '0';
                end if ;
            end if;
        end process ; -- forward_detection
        -- forward detection unit

end forward_unit_arch ; -- forward_unit_arch

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

-- fifth video of the discussion
-- around minute 3:00, before slightly

entity forward_unit is
    generic (
        n : integer := 32
    );

  port (
    clk :   in std_logic;
    rst :   in std_logic;
    ----------------------------------------------------
    ------------------------------------------------------
    enable_forward : in std_logic;
    forward_mem_wb_out_to_ex, forward_ex_mem_out_to_if, forward_mem_wb_out_to_if, forward_ex_mem_out_to_ex : out std_logic;
    --------------------------------------------------------
    -- inputs of signals and address
    ID_EX_out_memory_signals_5, ID_EX_out_memory_signals_2, ex_mem_out_write_back_signals_0  :   in std_logic;
    IF_ID_out_instruction_Rdst  :   in std_logic_vector(2 downto 0);
    ID_EX_out_registers_addr_Rsrc2, ID_EX_out_registers_addr_Rsrc1  :   in std_logic_vector(2 downto 0);
    EX_MEM_out_first_40_bits_Rdst   :   in std_logic_vector(2 downto 0);
    ID_EX_in_Rdst  :   in std_logic_vector(2 downto 0);
    EX_MEM_out_write_back_signals_1 :   in std_logic;
    IF_ID_in_op_code    :   in std_logic_vector(3 downto 0);
    IF_ID_in_last_6_bits    :   in std_logic_vector(4 downto 0);
    EX_MEM_out_memory_signals_5 :   in std_logic
    -------------------------------------------
    -- need to edit when Sara wakes up
    ex_mem_out_Rdst :   in std_logic_vector(2 downto 0);
    jump_Rdst :   in std_logic_vector(2 downto 0);
    mem_wb_out_Rdst :   in std_logic_vector(2 downto 0)
  ) ;
end forward_unit;

architecture forward_unit_arch of forward_unit is

begin

    forward_detection : process( clk )
        begin
            -- forward detection unit
            if enable_forward = 1 then
                -- load
                if (ID_EX_out_memory_signals_5 = 1 or ID_EX_out_memory_signals_2 = 1) and 
                -- this signal is not exist with this name in pipeline => (ask sara)
                mem_wb_out_write_back_signals_1 = 1 then
                    -- if_id_out_Rdst = id_ex_out_Rsrc2
                    if IF_ID_out_instruction_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_mem_wb_out_to_ex = '1';
                    
                    -- if_id_out_Rdst = id_ex_out_Rsrc1
                    elsif IF_ID_out_instruction_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_mem_wb_out_to_ex = '1';
                    
                    -- if_id_in_Rdst = id_ex_out_Rsrc2
                    elsif ID_EX_in_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_mem_wb_out_to_ex = '1';
                    
                    -- if_id_in_Rdst = id_ex_out_Rsrc1
                    elsif ID_EX_in_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_mem_wb_out_to_ex = '1';
                    end if ;
                end if ;
                -------------------------------------------------------------------
                -- jump after R-type
                if EX_MEM_out_write_back_signals_1 = 1 and 
                -- fitch_op_code = jump
                (IF_ID_in_op_code = "1111" and IF_ID_in_last_6_bits = "11110") and 
                EX_MEM_out_memory_signals_5 = 0 then
                    -- ex_mem_out_Rdst = jump_Rdst
                    if ex_mem_out_Rdst = jump_Rdst then
                        forward_ex_mem_out_to_if = '1';
                    end if ;
                end if ;
                -------------------------------------------------------------------
                -- jump after load
                if mem_wb_out_write_back_signals_1 = 1 and 
                -- fitch_op_code = jump 
                (IF_ID_in_op_code = "1111" and IF_ID_in_last_6_bits = "11110") then
                    if mem_wb_out_Rdst = jump_Rdst then
                        forward_mem_wb_out_to_if = '1';
                    end if ;
                    
                end if ;
                -------------------------------------------------------------------
                -- swap
                if ex_mem_out_write_back_signals_0 = 1 then
                    -- registers of ex_mem = id_ex_out_Rsrc2
                    if EX_MEM_out_first_40_bits_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                        forward_ex_mem_out_to_ex = '1';
                    -- registers of ex_mem = id_ex_out_Rsrc1
                    if EX_MEM_out_first_40_bits_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                        forward_ex_mem_out_to_ex = '1';
                    end if ;
                end if ;
                -------------------------------------------------------------------
                -- ALU to ALU
                -- ex_mem_out_Rdst = id_ex_out_Rsrc2
                if EX_MEM_out_first_40_bits_Rdst = ID_EX_out_registers_addr_Rsrc2 then
                    forward_ex_mem_out_to_ex = '1';
                -- ex_mem_out_Rdst = id_ex_out_Rsrc1
                elsif EX_MEM_out_first_40_bits_Rdst = ID_EX_out_registers_addr_Rsrc1 then
                    forward_ex_mem_out_to_ex = '1';
                end if ;
                -------------------------------------------------------------------
            end if ;
            end if;
        end process ; -- forward_detection
        -- forward detection unit

end forward_unit_arch ; -- forward_unit_arch
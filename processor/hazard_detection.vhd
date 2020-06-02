
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

entity hazard_detection_unit is
  port (
    clk, dec :   in std_logic;
    enable_hazard : in std_logic;
    ID_EX_out_RW,
    read_from_stack,
    ID_EX_out_MR,
    write_back_signals_RW_1,
    control_unit_MR,
    control_unit_RW,
    EX_MEM_out_RW ,
    EX_MEM_out_MR : in std_logic;
    interrupt_sig : in std_logic;
    Id_EX_out_Rdst, IF_ID_out_Rsrc1, IF_ID_out_Rsrc2, IF_ID_out_Rdst, jump_Rdst, EX_MEM_out_Rdst : in std_logic_vector(2 downto 0);
    fitch_op_code : in std_logic_vector(3 downto 0);
    last_6_bits : in std_logic_vector(5 downto 0);
    stall_sig : out integer
  ) ;
end hazard_detection_unit;

architecture hazard_detection_unit_arch of hazard_detection_unit is
signal temp_stall : integer:= 0;
begin
    stall_sig <= temp_stall;
  process(clk)
  begin
    if enable_hazard = '1' then
        -- load
        if (ID_EX_out_RW = '1' or read_from_stack = '1') and (ID_EX_out_MR = '1' or read_from_stack = '1') then
          -- Id_EX_Rdst = IF_ID_Rsrc2
          if Id_EX_out_Rdst = IF_ID_out_Rsrc2 then
            temp_stall <= 1;
          end if ;

          -- Id_EX_Rdst = IF_ID_Rsrc1
          if Id_EX_out_Rdst = IF_ID_out_Rsrc1 then
            temp_stall <= 1;
          end if ;
        end if ;

        -- jump
        if (fitch_op_code = "1111" and last_6_bits = "111100") then
          -- jump after R-type
          if write_back_signals_RW_1 = '1' and control_unit_MR = '0' and IF_ID_out_Rdst = jump_Rdst then
            temp_stall <= 2;
          end if ;

          -- jump after something then R-type
          if ID_EX_out_RW = '1' and ID_EX_out_MR = '0' and ID_EX_out_Rdst = jump_Rdst then
            temp_stall <= 1;
          end if ;

          -- jump after load directly
          if control_unit_RW = '1' and control_unit_MR = '1' and IF_ID_out_Rdst = jump_Rdst then
            temp_stall <= 3;
          end if ;

          -- jump after something then load
          if ID_EX_out_RW = '1'  and ID_EX_out_MR = '1' and ID_EX_out_Rdst = jump_Rdst then
            temp_stall <= 2;
          end if ;

          -- jump after 2 things then load
          if EX_MEM_out_RW = '1' and EX_MEM_out_MR = '1' and EX_MEM_out_Rdst = jump_Rdst then
            temp_stall <= 1;
          end if ;
        end if ;
        
        -- in case of RET and RTI
        if fitch_op_code = "1111" and (last_6_bits = "101100" or last_6_bits = "011000") then
            temp_stall <= 3;
        end if ;

        -- in case of interrupt
        if interrupt_sig = '1' then
            temp_stall <= 1;
        end if ;

        -- STALL => 
        -- read same instruction
        -- and insert zeros in the IF_ID_buff
        -- the rest is read the same only
    end if ;

  end process;

end hazard_detection_unit_arch ; -- hazard_detection_unit_arch
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity MUX_forward is
  port (
    clk :  in std_logic;
    input_from_ex_mem, input_from_mem_wb, input_from_id_ex, input_from_in_port   : in std_logic_vector(31 downto 0);
    forward_mem_wb_out_to_ex, forward_ex_mem_out_to_ex  : in std_logic;
    output_reg  :   out std_logic_vector(31 downto 0)
  ) ;
end MUX_forward;

architecture MUX_forward_arch of MUX_forward is

begin

    decision_MUX : process( clk )
    begin
        if forward_mem_wb_out_to_ex = '0' and forward_ex_mem_out_to_ex = '0' then
            output_reg <= input_from_id_ex;
        elsif forward_mem_wb_out_to_ex = '1' and forward_ex_mem_out_to_ex = '0' then
            output_reg <= input_from_mem_wb;
        elsif forward_mem_wb_out_to_ex = '0' and forward_ex_mem_out_to_ex = '1' then
            output_reg <= input_from_ex_mem;
        elsif forward_mem_wb_out_to_ex = '0' and forward_ex_mem_out_to_ex = '1' then
            output_reg <= input_from_in_port;
        end if ;
    end process ; -- decision_MUX

end MUX_forward_arch ; -- MUX_forward_arch
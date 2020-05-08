LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ALU IS
    PORT(
        ALU_signals : in STD_LOGIC_VECTOR (3  DOWNTO 0);
        a,b : in STD_LOGIC_VECTOR (31  DOWNTO 0);
        flag_in : in STD_LOGIC_VECTOR (2  DOWNTO 0);
        ALU_out : out STD_LOGIC_VECTOR (31 DOWNTO 0);
        flag_out : out STD_LOGIC_VECTOR (2  DOWNTO 0)
        );
end entity;


architecture ALU_arc of ALU is
    component ripple_adder IS
    PORT(
        a,b : in STD_LOGIC_VECTOR (31  DOWNTO 0);
        sum : out STD_LOGIC_VECTOR (31 DOWNTO 0);
        cout : out STD_LOGIC
        );
    end component;

signal temp_out, arthimatic_out, tows_complement, ones_complement, sec_operand : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal ones : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '1');
signal one, zeros : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
signal carry_operation, temp_c, op : std_logic;



begin
    one(0) <= '1';
    ones_complement <= not b;
    a0: ripple_adder port map(b, one, tows_complement, temp_c);

    sec_operand <= tows_complement when ALU_signals = "0101" -- sub
    else one when ALU_signals = "0110"                   -- inc
    else ones when ALU_signals = "0111"                  -- dec
    else b;                                                  -- add (0100)

    a1: ripple_adder port map (a, sec_operand, arthimatic_out, carry_operation);

    op <= '1' when (ALU_signals(3 downto 2) = "01")or(ALU_signals(3 downto 1) = "100")or((ALU_signals(3 downto 2) = "00") and ALU_signals(1 downto 0) /= "00")
    else '0';

    temp_out <= arthimatic_out when ALU_signals(3 downto 2) = "01"   -- add, sub, inc or dec
    else (a and b) when ALU_signals = "0001"                         -- and
    else (a or b) when ALU_signals = "0010"                          -- or
    else (not b) when ALU_signals = "0011"                           -- not
    else STD_LOGIC_VECTOR(shift_left(unsigned(b), to_integer(unsigned(a)))) when ALU_signals = "1000"  -- shl
    else STD_LOGIC_VECTOR(shift_right(unsigned(b), to_integer(unsigned(a)))) when ALU_signals = "1001" -- shr
    else b ;                                                                                           -- pass2

    flag_out(0) <= '1' when (op = '1' and temp_out = zeros)  -- zero flag
    else '0' when (op = '1')
    else flag_in(0);

    flag_out(1) <= temp_out(31) when op = '1'                -- negative flag
    else flag_in(1);

    flag_out(2) <= carry_operation  when ALU_signals(3 downto 2) = "01"  -- carry flag
    else b(32-to_integer(unsigned(a))) when ALU_signals = "1000" and a /= zeros  --shl 
    else b(to_integer(unsigned(a))-1) when ALU_signals = "1001" and a /= zeros   --shr
    else flag_in(2); 

    ALU_out <= temp_out;


end architecture;


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

entity srcs is
    port (
        instruction : in std_logic_vector(15 downto 0);
        src1, src2 : out std_logic;
        Rsrc1, Rsrc2 : out std_logic_vector(2 downto 0)
    );
end entity;

architecture srcs_arch of srcs is
    signal last_6_bits : std_logic_vector(5 downto 0);
    signal first_4_bits : std_logic_vector(3 downto 0);
    signal swap, R, one_operand : std_logic:='0';

begin

    last_6_bits <= instruction(5 downto 0);
    first_4_bits <= instruction(15 downto 12);

    swap <= '1' when first_4_bits = "1110"
    else '0';

    R <= '1' when (first_4_bits(3 downto 1) = "110") or ((first_4_bits = "1111") and (last_6_bits(1) = '1'))
    else '0';

    one_operand <= '1' when (first_4_bits = "1111") and ((last_6_bits(5 downto 4) = "00") or 
                                                        (last_6_bits(5 downto 3) = "111") or
                                                        (last_6_bits(5 downto 2) = "1000") or
                                                        (last_6_bits(5 downto 2) = "1100"))
    else '0';
    
    src1 <= '1' when swap = '1' or R = '1'
    else '0';

    src2 <= '1' when swap = '1' or R = '1' or one_operand = '1'
    else '0';

    Rsrc1 <= instruction(8 downto 6);

    Rsrc2 <= instruction(5 downto 3) when R = '1'
    else instruction(11 downto 9);

end architecture;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity sp IS
PORT( clk, rst, inc, dec : IN std_logic;
	    q : OUT std_logic_vector(31 DOWNTO 0)
);
end entity;
ARCHITECTURE sp_arc OF sp IS
signal temp : std_logic_vector(31 DOWNTO 0);
    BEGIN
    q <= temp;
    PROCESS (clk,rst)
        BEGIN
            if rst = '1' then
                temp <= "00000000000000000000111111111100";
            else
                IF (not (falling_edge(CLK))) THEN
                    if inc = '1' then
                        temp <= std_logic_vector(unsigned(temp)+2);
                    end if;
                elsif dec = '1' then
                    IF (falling_edge(CLK)) THEN
                        temp <= std_logic_vector(unsigned(temp)-2);
                    end if;
                end if;
                
            end if;
        END PROCESS;
END ARCHITECTURE;


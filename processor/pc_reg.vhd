LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY pc_register IS
PORT( clk, rst, e : IN std_logic;
	    d : IN std_logic_vector(31 DOWNTO 0);
	    q : OUT std_logic_vector(31 DOWNTO 0)
);
	
END ENTITY;
ARCHITECTURE pc_register_arc OF pc_register IS
    BEGIN
    q <= d;
    -- PROCESS (d,clk,rst,e)
    --     BEGIN
    --         IF (rising_edge(CLK) and e='1' ) THEN
    --         -- IF (clk = '1' and e='1' ) THEN
    --             q <= d;
    --         END IF;
    --     END PROCESS;
END ARCHITECTURE;

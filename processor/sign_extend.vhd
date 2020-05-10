LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity sign_extend is
	port(
		A: in std_logic_vector(15 downto 0);
		c: out std_logic_vector(31 downto 0)
	);
end entity;

architecture sign_extend_arc of sign_extend is
	signal temp_out : std_logic_vector(31 downto 0) := (others => '0');
begin
	temp_out(15 downto 0) <= A;
	temp_out(31 downto 16) <= (others => '0') when A(15) = '0'
	else (others => '1');
	c <= temp_out;
end architecture;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity inc_dec is
	port(
		sel : std_logic;   -- 0 inc, 1 dec
		A: in std_logic_vector(31 downto 0);
		c: out std_logic_vector(31 downto 0)
	);
end entity;

architecture inc_dec_arc of inc_dec is
	component ripple_adder IS
    PORT(
        a,b : in STD_LOGIC_VECTOR (31  DOWNTO 0);
        sum : out STD_LOGIC_VECTOR (31 DOWNTO 0);
        cout : out STD_LOGIC
        );
	end component;

	signal ones : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '1');
	signal one : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
	signal temp_out, sec_op : std_logic_vector(31 downto 0) := (others => '0');
	signal temp_c : std_logic;
begin
	one(0) <= '1';
	a0: ripple_adder port map(A, sec_op, temp_out, temp_c);

	sec_op <= one when sel = '0'
	else ones;
	
	c <= temp_out;
end architecture;

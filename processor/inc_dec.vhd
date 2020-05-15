LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity inc_dec is
	port(
		sel : std_logic;   -- 0 inc, 1 dec
		num : std_logic;   -- 0 by 1, 1 by 2
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
	signal twos : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '1');
	signal two : STD_LOGIC_VECTOR (31 DOWNTO 0) := (others => '0');
	signal temp_out, sec_op : std_logic_vector(31 downto 0) := (others => '0');
	signal temp_c : std_logic;
begin
	one(0) <= '1';
	two(1) <= '1';
	twos(0) <= '0';
	a0: ripple_adder port map(A, sec_op, temp_out, temp_c);

	sec_op <= one when sel = '0' and num = '0'
	else ones when sel = '1' and num = '0'
	else two when sel = '0' and num = '1'
	else twos when sel = '1' and num = '1';
	
	c <= temp_out;
end architecture;

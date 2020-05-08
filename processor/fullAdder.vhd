LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

entity full_adder IS  
     PORT( 
            a,b,cin : in STD_LOGIC;
            sum,cout : out STD_LOGIC
          );
end entity;

architecture full_adder_arch OF full_adder IS
begin
    process (a,b,cin)
    begin 
	sum <= a xor b xor cin;
	cout <= (a and b) or (cin and (a xor b));
    end process;
end architecture;

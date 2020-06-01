LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity decoder IS
    port(
		clk, rst, E, T, C :          in  STD_LOGIC;
		data_in :      in  STD_LOGIC_VECTOR(11 DOWNTO 0);
		data_out :     out STD_LOGIC_VECTOR(19 DOWNTO 0)
        );
end entity;

architecture decoder_arc OF decoder IS


signal tempout: STD_LOGIC_VECTOR(19 DOWNTO 0);


begin
	

data_out <= tempout;

process (E, T, C, data_in, clk)
begin
	if rst = '1' then
		tempout     <= (others => '0');

	elsif rst = '0' then
		if falling_edge(clk) then
		-- if clk = '1' then
			if E = '1' then 
				if T = '1' then
				if C = '1' then tempout(7 downto 0) <= data_in(8 downto 1);
				else tempout(19 downto 8) <= data_in; tempout(7 downto 0) <= (others => '0');
					end if;
				else 
				if C = '1' then tempout(7 downto 4) <= data_in(5 downto 2);
				else tempout(19 downto 8) <= data_in; tempout(7 downto 0) <= (others => '0');
					end if;
				end if;
			else 
				tempout     <= (others => '0');
			end if;
		end if;
    end if;
end process;

end architecture;


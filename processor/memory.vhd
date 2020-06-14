LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity memory is
    generic (addr_width : integer := 20);

    port(
        clk, rst :   in std_logic;
        R, W : in std_logic;
        addr : in std_logic_vector(31 downto 0);
        din : in std_logic_vector(31 downto 0);
        dout : out std_logic_vector(31 downto 0)
    );
end entity;

architecture memory_arch of memory is
    type ram_type is array (2**addr_width-1 downto 0) of std_logic_vector (15 downto 0);
    signal ram_single_port : ram_type;
    signal checker_int, addr_int : integer:=0;

    begin
        checker_int <= to_integer(unsigned(addr));

        addr_int <= to_integer(unsigned(addr)) when (checker_int < 2**addr_width-1) and (checker_int >= 0)
        else 0;

        process(clk, W, R, addr)
        begin

            if rst = '1' then
                for I in 0 to 2**addr_width-1 loop
                    ram_single_port(I) <= (others => '0');
                end loop;
            else
                if (checker_int < 2**addr_width-1) and (checker_int >= 0) then
	    
                    if (W = '1' and clk'event and clk='0') then
                        ram_single_port(addr_int) <= din(15 downto 0);
                        ram_single_port(addr_int + 1) <= din(31 downto 16);
                        
                    elsif R = '1' then
                        dout(15 downto 0) <= ram_single_port(addr_int);
                        dout(31 downto 16) <= ram_single_port(addr_int + 1);

                    end if;
                end if;
            end if;
    
        end process;

end architecture;
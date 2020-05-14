LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity memory is
    generic (addr_width : integer := 2);

    port(
        clk, rst :   in std_logic;
        we : in std_logic;
        addr : in std_logic_vector(31 downto 0);
        din : in std_logic_vector(31 downto 0);
        dout : out std_logic_vector(31 downto 0)
    );
end entity;

architecture memory_arch of memory is
    type ram_type is array (2**addr_width-1 downto 0) of std_logic_vector (31 downto 0);
    signal ram_single_port : ram_type;

    begin
        process(clk)
        begin
	    if (rst = '1') then

		for i in 2**addr_width-1 downto 0 loop            
                    ram_single_port(i) <= (others => '0');
                end loop;
	    else
                if (clk'event and clk='1') then
                    if (we='1') then -- write data to address 'addr'
                        --convert 'addr' type to integer from std_logic_vector
                        ram_single_port(to_integer(unsigned(addr))) <= din;
                    end if;
                end if;
	    end if;
        end process;

    -- read data from address 'addr'
    -- convert 'addr' type to integer from std_logic_vector
    dout<=ram_single_port(to_integer(unsigned(addr)));

end architecture;
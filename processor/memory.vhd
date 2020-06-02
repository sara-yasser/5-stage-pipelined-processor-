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

    begin
        process(clk, W, R, addr)
        begin
            if rst = '1' then
                for I in 0 to 2**addr_width-1 loop
                    ram_single_port(I) <= (others => '0');
                end loop;
            else
	    
                if (W = '1' and clk'event and clk='0') then
                    ram_single_port(to_integer(unsigned(addr))) <= din(15 downto 0);
                    ram_single_port(to_integer(unsigned(addr)) + 1) <= din(31 downto 16);
                    
                elsif R = '1' then
                    dout(15 downto 0) <= ram_single_port(to_integer(unsigned(addr)));
                    dout(31 downto 16) <= ram_single_port(to_integer(unsigned(addr)) + 1);

                end if;
            end if;
    
        end process;

end architecture;
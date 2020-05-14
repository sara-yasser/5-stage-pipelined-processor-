Library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
USE IEEE.numeric_std.all;

entity inst_mem is
    port(
        clk, rst :   in std_logic;
        addr : in std_logic_vector(31 downto 0);
        dout : out std_logic_vector(15 downto 0)
    );
end entity;

architecture inst_mem_arc of inst_mem is

    type ram_type is array (15 downto 0) of std_logic_vector (15 downto 0);
    signal ram_single_port : ram_type;
    signal temp_addr : std_logic_vector(31 downto 0);

    begin
        -- for i in 15 downto 0 loop            
        --     ram_single_port(i) <= (others => '0');
        -- end loop;

        process(clk)
        file text_file1 : text open read_mode is "E:\arc2pro\5-stage pipelined processor\processor\out.txt";
        variable text_line : line;
        variable char1, char2, char3, char4 : character;
        variable inst :STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
        variable address : integer := 0;
        begin
            while not endfile(text_file1) loop
                readline(text_file1, text_line);
                -----
                read(text_line, char1);
                -----
                read(text_line, char2);
                -----
                read(text_line, char3);
                -----
                read(text_line, char4);
                -----
                read(text_line, inst);
                ram_single_port(address) <= inst;
                address := address + 1;
                
            end loop;
            -- if (rst = '1') then temp_addr <= (others => '0'); else temp_addr <= addr; end if ;
        end process;

        temp_addr <= addr;
    dout<=ram_single_port(to_integer(unsigned(temp_addr)));

end architecture;

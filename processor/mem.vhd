LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity mem is
    port(
        clk, rst                  :   in std_logic;

        EX_MEM_first_40_bits      : in std_logic_vector(39 DOWNTO 0);
        EX_MEM_b_20_bits          : in std_logic_vector(19 downto 0);
        EX_MEM_data_mem_in        : in std_logic_vector(31 downto 0);
        EX_MEM_ALU_out            : in std_logic_vector(31 downto 0);
        EX_MEM_sp                 : in std_logic_vector(31 downto 0);
        EX_MEM_in_port_data       : in std_logic_vector(31 downto 0);
        EX_MEM_write_back_signals : in std_logic_vector(3 downto 0);
        EX_MEM_memory_signals     : in std_logic_vector(5 downto 0);

        inc_sp, dec_sp            : out std_logic;
        
        MEM_WB_first_40_bits      : out std_logic_vector(39 downto 0);
        MEM_WB_wb_result          : out std_logic_vector(31 downto 0);
        MEM_WB_write_back_signals : out std_logic_vector(3 downto 0)
    );
end entity;

architecture mem_arc of mem is
    component memory is
        generic (
            addr_width : integer := 2;
            data_width : integer := 3 
        );
        port(
            clk, rst :   in std_logic;
            R, W     : in std_logic;
            addr     : in std_logic_vector(addr_width-1 downto 0);
            din      : in std_logic_vector(data_width-1 downto 0);
            dout     : out std_logic_vector(data_width-1 downto 0)
        );
    end component;

    
    -- signal instruction : std_logic_vector(15 downto 0);
    signal write_in_mem, read_from_mem, MR, MW, write_in_stack, read_from_stack, inc_sp_seg, dec_sp_seg : std_logic;
    signal WB : STD_LOGIC_VECTOR(1 downto 0);
    signal data_mem_in, data_mem_out, wb_result, addr_imm, ALU_out, sp, in_port_data, mem_addr : std_logic_vector(31 downto 0);
    signal memory_signals :      STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal write_back_signals :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal b_20_bits : std_logic_vector(19 downto 0);
    
    

    begin
        memory_com: memory generic map (5) port map(clk, rst, read_from_mem, write_in_mem, mem_addr, data_mem_in, data_mem_out); --just for testing
        -- memory_com: memory generic map (20) port map(clk, rst, write_in_mem, data_mem_in, data_mem_out);

        -- initializations
        b_20_bits          <= EX_MEM_b_20_bits;
        data_mem_in        <= EX_MEM_data_mem_in;
        ALU_out            <= EX_MEM_ALU_out;
        sp                 <= EX_MEM_sp;
        in_port_data       <= EX_MEM_in_port_data;
        write_back_signals <= EX_MEM_write_back_signals;
        memory_signals     <= EX_MEM_memory_signals;

        addr_imm <= "000000000000" & b_20_bits;

        MR <= memory_signals(5);
        MW <= memory_signals(4);
        write_in_stack <= memory_signals(3);
        read_from_stack <= memory_signals(2);
        WB <= memory_signals(1 downto 0);
        
        --muxes
        mem_addr <= sp when write_in_stack = '1' or read_from_stack = '1'
        else addr_imm;-- when MR = '1' or MW = '1'

        write_in_mem <= '1' when write_in_stack = '1' or MW = '1'
        else '0';

        read_from_mem <= '1' when read_from_stack = '1' or MR = '1'
        else '0';

        inc_sp <= '1' when read_from_stack = '1'
        else '0';

        dec_sp <= '1' when write_in_stack = '1'
        else '0';

        wb_result <= in_port_data when WB = "00"
        else ALU_out when WB = "01"
        else data_mem_out when WB = "10"
        else addr_imm; --when WB = "11"

        MEM_WB_first_40_bits          <= EX_MEM_first_40_bits;
        MEM_WB_wb_result              <= wb_result;
        MEM_WB_write_back_signals     <= write_back_signals;
        
        -- process(clk)
        -- begin
            
        --     if rst = '1' then
        --         MEM_WB <= (others => '0');
        --     else
        --         if (clk'event and clk='0') then
        --             MEM_WB(40 downto 0) <= EX_MEM(40 downto 0);
        --             MEM_WB(72 downto 41) <= wb_result;
        --             MEM_WB(76 downto 73) <= write_back_signals;
                    
        --         end if;
        --     end if;
        -- end process;
end architecture;


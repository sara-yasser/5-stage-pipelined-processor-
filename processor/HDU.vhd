LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;
-- handle just load for now
entity HDU is
    port (
        clk, enable_hazard :   in std_logic;
        IF_ID_in_instruction, IF_ID_out_instruction : in std_logic_vector(15 downto 0);
        decode_MR, decode_read_from_stack : in std_logic;
        IF_ID_Rdst, IF_ID_src1, IF_ID_src2 : in std_logic_vector(2 downto 0);
        -- cmp_logic_seg : in std_logic;
        -- ID_EX_MR, ID_EX_read_from_stack, ID_EX_RW : in std_logic;
        -- ID_EX_Rdst : in std_logic_vector(2 downto 0);
        -- EX_MEM_RW : in std_logic;
        -- EX_MEM_Rdst : in std_logic_vector(2 downto 0);

        stall_sig : out std_logic
    );
  end entity;

architecture HDU_arch of HDU is
signal temp_stall : std_logic:= '0';
signal fetch_src1, fetch_src2 : std_logic;
signal fetch_Rsrc1, fetch_Rsrc2 : std_logic_vector(2 downto 0);
begin
    srcs: entity work.srcs port map (IF_ID_in_instruction, fetch_src1, fetch_src2, fetch_Rsrc1, fetch_Rsrc2);

    stall_sig <= temp_stall;
    process(clk)
    begin
        temp_stall <= '0';
        if enable_hazard = '1' then
            -- load
            if (decode_MR = '1' or decode_read_from_stack = '1') then
                if ((fetch_src1 = '1') and(IF_ID_Rdst = fetch_Rsrc1)) or ((fetch_src2 = '1') and(IF_ID_Rdst = fetch_Rsrc2)) then
                temp_stall <= '1';
                end if ;
            end if ;

        end if;
    end process;

end architecture;

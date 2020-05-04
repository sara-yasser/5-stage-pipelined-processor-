LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity control_unit IS
    generic (n : integer := 16);
    port
	(
	clk :                in  STD_LOGIC;
	first_four_bits :    in  STD_LOGIC_VECTOR(3 DOWNTO 0);
	last_six_bits :      in  STD_LOGIC_VECTOR(5 DOWNTO 0);
	insert_zeros :       in  STD_LOGIC;
	decode_signals :     out STD_LOGIC_VECTOR(4 DOWNTO 0);
	excute_signals :     out STD_LOGIC_VECTOR(10 DOWNTO 0);
	memory_signals :     out STD_LOGIC_VECTOR(5 DOWNTO 0);
	write_back_signals : out STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
end entity;

architecture control_unit_arc OF control_unit IS

signal BE, src, E, T, C:                        STD_LOGIC := '0';                                 -- decode signals
signal WD_sel:                                  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');  -- excute signals
signal out_seg, in_seg, src1, src2, res_f:      STD_LOGIC := '0';                                 -- excute signals
signal ALU:                                     STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');  -- excute signals
signal MR, MW, write_in_stack, read_from_stack: STD_LOGIC := '0';                                 --mem signals
signal WB:                                      STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');  --mem signals
signal write_in_pc, RW, swap:                   STD_LOGIC := '0';                                 --write back signals

begin
	-- initializing decode signals
	decode_signals(4)          <= BE;
	decode_signals(3)          <= src;
	decode_signals(2)          <= E;
	decode_signals(1)          <= T;
	decode_signals(0)          <= C;
	-- initializing excute signals
	excute_signals(10)         <= in_seg;
	excute_signals(9)          <= out_seg;
	excute_signals(8 downto 7) <= WD_sel;
	excute_signals(6)          <= src1;
	excute_signals(5)          <= src2;
	excute_signals(4)          <= res_F;
	excute_signals(3 downto 0) <= ALU;
	-- initializing mem signals
	memory_signals(5)          <= MR;
	memory_signals(4)          <= MW;
	memory_signals(3)          <= write_in_stack;
	memory_signals(2)          <= read_from_stack;
	memory_signals(1 downto 0) <= WB;
	-- initializing write back signals
	write_back_signals(2)      <= write_in_pc;
	write_back_signals(1)      <= RW;
	write_back_signals(0)      <= swap;



process (first_four_bits, last_six_bits, insert_zeros, clk)
begin

    --if rising_edge(clk) then
    if clk = '1' then
	BE <= '0'; src <= '0'; E <= '0'; T <= '0'; C <= '0'; in_seg<= '0'; out_seg <= '0'; WD_sel <= "00";
	src1 <= '0'; src2 <= '0'; res_F <= '0'; ALU <= "0000"; MR <= '0'; MW <= '0'; write_in_stack <= '0';
	read_from_stack <= '0'; WB <= "00"; write_in_pc <= '0'; RW <= '0'; swap <= '0';
	
	if first_four_bits = "0000" then E <= '1'; T <= '1';                                                       -- LDD 1
	elsif first_four_bits = "0001" then MR <= '1'; RW <= '1'; WB <= "10"; E <= '1'; T <= '1'; C <= '1';           -- LDD 2
	elsif first_four_bits = "0010" then src <= '1'; E <= '1'; T <= '1';                                           -- STD 1
	elsif first_four_bits = "0011" then MW <= '1'; E <= '1'; T <= '1'; C <= '1';                                  -- STD 2
	elsif first_four_bits = "0100" then src <= '1'; E <= '1'; T <= '1';                                           -- SHL 1
	elsif first_four_bits = "0101" then ALU <= "0001"; src1 <= '1'; E <= '1'; T <= '1'; C <= '1';                 -- SHL 2
	elsif first_four_bits = "0110" then src <= '1'; E <= '1'; T <= '1';                                           -- SHR 1
	elsif first_four_bits = "0111" then ALU <= "0010"; src1 <= '1'; E <= '1'; T <= '1'; C <= '1';                 -- SHR 2
	elsif first_four_bits = "1000" then E <= '1'; T <= '1';                                                       -- LDM 1
	elsif first_four_bits = "1001" then RW <= '1'; WB <= "11"; E <= '1'; T <= '1'; C <= '1';                      -- LDM 2
	elsif first_four_bits = "1010" then E <= '1';                                                                 -- IADD 1
	elsif first_four_bits = "1011" then src2 <= '1'; ALU <= "0011"; RW <= '1'; WB <= "01"; E <= '1'; C <= '1';    -- IADD 2
	elsif first_four_bits = "1100" then ALU <= "0100"; RW <= '1'; WB <= "01";                                     -- OR
	elsif first_four_bits = "1101" then ALU <= "0101"; RW <= '1'; WB <= "01";                                     -- AND
	elsif first_four_bits = "1110" then src <= '1'; swap <= '1'; ALU <= "0111"; WB <= "01";                       -- SWAP

	elsif first_four_bits = "1111" then

	    if last_six_bits = "000010" then ALU <= "0110"; RW <= '1'; WB <= "01";                      -- SUB
	    elsif last_six_bits = "000011" then ALU <= "0011"; RW <= '1'; WB <= "01";                      -- ADD

	    elsif last_six_bits = "000000" then src <= '1'; ALU <= "1000"; RW <= '1'; WB <= "01";          -- NOT
	    elsif last_six_bits = "000100" then src <= '1'; ALU <= "1001"; RW <= '1'; WB <= "01";          -- INC
	    elsif last_six_bits = "001000" then src <= '1'; ALU <= "1010"; RW <= '1'; WB <= "01";          -- DEC
	    elsif last_six_bits = "001100" then src <= '1'; out_seg <= '1';                                -- OUT
	    elsif last_six_bits = "010000" then in_seg <= '1'; RW <= '1';                                  -- IN
	    elsif last_six_bits = "010100" then res_f <= '1'; read_from_stack <= '1'; WD_sel <= "01";      -- NOP/ RTI 1
	    elsif last_six_bits = "011000" then read_from_stack <= '1'; write_in_pc <= '1'; WB <= "01";    -- NOP/ RTI 2
	    --else if last_six_bits = "011100" then                                                            -- NOP
	    elsif last_six_bits = "100000" then src <= '1'; write_in_stack <= '1';                         -- PUSH
	    elsif last_six_bits = "100100" then read_from_stack <= '1'; write_in_pc <= '1'; WB <= "10";    -- POP
	    --else if last_six_bits = "101000" then                                                            -- NOP
	    elsif last_six_bits = "101100" then read_from_stack <= '1'; write_in_pc <= '1'; WB <= "10";    -- RET
	    elsif last_six_bits = "110000" then write_in_stack <= '1'; WD_sel <= "10";                     -- CALL
	    --else if last_six_bits = "110100" then                                                            -- RTI ghanged -------
	    elsif last_six_bits = "111000" then BE <= '1';                                                 -- JZ
	    --else if last_six_bits = "111100" then                                                            -- JMP
	    end if;
	end if;
    end if;
end process;

end architecture;


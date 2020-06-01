LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity control_unit IS
    port(
		clk, rst :           in  STD_LOGIC;
		first_four_bits :    in  STD_LOGIC_VECTOR(3 DOWNTO 0);
		last_six_bits :      in  STD_LOGIC_VECTOR(5 DOWNTO 0);
		decode_signals :     out STD_LOGIC_VECTOR(4 DOWNTO 0);
		excute_signals :     out STD_LOGIC_VECTOR(9 DOWNTO 0);
		memory_signals :     out STD_LOGIC_VECTOR(5 DOWNTO 0);
		write_back_signals : out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
end entity;

architecture control_unit_arc OF control_unit IS

signal BE, src, E, T, C:                        STD_LOGIC := '0';                                 -- decode signals
signal WD_sel:                                  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');  -- excute signals
signal out_seg, in_seg, src1, src2:             STD_LOGIC := '0';                                 -- excute signals
signal ALU:                                     STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');  -- excute signals
signal MR, MW, write_in_stack, read_from_stack: STD_LOGIC := '0';                                 --mem signals
signal WB:                                      STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');  --mem signals
signal write_in_pc, RW, swap, res_f:            STD_LOGIC := '0';                                 --write back signals

signal decode_s :      STD_LOGIC_VECTOR(4 DOWNTO 0);
signal excute_s :      STD_LOGIC_VECTOR(9 DOWNTO 0);
signal memory_s :      STD_LOGIC_VECTOR(5 DOWNTO 0);
signal write_back_s :  STD_LOGIC_VECTOR(3 DOWNTO 0);

begin
	-- initializing decode signals
	--decode_signals(4)          <= BE;
	--decode_signals(3)          <= src;
	--decode_signals(2)          <= E;
	--decode_signals(1)          <= T;
	--decode_signals(0)          <= C;
	decode_signals <= decode_s;
	-- initializing excute signals
	--excute_signals(9)         <= in_seg;
	--excute_signals(8)          <= out_seg;
	--excute_signals(7 downto 6) <= WD_sel;
	--excute_signals(5)          <= src1;
	--excute_signals(4)          <= src2;
	--excute_signals(3 downto 0) <= ALU;
	excute_signals <= excute_s;
	-- initializing mem signals
	--memory_signals(5)          <= MR;
	--memory_signals(4)          <= MW;
	--memory_signals(3)          <= write_in_stack;
	--memory_signals(2)          <= read_from_stack;
	--memory_signals(1 downto 0) <= WB;
	memory_signals <= memory_s;
	-- initializing write back signals
	--write_back_signals(3)      <= res_F;
	--write_back_signals(2)      <= write_in_pc;
	--write_back_signals(1)      <= RW;
	--write_back_signals(0)      <= swap;
	write_back_signals <= write_back_s;


process (first_four_bits, last_six_bits, clk)
begin

	if rst = '1' then
		decode_s     <= (others => '0');
		excute_s     <= (others => '0');
		memory_s     <= (others => '0');
		write_back_s <= (others => '0');

	elsif rst = '0' then
		--if clk'event and clk = '1' then
		--if rising_edge(clk) then
		if clk = '1' then
			BE <= '0'; src <= '0'; E <= '0'; T <= '0'; C <= '0'; in_seg<= '0'; out_seg <= '0'; WD_sel <= "00";
			src1 <= '0'; src2 <= '0'; res_F <= '0'; ALU <= "0000"; MR <= '0'; MW <= '0'; write_in_stack <= '0';
			read_from_stack <= '0'; WB <= "00"; write_in_pc <= '0'; RW <= '0'; swap <= '0';
			
			if first_four_bits = "0000" then E <= '1'; T <= '1';                                                       -- LDD 1
				decode_s <= "00110"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "0001" then MR <= '1'; RW <= '1'; WB <= "10"; E <= '1'; T <= '1'; C <= '1';           -- LDD 2
				decode_s <= "00111"; excute_s <= "0000000000"; memory_s <= "100010"; write_back_s <= "0010";
			elsif first_four_bits = "0010" then src <= '1'; E <= '1'; T <= '1';                                           -- STD 1
				decode_s <= "01110"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "0011" then MW <= '1'; E <= '1'; T <= '1'; C <= '1';                                  -- STD 2
				decode_s <= "00111"; excute_s <= "0000000000"; memory_s <= "010000"; write_back_s <= "0000";
			elsif first_four_bits = "0100" then src <= '1'; E <= '1'; T <= '1';                                           -- SHL 1
				decode_s <= "01110"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "0101" then ALU <= "1000"; src1 <= '1'; E <= '1'; T <= '1'; C <= '1';                 -- SHL 2
				decode_s <= "00111"; excute_s <= "0000101000"; memory_s <= "000000"; write_back_s <= "0010";
			elsif first_four_bits = "0110" then src <= '1'; E <= '1'; T <= '1';                                           -- SHR 1
				decode_s <= "01110"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "0111" then ALU <= "1001"; src1 <= '1'; E <= '1'; T <= '1'; C <= '1';                 -- SHR 2
				decode_s <= "00111"; excute_s <= "0000101001"; memory_s <= "000000"; write_back_s <= "0010";
			elsif first_four_bits = "1000" then E <= '1'; T <= '1';                                                       -- LDM 1
				decode_s <= "00110"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "1001" then RW <= '1'; WB <= "11"; E <= '1'; T <= '1'; C <= '1';                      -- LDM 2
				decode_s <= "00111"; excute_s <= "0000000000"; memory_s <= "000011"; write_back_s <= "0010";
			elsif first_four_bits = "1010" then E <= '1';                                                                 -- IADD 1
				decode_s <= "00100"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
			elsif first_four_bits = "1011" then src2 <= '1'; ALU <= "0100"; RW <= '1'; WB <= "01"; E <= '1'; C <= '1';    -- IADD 2
				decode_s <= "00101"; excute_s <= "0000010100"; memory_s <= "000001"; write_back_s <= "0010";
			elsif first_four_bits = "1100" then ALU <= "0010"; RW <= '1'; WB <= "01";                                     -- OR
				decode_s <= "00000"; excute_s <= "0000000010"; memory_s <= "000001"; write_back_s <= "0010";
			elsif first_four_bits = "1101" then ALU <= "0001"; RW <= '1'; WB <= "01";                                     -- AND
				decode_s <= "00000"; excute_s <= "0000000001"; memory_s <= "000001"; write_back_s <= "0010";
			elsif first_four_bits = "1110" then src <= '1'; swap <= '1'; ALU <= "1010"; WB <= "01";                       -- SWAP
				decode_s <= "01000"; excute_s <= "0000001010"; memory_s <= "000001"; write_back_s <= "0001";

			elsif first_four_bits = "1111" then

				if last_six_bits(1 downto 0) = "10" then ALU <= "0101"; RW <= '1'; WB <= "01";                 -- SUB
					decode_s <= "00000"; excute_s <= "0000000101"; memory_s <= "000001"; write_back_s <= "0010";
				elsif last_six_bits(1 downto 0) = "11" then ALU <= "0100"; RW <= '1'; WB <= "01";              -- ADD
					decode_s <= "00000"; excute_s <= "0000000100"; memory_s <= "000001"; write_back_s <= "0010";

				elsif last_six_bits = "000000" then src <= '1'; ALU <= "0011"; RW <= '1'; WB <= "01";          -- NOT
					decode_s <= "01000"; excute_s <= "0000000011"; memory_s <= "000001"; write_back_s <= "0010";
				elsif last_six_bits = "000100" then src <= '1'; ALU <= "0110"; RW <= '1'; WB <= "01";          -- INC
					decode_s <= "01000"; excute_s <= "0000000110"; memory_s <= "000001"; write_back_s <= "0010";
				elsif last_six_bits = "001000" then src <= '1'; ALU <= "0111"; RW <= '1'; WB <= "01";          -- DEC
					decode_s <= "01000"; excute_s <= "0000000111"; memory_s <= "000001"; write_back_s <= "0010";
				elsif last_six_bits = "001100" then src <= '1'; out_seg <= '1';                                -- OUT
					decode_s <= "01000"; excute_s <= "0100000000"; memory_s <= "000000"; write_back_s <= "0000";
				elsif last_six_bits = "010000" then in_seg <= '1'; RW <= '1';                                  -- IN
					decode_s <= "00000"; excute_s <= "1000000000"; memory_s <= "000000"; write_back_s <= "0010";
				elsif last_six_bits = "010100" then res_f <= '1'; read_from_stack <= '1'; WD_sel <= "01";      -- NOP/ RTI 1
					decode_s <= "00000"; excute_s <= "0001000000"; memory_s <= "000100"; write_back_s <= "1000";
				elsif last_six_bits = "011000" then read_from_stack <= '1'; write_in_pc <= '1'; WB <= "01";    -- NOP/ RTI 2
					decode_s <= "00000"; excute_s <= "0000000000"; memory_s <= "000101"; write_back_s <= "0100";
				else if last_six_bits = "011100" then                                                            -- NOP
					decode_s <= "00000"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
				elsif last_six_bits = "100000" then src <= '1'; write_in_stack <= '1';                         -- PUSH
					decode_s <= "01000"; excute_s <= "0000000000"; memory_s <= "001000"; write_back_s <= "0000";
				elsif last_six_bits = "100100" then read_from_stack <= '1'; RW <= '1'; WB <= "10";    -- POP
					decode_s <= "00000"; excute_s <= "0000000000"; memory_s <= "000110"; write_back_s <= "0010";
				--else if last_six_bits = "101000" then                                                            -- NOP
				elsif last_six_bits = "101100" then read_from_stack <= '1'; write_in_pc <= '1'; WB <= "10";    -- RET
					decode_s <= "00000"; excute_s <= "0000000000"; memory_s <= "000110"; write_back_s <= "0100";
				elsif last_six_bits = "110000" then write_in_stack <= '1'; WD_sel <= "10";                     -- CALL
					decode_s <= "00000"; excute_s <= "0010000000"; memory_s <= "001000"; write_back_s <= "0000";
				--else if last_six_bits = "110100" then                                                            -- RTI ghanged -------
				elsif last_six_bits = "111000" then BE <= '1';                                                 -- JZ
					decode_s <= "10000"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
				--else if last_six_bits = "111100" then                                                            -- JMP
				else
					decode_s <= "00000"; excute_s <= "0000000000"; memory_s <= "000000"; write_back_s <= "0000";
				end if;
			end if;
		end if;
	end if;
end process;

end architecture;


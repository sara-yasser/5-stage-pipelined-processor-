LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity ripple_adder IS
    PORT(
        a,b : in STD_LOGIC_VECTOR (31  DOWNTO 0);
        sum : out STD_LOGIC_VECTOR (31 DOWNTO 0);
        cout : out STD_LOGIC
        );
end entity;

architecture ripple_adder_arc of ripple_adder is

    signal ctemp : STD_LOGIC_VECTOR (31 DOWNTO 0);
begin
      a0:  entity work.full_adder port map(a(0),b(0),'0',sum(0),ctemp(0));
      l1: 
      for i in 1 to 31 generate
          a1:  entity work.full_adder port map(a(i),b(i),ctemp(i-1),sum(i),ctemp(i));
      end generate;
      cout <= ctemp(31);
end architecture;


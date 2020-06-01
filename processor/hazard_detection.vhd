LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity hazard_detection is
    generic (
        n : integer := 32
    );

  port (
    clk :   in std_logic;
    mem_rd  :   in std_logic;
    reg_rd  :   in std_logic_vector(n - 1 downto 0);
    reg_rt, reg_rs  :   in std_logic_vector(n - 1 downto 0);
    stall_sig   :   in std_logic
  ) ;
end hazard_detection;

architecture hazard_detection_arch of hazard_detection is

    -- signal 

begin

    process (clk)
    begin
        if (clk'event and clk='1') then
            stall_sig <= '0';

            -- check for hazard
            if mem_rd = '1' then
                if reg_rd = reg_rt or reg_rd = reg_rs then
                    -- hazard => Time of stall
                    stall_sig <= '1';
                end if ;
            end if ;
        end if ;

    end process;

end hazard_detection_arch ; -- hazard_detection_arch
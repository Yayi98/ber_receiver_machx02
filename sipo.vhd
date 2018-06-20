library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SIPO is
    Port ( sdata : in  STD_LOGIC;
           pdata : out  STD_LOGIC_VECTOR (9 downto 0);
           sclk   : in  STD_LOGIC;
           reset : in STD_LOGIC);
end SIPO;

architecture Behavioral of SIPO is
begin
    process(sclk,reset)
        variable temp : std_logic_vector(9 downto 0) := (others => '0');
    begin
        if reset = '0' then
            if sclk'event and sclk = '1' then
                temp(9) := temp(8);
                temp(8) := temp(7);
                temp(7) := temp(6);
                temp(6) := temp(5);
                temp(5) := temp(4);
                temp(4) := temp(3);
                temp(3) := temp(2);
                temp(2) := temp(1);
                temp(1) := temp(0);
                temp(0) := sdata;
            end if;
        else
            if reset'event and reset = '1' then
                temp := (others => '0');
            end if;
        end if;
        pdata <= temp;
    end process;

end Behavioral;

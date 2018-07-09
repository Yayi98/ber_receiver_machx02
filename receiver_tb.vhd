library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receiver_tb is
end receiver_tb;

architecture behavior of receiver_tb is

component receiver is
port (
    sclk  : in std_logic;
    clkx8 : in std_logic;
    ce    : in std_logic;
    reset : in std_logic;
    sdata : in std_logic;
    ber   : out std_logic_vector (7 downto 0)
    );
end component;

signal sclk  : std_logic := '0';
signal reset : std_logic := '1';
signal ce    : std_logic := '0';
signal clkx8 : std_logic := '0';
signal sdata : std_logic := '1';
signal ber   : std_logic_vector (7 downto 0);
constant CLK_PERIOD : time := 10 ns;

begin

   uut : receiver port map (
            sclk => sclk,
            reset => reset,
            ber => ber,
            ce  => ce,
            clkx8 => clkx8,
            sdata => sdata
        );

   Clk_process : process
   begin
        sclk <= '0';
        wait for CLK_PERIOD/2;
        sclk <= '1';
        wait for CLK_PERIOD/2;
   end process;

   data_proc : process
   begin
       sdata <= '0';
       wait for 10*(CLK_PERIOD/2);
       sdata <= '1';
       wait for 10*(CLK_PERIOD/2);
   end process;

   clkx8_proc : process
   begin
       clkx8 <= '0';
       wait for CLK_PERIOD*4;
       clkx8 <= '1';
       wait for CLK_PERIOD*4;
   end process;
   -- Stimulus process, Apply inputs here.
  stim_proc: process
   begin
        wait for CLK_PERIOD*10;
        reset <='0';
        wait for CLK_PERIOD*2;
        ce <= '1';
  end process;

end behavior;

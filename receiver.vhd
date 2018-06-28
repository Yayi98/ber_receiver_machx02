----------------------------------------------------------------------------
--  receiver.vhd
--	Version 1.0
--
--  Copyright (C) 2018 Mahesh Chandra Yayi
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity receiver is

    generic (
    SEED : std_logic_vector (31 downto 0)
            := "10101010110011001111000001010011"
    );

    port (
        sclk    : in std_logic; -- sclk_freq = clk_freq * 10
        clk     : in std_logic;
        clkx8   : in std_logic; -- clkx8_freq = clk_freq * 8
        ce      : in std_logic;
        alignwd : in std_logic;
        reset   : in std_logic;
        sdata   : in std_logic;
        ber     : out std_logic_vector(7 downto 0)
    );

end receiver;

architecture rtl of receiver is

    signal sipo2dec  : std_logic_vector(9 downto 0);
    signal dec2ber   : std_logic_vector(7 downto 0);
    signal err_bits  : std_logic;
    signal rng_lsb   : std_logic_vector(23 downto 0);
    signal rng       : std_logic_vector(7 downto 0);
    signal error_reg : std_logic_vector(7 downto 0);

begin

    sipo : entity work.deserializer8_1
    port map (
        sclk     => sclk,
        clk      => clk,
        sdataIn  => sdata,
        reset    => reset,
        pdataOut => sipo2dec,
        alignwd  => alignwd
    );

    decoder : entity work.dec_8b10b
    port map (
        RESET => reset,
        RBYTECLK => clk,
        AI => sipo2dec (kParallelWidth-1),
        BI => sipo2dec (kParallelWidth-2),
        CI => sipo2dec (kParallelWidth-3),
        DI => sipo2dec (kParallelWidth-4),
        EI => sipo2dec (kParallelWidth-5),
        FI => sipo2dec (kParallelWidth-6),
        GI => sipo2dec (kParallelWidth-7),
        HI => sipo2dec (kParallelWidth-8),
        II => sipo2dec (kParallelWidth-9),
        JI => sipo2dec (kParallelWidth-10),
        KO => open,
        AO => dec2ber(7),
        BO => dec2ber(6),
        CO => dec2ber(5),
        DO => dec2ber(4),
        EO => dec2ber(3),
        FO => dec2ber(2),
        GO => dec2ber(1),
        HO => dec2ber(0)
    );

    prng : entity work.prng32
    generic map (
        SEED => SEED
    )
    port map (
        clk   => clk,
        ce    => ce,
        reset => reset,
        rng (31 downto 24) => rng,
        rng (23 downto 0) => rng_lsb
    );

    counter_inst : entity work.count_ones
    port map (
        A    => error_reg,
        ones => err_bits
    );

    ber_proc : process(clkx8,reset)
    begin
        if rising_edge(clkx8) then
            if reset = '0' then
                error_reg <= rng xor dec2ber;
            else
                error_reg <= (others => '0');
            end if;
        end if;
    end process ber_proc;

    ber <= err_bits;

end rtl;

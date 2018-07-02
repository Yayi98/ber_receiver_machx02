library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY lattice;
USE lattice.components.all;

LIBRARY machxo2;
USE machxo2.all;

entity deserializer8_1 is
    port (
        sdataIn  : in std_logic;
        sclk     : in std_logic;
        clk      : in std_logic;
        reset    : in std_logic;
        alignwd  : in std_logic;
        pdataOut : out std_logic_vector (7 downto 0)
    );
end deserializer8_1;

architecture rtl of deserializer8_1 is

    signal reg40       : std_logic_vector (39 downto 0) := (others => '0');
    signal pdata2mux   : std_logic_vector (7 downto 0)  := (others => '0');
    signal mux2reg40   : std_logic_vector (7 downto 0)  := (others => '0');
    signal decoderIn   : std_logic_vector (9 downto 0)  := (others => '0');
    signal decoderOut  : std_logic_vector (7 downto 0)  := (others => '0');
    signal mux1select  : std_logic := '0';
    signal mux2select  : std_logic := '0';

    component IDDRX4B
    generic (
        GSR : string
    );
    port (
        D,ECLK,SCLK,RST,ALIGNWD : in std_logic;
        Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7 : out std_logic
    );
    end component;

begin

    deserializer_inst : IDDRX4B
    generic map (
        GSR => "ENABLED"
    )
    port map (
        D       => sdataIn,
        ECLK    => sclk,
        SCLK    => clk,
        RST     => reset,
        ALIGNWD => alignwd,
        Q0      => pdata2mux(0),
        Q1      => pdata2mux(1),
        Q2      => pdata2mux(2),
        Q3      => pdata2mux(3),
        Q5      => pdata2mux(4),
        Q4      => pdata2mux(5),
        Q6      => pdata2mux(6),
        Q7      => pdata2mux(7)
    );

    decoder_inst : entity work.dec_8b10b
    port map (
        RESET    => reset,
        RBYTECLK => clk,
        AI       => decoderIn(0),
        BI       => decoderIn(1),
        CI       => decoderIn(2),
        DI       => decoderIn(3),
        EI       => decoderIn(4),
        FI       => decoderIn(5),
        GI       => decoderIn(6),
        HI       => decoderIn(7),
        II       => decoderIn(8),
        JI       => decoderIn(9),
        HO       => decoderOut(7),
        GO       => decoderOut(6),
        FO       => decoderOut(5),
        EO       => decoderOut(4),
        DO       => decoderOut(3),
        CO       => decoderOut(2),
        BO       => decoderOut(1),
        AO       => decoderOut(0)
    );

    loadreg : process(clk,reset)
    variable temp1 : integer range 0 to 4 := 4;-- temp1 is initiated with 4 because the counting must start from 0
    begin
        if reset = '1' then
            temp1 := 0
            reg40 <= (others => '0');
        elsif clk'event and clk = '1' then
            if temp1 = 4 then
                temp1 := 0;
            else
                temp1 := temp1 + 1;
            end if;
        end if;
        regfull <= '0';
        case temp1 is
            when 0 =>
                pdata2mux <= reg40(39 downto 32);
                reg40(31 downto 0) <= (others => '0');
            when 1 =>
                pdata2mux <= reg40(31 downto 24);
                reg40(39 downto 32) <= (others => '0');
            when 2 =>
                pdata2mux <= reg40(23 downto 16);
                reg40(31 downto 24) <= (others => '0');
            when 3 =>
                pdata2mux <= reg40(15 downto 8);
                reg40(23 downto 16) <= (others => '0');
            when 4 =>
                pdata2mux <= reg40(7 downto 0);
                reg40(15 downto 8) <= (others => '0');
        end case;
    end process;

    clrreg : process(clk,reset)
    signal temp2 : integer range 0 to 3 : 3;-- temp2 is initiated with 3 because the counting must start from 0
    begin
        if reset = '1' then
            temp2 <= 0;
        elsif clk'event and clk = '1' then
            temp2 <= temp2 + 1;
        end if;
        case temp2 is
            when 0 =>
                decoderOut <= reg40(39 downto 32);
            when 1 =>
                decoderOut <= reg40(31 downto 24);
            when 2 =>
                decoderOut <= reg40(23 downto 16);
            when 3 =>
                decoderOut <= reg40(15 downto 8);
            when 4 =>
                decoderOut <= reg40(7 downto 0);
        end case;
    end process;

    pdataOut <= decoderOut;

end rtl;

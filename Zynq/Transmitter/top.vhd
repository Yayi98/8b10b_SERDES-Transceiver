----------------------------------------------------------------------------
--  top.vhd
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
    generic (
        SEED : std_logic_vector(31 downto 0)
                := "10101010110011001111000001010011"
    );
    port (
    -- Note : frequency of clk = (frequency of sclk) / 5
    -- inputs of prng32, 8b10b_enc and serializer
        clk   : in std_logic; -- clk for prng and 8b10b_enc
        sclk  : in std_logic; -- clk for the right side of serializer
        ce    : in std_logic;
        reset : in std_logic;

        -- ouputs of serializer
        dout_p  : out std_logic;
        dout_n  : out std_logic
    );

end top;

architecture behavioral of top is

    -- output ports of prng32
    signal rng   : std_logic_vector (31 downto 0);

    -- inputs of 8b10b_enc
    signal KI       : std_logic := '0'; -- Control (K) input(active high)
    signal AI       : std_logic := '0'; --MSB
    signal BI       : std_logic := '0';
    signal CI       : std_logic := '0';
    signal DI       : std_logic := '0';
    signal EI       : std_logic := '0';
    signal FI       : std_logic := '0';
    signal GI       : std_logic := '0';
    signal HI       : std_logic := '0'; --LSB

    -- ouputs of 8b10b_enc
    signal JO       : std_logic := '0'; --MSB
    signal HO       : std_logic := '0';
    signal GO       : std_logic := '0';
    signal FO       : std_logic := '0';
    signal IO       : std_logic := '0';
    signal EO       : std_logic := '0';
    signal DO       : std_logic := '0';
    signal CO       : std_logic := '0';
    signal BO       : std_logic := '0';
    signal AO       : std_logic := '0'; --LSB


    -- outputs of serializer
    signal serial  : std_logic;

    -- inputs of OBUFDS
    signal O  : std_logic := '0';
    signal OB : std_logic := '0';

    -- output of OBUFDS
    signal I  : std_logic := '0';


begin

    prng_inst : entity work.prng32
    generic map (
        SEED => SEED
    )
    port map (
        clk   => clk,
        ce    => ce,
        reset => reset,
        rng   => rng
    );

    enc_inst : entity work.enc_8b10b
    port map (
        KI => KI,
        AI => AI,
        BI => BI,
        CI => CI,
        DI => DI,
        EI => EI,
        FI => FI,
        GI => GI,
        HI => HI,
        JO => JO,
        HO => HO,
        GO => GO,
        FO => FO,
        IO => IO,
        EO => EO,
        DO => DO,
        CO => CO,
        BO => BO,
        AO => AO,
        RESET    => reset,
        SBYTECLK => clk
    );

    serdes_inst : entity work.serialiser_10_to_1
    port map (
        clk     => clk,
        clk_x5  => sclk,
        reset   => reset,
        data(9) => AO,
        data(8) => BO,
        data(7) => CO,
        data(6) => DO,
        data(5) => EO,
        data(4) => IO,
        data(3) => FO,
        data(2) => GO,
        data(1) => HO,
        data(0) => JO,
        serial => serial );

    OBUFDS_inst : OBUFDS
    generic map (
        IOSTANDARD => "DEFAULT",
        SLEW => "SLOW")
    port map (
        O => O,
        OB => OB,
        I => I
    );

    AI <= rng(31);
    BI <= rng(30);
    CI <= rng(29);
    DI <= rng(28);
    EI <= rng(27);
    FI <= rng(26);
    GI <= rng(25);
    HI <= rng(24);

    I  <= serial;

    dout_p <= O;
    dout_n <= OB;

end behavioral;

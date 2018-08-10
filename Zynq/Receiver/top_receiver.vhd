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

entity top_receiver is
    generic (
        --kIDLY_TapWidth : natural := 5;
        kParallelWidth : natural := 10;
        SEED : std_logic_vector (31 downto 0)
                := "10101010110011001111000001010011"
    );
    port (
        clk   : in std_logic; -- clk for prng and 8b10b_enc
        sclk  : in std_logic; -- clk for the right side of serializer
        ce    : in std_logic;
        reset : in std_logic;
        din_p : in std_logic;
        din_n : in std_logic;
        ber   : out std_logic_vector ( 7 downto 0 )
    );

end top_receiver;

architecture behavioral of top_receiver is
    signal sDataIn_p : std_logic;
    signal sDataIn_n : std_logic;
    signal pDataOut   : std_logic_vector (kParallelWidth-1 downto 0);
    --signal pBitslip  : std_logic := '0';
    --signal pIDLY_LD  : std_logic;
    --signal pIDLY_CE  : std_logic;
    --signal pIDLY_INC : std_logic;
    --signal pIDLY_CNT : std_logic_vector (kIDLY_TapWidth-1 downto 0);
    signal KO        : std_logic;
    signal rng       : std_logic_vector (7 downto 0);
    signal dout      : std_logic_vector (7 downto 0);
    signal error_reg : std_logic_vector (7 downto 0);
    signal err_bits  : std_logic_vector (7 downto 0)  := (others => '0');
    signal rng_lsb   : std_logic_vector (23 downto 0) := (others => '0');

begin

    error_reg <= dout xor rng;
    sDataIn_p <= din_p;
    sDataIn_n <= din_n;

    deserializer_inst : entity work.deserializer
    generic map (
        --kIDLY_TapWidth => kIDLY_TapWidth,
        OPWIDTH => kParallelWidth
    )
    port map (
        clk  => clk,
        sclk => sclk,
        sDataIn_p => sDataIn_p,
        sDataIn_n => sDataIn_n,
        pDataOut  => pDataOut,
        reset      => reset
    );

    decoder_inst : entity work.dec_8b10b
    port map (
        RESET => reset,
        RBYTECLK => clk,
        AI => pDataOut (kParallelWidth-1),
        BI => pDataOut (kParallelWidth-2),
        CI => pDataOut (kParallelWidth-3),
        DI => pDataOut (kParallelWidth-4),
        EI => pDataOut (kParallelWidth-5),
        FI => pDataOut (kParallelWidth-6),
        GI => pDataOut (kParallelWidth-7),
        HI => pDataOut (kParallelWidth-8),
        II => pDataOut (kParallelWidth-9),
        JI => pDataOut (kParallelWidth-10),
        KO => KO,
        AO => dout(7),
        BO => dout(6),
        CO => dout(5),
        DO => dout(4),
        EO => dout(3),
        FO => dout(2),
        GO => dout(1),
        HO => dout(0)
    );

    prng_inst : entity work.prng32
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

    ber <= err_bits;

end behavioral;

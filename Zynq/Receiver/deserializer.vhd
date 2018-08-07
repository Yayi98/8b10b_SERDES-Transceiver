----------------------------------------------------------------------------
--  deserializer.vhd
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

entity deserializer is
    generic (
        OPWIDTH : natural := 10
    );
    port (
        clk  : in std_logic;
        sclk : in std_logic;
        reset : in std_logic;
        sDataIn_p : in std_logic;
        sDataIn_n : in std_logic;
        pDataOut : out std_logic_vector ( OPWIDTH-1 downto 0 )
    );
end deserializer;

architecture rtl of deserializer is

    signal shift1  : std_logic := '0';
    signal shift2  : std_logic := '0';
    signal clkinv  : std_logic := '0';
    signal sDataIn : std_logic := '0';

begin

    clkinv <= not sclk;

    InputBuffer: IBUFDS
    generic map (
        DIFF_TERM  => FALSE,
        IOSTANDARD => "LVDS_25")
    port map (
        I          => sDataIn_p,
        IB         => sDataIn_n,
        O          => sDataIn);


    master_iserdes : ISERDESE2
    generic map (
        DATA_RATE         => "DDR",
        DATA_WIDTH        => OPWIDTH,
        INTERFACE_TYPE    => "NETWORKING",
        DYN_CLKDIV_INV_EN => "FALSE",
        DYN_CLK_INV_EN    => "FALSE",
        NUM_CE            => 2,
        OFB_USED          => "FALSE",
        IOBDELAY          => "NONE",         -- Use input at DDLY to output the data on Q1-Q6
        SERDES_MODE       => "MASTER")
    port map (
        BITSLIP   => '0',
        CE1       => '1',
        CE2       => '1',
        CLK       => sclk,
        CLKB      => clkinv,
        CLKDIV    => clk,
        CLKDIVP   => '0',
        D         => sDataIn,
        DDLY      => '0',
        O         => open,
        OCLK      => '0',
        OCLKB     => '0',
        OFB       => '0',
        SHIFTIN1  => '0',
        SHIFTIN2  => '0',
        SHIFTOUT1 => shift1,
        SHIFTOUT2 => shift2,
        DYNCLKDIVSEL => '0',
        DYNCLKSEL    => '0',
        RST       => reset,
        Q1        => pDataOut(0),
        Q2        => pDataOut(1),
        Q3        => pDataOut(2),
        Q4        => pDataOut(3),
        Q5        => pDataOut(4),
        Q6        => pDataOut(5),
        Q7        => pDataOut(6),
        Q8        => pDataOut(7)
    );

    slave_iserdes : ISERDESE2
    generic map (
        DATA_RATE         => "DDR",
        DATA_WIDTH        => OPWIDTH,
        INTERFACE_TYPE    => "NETWORKING",
        DYN_CLKDIV_INV_EN => "FALSE",
        DYN_CLK_INV_EN    => "FALSE",
        NUM_CE            => 2,
        OFB_USED          => "FALSE",
        IOBDELAY          => "NONE",         -- Use input at DDLY to output the data on Q1-Q6
        SERDES_MODE       => "SLAVE")
    port map (
        BITSLIP   => '0',
        CE1       => '1',
        CE2       => '1',
        CLK       => sclk,
        CLKB      => clkinv,
        CLKDIV    => clk,
        CLKDIVP   => '0',
        D         => '0',
        DDLY      => '0',
        O         => open,
        OCLK      => '0',
        OCLKB     => '0',
        OFB       => '0',
        SHIFTIN1  => shift1,
        SHIFTIN2  => shift2,
        DYNCLKDIVSEL  => '0',
        DYNCLKSEL     => '0',
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        RST       => reset,
        Q1        => open,
        Q2        => open,
        Q3        => pDataOut(8),
        Q4        => pDataOut(9),
        Q5        => open,
        Q6        => open,
        Q7        => open,
        Q8        => open
    );
end rtl;

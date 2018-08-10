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
        clkx8   : in std_logic; -- clkx8_freq = clk_freq * 8
        ce      : in std_logic;
        reset   : in std_logic;
        sdata   : in std_logic;
        ber     : out std_logic_vector(7 downto 0)
    );

end receiver;

architecture rtl of receiver is

	signal clkout      : std_logic;
    signal dec2ber   : std_logic_vector (7 downto 0);
    signal err_bits  : std_logic_vector (7 downto 0);
    signal rng_lsb   : std_logic_vector (23 downto 0);
    signal rng       : std_logic_vector (7 downto 0);
    signal error_reg : std_logic_vector (7 downto 0);

begin

    decoder_inst : entity work.deserializer8_1
    port map (
        sdataIn  => sdata,
        sclk1    => sclk,
        reset    => reset,
		clkout   => clkout,
        pdataOut => dec2ber
    );

    prng : entity work.prng32
    generic map (
        SEED => SEED
    )
    port map (
        clk   => clkout,
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
        if reset = '0' then
            if rising_edge(clkx8) then
                error_reg <= rng xor dec2ber;
            end if;
        else
            error_reg <= (others => '0');
        end if;
    end process ber_proc;

    ber <= err_bits;

end rtl;

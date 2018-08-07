----------------------------------------------------------------------------
--  prng.vhd
--	Pseudo Random Generators
--	Version 1.0
--
--  Copyright (C) 2014 H.Poetzl
--
--  Modified by Mahesh Chandra Yayi
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity prng32 is
    generic(
        SEED : std_logic_vector(31 downto 0)
                        := "10101010110011001111000001010011"
    );
    port(
    	clk   : in std_logic;
    	ce    : in std_logic;
        reset : in std_logic;
    	rng   : out std_logic_vector (31 downto 0)
    );
end prng32;



----------------------------------------------------------------------------
--  LFSR RNG (Fibonacci)
--	(32,22,2,1,0)
--	Version 1.0
--
----------------------------------------------------------------------------

architecture LFSR_FIB of prng32 is

    signal fb : std_logic;
    signal sr : std_logic_vector (31 downto 0) := SEED;

begin

    prng : process (clk, reset)
    begin
    if reset = '1' then
        sr <= SEED;
    end if;
    if reset = '0' then
        if rising_edge(clk) then
    	    if ce = '1' then

    		    fb <= sr(31) xor sr(21) xor sr(1) xor sr(0);
    		    sr <= sr(30 downto 0) & fb;

    	    end if;
    	end if;
    end if;
    end process;

    rng <= sr;

end LFSR_FIB;

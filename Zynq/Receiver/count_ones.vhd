----------------------------------------------------------------------------
--  ones.vhd
--	Version 1.0
--
--  Copyright (C) 2018 Mahesh Chandra Yayi
--
--  Modified from source : http://vhdlguru.blogspot.com/2017/10/count-number-of-1s-in-binary-number.html
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity count_ones is
    port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           ones : out  STD_LOGIC_VECTOR (7 downto 0));
end count_ones;

architecture Behavioral of count_ones is
begin
    count_ones : process(A)
    variable count : unsigned(7 downto 0) := (others => '0');
    begin
        count := "00000000";
        for i in 0 to 7 loop
            count := count + ("0000000" & A(i));
        end loop;
        ones <= std_logic_vector(count);
    end process;
end Behavioral;

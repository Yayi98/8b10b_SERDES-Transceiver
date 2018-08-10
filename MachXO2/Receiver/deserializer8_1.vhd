library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY machxo2;
USE machxo2.all;

entity deserializer8_1 is
    port (
        sdataIn  : in std_logic;
        sclk1    : in std_logic;
        reset    : in std_logic;
		clkout   : out std_logic;
        pdataOut : out std_logic_vector (7 downto 0)
    );
end deserializer8_1;

architecture rtl of deserializer8_1 is

    signal sclk    : std_logic;
    signal clk     : std_logic;
    signal stop    : std_logic;
    signal reg40       : std_logic_vector (39 downto 0) := (others => '0');
    signal pdata2mux   : std_logic_vector (7 downto 0)  := (others => '0');
    signal mux2reg40   : std_logic_vector (7 downto 0)  := (others => '0');
    signal decoderIn   : std_logic_vector (9 downto 0)  := (others => '0');
    signal decoderOut  : std_logic_vector (7 downto 0)  := (others => '0');
    signal tempreg     : std_logic_vector (9 downto 0)  := (others => '0');

    component IDDRX4B
    generic (
        GSR : string
    );
    port (
        D,ECLK,SCLK,RST,ALIGNWD : in std_logic;
        Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7 : out std_logic
    );
    end component;

    component CLKDIVC
    generic (
        DIV : string;
        GSR : string);
    port (
        RST: in  std_logic;
        CLKI: in  std_logic;
        ALIGNWD: in  std_logic;
        CDIV1: out std_logic;
        CDIVX : out std_logic);
    end component;

    component ECLKSYNCA
    port (
        ECLKI : in std_logic;
        STOP  : in std_logic;
        ECLKO : out std_logic);
    end component;

begin

    ECLKSYNCA_inst : ECLKSYNCA
    port map (
        ECLKI => sclk1,
        STOP  => stop,
        ECLKO => sclk
    );

    clkdiv_inst : CLKDIVC
    generic map (
        DIV => "4.0",
        GSR => "ENABLED"
    )
    port map (
        RST     => reset,
        ALIGNWD => '1',
        CLKI    => sclk,
        CDIV1   => open,
        CDIVX   => clk
    );

    deserializer_inst : IDDRX4B
    generic map (
        GSR => "ENABLED"
    )
    port map (
        D       => sdataIn,
        ECLK    => sclk,
        SCLK    => clk,
        RST     => reset,
        ALIGNWD => '1',
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

    deserialize_proc : process(clk,reset)
    variable temp1 : integer range 0 to 4 := 4;
    begin
        if reset = '0' then
            if clk'event and clk = '1' then
                if temp1 = 4 then
                    temp1 := 0;
                else
                    temp1 := temp1 + 1;
                end if;
            end if;
        else
            temp1 := 4;
        end if;
        case temp1 is
            when 0 =>
                reg40 (39 downto 32) <= pdata2mux;
                decoderIn <= tempreg;
            when 1 =>
                reg40 (31 downto 24) <= pdata2mux;
                decoderIn <= reg40 (39 downto 30);
            when 2 =>
                reg40 (23 downto 16) <= pdata2mux;
                decoderIn <= reg40 (29 downto 20);
            when 3 =>
                reg40 (15 downto 8) <= pdata2mux;
                decoderIn <= reg40 (19 downto 10);
            when 4 =>
                reg40 (7 downto 0) <= pdata2mux;
                decoderIn <= reg40 (9 downto 0);
        end case;
    end process;
    pdataOut <= decoderOut;
	clkout   <= clk;
end rtl;

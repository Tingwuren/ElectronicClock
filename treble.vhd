--高音C响铃
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity treble is
    port(
        highfre: in std_logic;
        --High frequency（高频，100KHz）
        enlow: in std_logic;
        --使能信号，高有效
        clear: in std_logic;
        --清零信号，高有效
        lowfre: out std_logic;
        --Low frequency（低音C频率，521Hz方波）
        speaker: out std_logic;
        --喇叭
    );
end treble;

--对100kHz的脉冲进行分频
architecture behavioral of treble is
begin
    signal ft: integer range 0 to 95;

    process(highfre, enlow, clear)
    begin
        if clr = '0' then
            ft <= 0;
            lowfre <= '0';
        elsif (highfre'event and highfre = '1') then
            if ft = 190 then
                --进行96分频
                ft <= 0;
                lowfre <= not lowfre;
                --2分频
            else
                ft <= ft + 1;
                lowfre = lowfre;
            end if;
        end if;
    end process;

end behavioral;
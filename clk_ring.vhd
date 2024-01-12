--提供1Hz和整点响铃脉冲
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_ring is
    port(
        highfre: in std_logic;
        --High frequency（高频，10KHz）
        lowfre: out std_logic
        --Low frequency（低频，1Hz）
    );
end clk_ring;

--对10kHz的脉冲进行分频
architecture behavioral of Frequency_divider is
    signal temp: integer range 0 to 9999;
    --临时变量，在0-9999一万个数之间循环递增
begin
    process(highfre)
    begin
        if (highfre'event and highfre = '1') then
            if temp = 9999 then
                lowfre <= '1';
                temp <= 0;
            else
				lowfre <= '0';
                temp <= temp + 1;
            end if;
        end if;
    end process;

end behavioral;
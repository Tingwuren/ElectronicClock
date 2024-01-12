--由1MHz得到100KHz
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--分频模块
entity Frequency_divider is
    port(
        highfre: in std_logic;
        --High frequency（高频，1MHz）
        lowfre: out std_logic
        --Low frequency（低频，100KHz）
    );
end Frequency_divider;

--对1MHz的脉冲进行分频
architecture behavioral of Frequency_divider is
    signal temp: integer range 0 to 9;
    --临时变量，在0-9十个数之间循环递增
begin
    process(highfre)
    begin
        if (highfre'event and highfre = '1') then
            if temp = 9 then
                lowfre <= '1';
                temp <= 0;
            else
				lowfre <= '0';
                temp <= temp + 1;
            end if;
        end if;
    end process;

end behavioral;
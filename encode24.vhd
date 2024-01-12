--2-4译码器
library ieee;
use ieee.std_logic_1164.all;

entity encode24 is
    port(
        a: in std_logic_vector(1 downto 0);
        y: out std_logic_vector(3 downto 0)
    );
end encode24;

architecture behavioral of encode24 is
begin
    with a select
        y <= "0001" when "00",--正常工作
             "0010" when "01",--调节时钟
             "0100" when "10",--调节分钟
             "1000" when "11",--调节秒钟
             "0000" when others;
end behavioral;

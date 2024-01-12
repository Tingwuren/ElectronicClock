--整点响铃信号
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ring is
    port(
        co: in std_logic;
        --分钟向小时的进位
        clk: in std_logic;
        --1Hz时钟信号
        enlow: out std_logic;
        --低音C使能信号，高电平有效
        enhigh: out std_logic
        --高音C使能信号，高电平有效
    );
end;

architecture behavioral of ring is
    signal count: integer range 0 to 4;

begin
    process(co, clk)
    begin
        if (clk'event and clk = '1') then
            if (count < 3) then
                --整点后前三秒使低音C使能
                count <= count + 1;
                enlow <= '1';
            elsif (count = 3) then
                --整点后第四秒使高音C使能，低音C禁用
                count <= count + 1;
                enlow <= '0';
                enhigh <= '1';
            else
                --整点第四秒后禁用低音和高音
                enlow <= '0';
                enhigh <= '0';
            end if;
        end if;
        if (co = '1') then
            --整点时刻，使count初始值为0
            count <= 0;
        end if;
    end process;

end behavioral;
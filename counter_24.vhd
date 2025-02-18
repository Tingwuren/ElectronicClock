--24进制计数器
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_24 is
    port(
        clk: in std_logic;
        --1Hz时钟信号
        clr: in std_logic;
        --清零信号
        qd: in std_logic;
        --单拍脉冲
        modify: in std_logic;
        --校时信号，高有效
        single: out std_logic_vector(3 downto 0); 
        --个位
        ten: out std_logic_vector(3 downto 0); 
        --十位
    );
end counter_24;

architecture behavioral of counter_24 is
    signal pulse: std_logic;

begin
    pulse <= clk when (modify = '0') else qd;

    process(pluse, clr) --24进制计数器
    begin
        if (clr = '0') then
            --清零
            single <= "0000";
            ten <= "0000";
        elsif (pluse'event and pluse = '1') then
            --计时
            if (single = 3 and ten = 2) then
                --23后变为00
                single <= "0000";
                ten <= "0000";
            elsif (single = 9) then
                --个位进位
                single <= "0000";
                ten <= ten + 1;
            else
                --个位加一
                single <= single + 1;
            end if;
        end if;
    end process;

end behavioral;
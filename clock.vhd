--顶层模块
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock is
    port(
        clr: in std_logic;
        --清零信号，高电平有效
        --SWA 4
        clk: in std_logic;
        --时钟信号，10KHz
        --CP1 56 IN 100KHz或10KHz
        highfre: in std_logic;
        --时钟信号，1MHz
        --MF 55 IN 主时钟
        qd: in std_logic;
        --调节控制信号，上升沿触发
        --QD 60 IN 启动按钮QD
        mode: in std_logic_vector(1 downto 0);
        --模式选择信号
        --“00”为正常工作状态
        --“01”状态下对小时进行修改
        --“10”状态下对分钟进行修改
        --“11”状态下对秒进行修改
        --SWC 6 SWB 5 IN
        hour1: out std_logic_vector(3 downto 0);
        --时钟十位
        --LG6 24 22 21 20
        hour0: out std_logic_vector(3 downto 0);
        --时钟个位
        --LG5 29 28 27 25
        minute1: out std_logic_vector(3 downto 0);
        --分钟十位
        --LG4 34 33 31 30
        minute0: out std_logic_vector(3 downto 0);
        --分钟个位
        --LG3 18 17 36 35
        second1: out std_logic_vector(3 downto 0);
        --秒钟十位
        --LG2 41 40 39 37
        second0: out std_logic_vector(6 downto 0);
        --秒钟个位
        --LG1 51 50 49 48 46 45 44
        speaker: out std_logic
        --响铃信号
        --SPEAKER 52 out
    );
end clock;

architecture behavioral of clock is
    --分频模块，提供1Hz脉冲
    component clk_ring 
        port(
            highfre: in std_logic;
            --High frequency（高频，10KHz）
            lowfre: out std_logic
            --Low frequency（低频，1Hz）
        );
    end component;

    --2-4译码器模块
    component encode24 is
        port(
            a: in std_logic_vector(1 downto 0);
            y: out std_logic_vector(3 downto 0)
        );
    end component;

    --模60计数器
    component counter_60
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
            co: out std_logic
            --进位
        );
    end component;

    --模24计数器模块
    component counter_24
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
            ten: out std_logic_vector(3 downto 0) 
            --十位
        );
    end component;

    --七段显示译码模块
    component display is
        port(
            pin: in std_logic_vector(3 downto 0);
            --8421BCD码
            pout: out std_logic_vector(6 downto 0)
            --七段显示译码
        );
    end component;

    --响铃控制模块
    component ring is
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
    end component;
    
    --低音C响铃
	component bass is
		port(
			highfre: in std_logic;
			--High frequency（高频，100KHz）
			enlow: in std_logic;
			--使能信号，高有效
			clr: in std_logic;
			--清零信号，高有效
			lowfre: out std_logic
			--Low frequency（低音C频率，261Hz方波）
		);
	end component;
	
	--高音C响铃
	component treble is
		port(
			highfre: in std_logic;
			--High frequency（高频，100KHz）
			enlow: in std_logic;
			--使能信号，高有效
			clr: in std_logic;
			--清零信号，高有效
			lowfre: out std_logic
			--Low frequency（低音C频率，521Hz方波）
		);
	end component;
	
	--由1MHz得到100KHz
	component divider is
		port(
			highfre: in std_logic;
			--High frequency（高频，1MHz）
			lowfre: out std_logic
			--Low frequency（低频，100KHz）
		);
	end component;
	
	--或门模块
	component or_gate is
		port(
			a: in std_logic;
			b: in std_logic;
			y: out std_logic
		);
	end component;

    signal lowfre: std_logic;
    --1Hz时钟信号c
    signal modify: std_logic_vector(3 downto 0);
    --译码后的模式选择信号
    signal bcd: std_logic_vector(3 downto 0);
    --秒钟个位译码为七段译码之前
    signal co0: std_logic;
    --秒钟向分钟的进位
    signal co1: std_logic;
    --分钟向时钟的进位
    signal f100k: std_logic;
    --100KHz
    signal enlow: std_logic;
    --低音C使能
    signal enhigh: std_logic;
    --高音C使能
    signal lowc: std_logic;
    --低音C输出
    signal highc: std_logic;
    --高音C输出

begin

    u1: clk_ring port map (clk, lowfre);
    --分频模块
    --对10KHz进行分频，产生1Hz时钟脉冲

    u2: encode24 port map (mode, modify);
    --2-4译码器
    --用于对mode译码产生四个控制信号

    u3: counter_60 port map (lowfre, clr, qd, modify(3), bcd, second1, co0);
    --秒钟计时模块
    --以modify(3)为选择，若为低电平则以时钟信号作为脉冲，否则以QD作为脉冲

    u4: display port map (bcd, second0);
    --七段显示译码模块，用于将秒钟个位译码为七段译码
    --将秒钟个位由8421BCD码转为七段显示译码

    u5: counter_60 port map (co0, clr, qd, modify(2), minute0, minute1, co1);
    --分钟计时模块
    --以modify(2)为选择，若为低电平则以秒钟进位作为脉冲信号，否则以QD作为脉冲

    u6: counter_24 port map (co1, clr, qd, modify(1), hour0, hour1);
    --时钟计时模块
    --以modify(1)为选择，若为低电平则以分钟进位作为脉冲信号，否则以QD作为脉冲

    u7: ring port map (co1, lowfre, enlow, enhigh);
    --响铃控制模块
    --通过分钟进位来产生响铃控制信号

    u8: divider port map (highfre, f100k);
    --由1MHz得到100KHz
    --采用100KHz来控制响铃的音调

    u9: bass port map (f100k, enlow, clr, lowc);
    --低音C响铃
    --若enlow为高，则响低音C

    u10: treble port map (f100k, enhigh, clr, highc);
    --高音C响铃
    --若enhigh为高，则响高音C

    u11: or_gate port map (lowc, highc, speaker);
    --或门模块
    --选择高音C或低音C中的一个给喇叭

end behavioral;

library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use ieee.std_logic_unsigned.all;

entity clk_enabler_adv is
	GENERIC (CONSTANT cnt_max : integer := 49999999;  pulse_time : integer := 49999999);      --  1.0 Hz 
	port(	
		clock:		  in std_logic;	 
		reset:        in std_logic;
		clk_en: 	     out std_logic;
		enable:		  in std_logic
	);
end clk_enabler_adv;

----------------------------------------------------

architecture behv of clk_enabler_adv is

signal clk_cnt: integer range 0 to cnt_max;

	 
begin

	process(clock)
	begin
	if rising_edge(clock) then
        if reset = '0' then
				if enable = '1' then
				  if (clk_cnt = cnt_max) then
						 clk_cnt <= 0;
					else
						 clk_cnt <= clk_cnt + 1;
					end if;
				end if;
        else
           clk_cnt <= 0;
        end if;
	end if;
	end process;
	
	clk_en <= '1' when clk_cnt = pulse_time else
				 '0';

end behv;

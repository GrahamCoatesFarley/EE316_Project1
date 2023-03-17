-- Rising Edge Detector
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RED is
	port(
		clk								:in std_logic;
		signal_input					:in std_logic;
		edge_detected					:out std_logic
	);
end RED;

architecture behavior of RED is
	signal sig1, sig2: std_logic := '0'; -- Registers for edge detection
begin
	process(clk)
	begin
		if rising_edge(clk) then
			sig1 <= signal_input;
			sig2 <= sig1;
		end if;
	end process;
	
	edge_detected <= ((not sig2) and sig1);

end behavior;
-- Seven Segment Look Up Table
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSegmentLUT is
	port(
		DataIn	: in std_logic_vector(3 downto 0);
		HEX		: out std_logic_vector(6 downto 0)
	);
end SevenSegmentLUT;

architecture behavior of SevenSegmentLUT is
begin
	
	HEX <= "1000000" when DataIn = "0000" else -- 0
			 "1111001" when DataIn = "0001" else -- 1
			 "0100100" when DataIn = "0010" else -- 2
			 "0110000" when DataIn = "0011" else -- 3
			 "0011001" when DataIn = "0100" else -- 4
			 "0010010" when DataIn = "0101" else -- 5
			 "0000010" when DataIn = "0110" else -- 6
			 "1111000" when DataIn = "0111" else -- 7
			 "0000000" when DataIn = "1000" else -- 8
			 "0011000" when DataIn = "1001" else -- 9
			 "0001000" when DataIn = "1010" else -- 10 A
			 "0000011" when DataIn = "1011" else -- 11 B
			 "1000110" when DataIn = "1100" else -- 12 C
			 "0100001" when DataIn = "1101" else -- 13 D
			 "0000110" when DataIn = "1110" else -- 14 E
			 "0001110" when DataIn = "1111";		 -- 15 F
	
end behavior;
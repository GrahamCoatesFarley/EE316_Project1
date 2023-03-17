--ROM Controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_Controller is
	generic(AddrSize: integer := 8; DataSize: integer := 16);
	port(
		clk, clk_en		: in std_logic;
		Address			: in std_logic_vector(AddrSize - 1 downto 0);
		delayedPulse	: out std_logic;
		DataOut			: out std_logic_vector(DataSize - 1 downto 0)
	);

end ROM_Controller;

architecture behavior of ROM_Controller is

	Component ROM IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END Component;
	
	signal delayIntermediate : std_logic;

begin
	
	-- Delaying the clock enable pulse by 1 clock cycle
	-- For use as a pulse input to the SRAM Controller
	process(clk)
	begin
		if rising_edge(clk) then
			delayedPulse <= clk_en;
		end if;
	end process;
	
	-- Creating an instance of the ROM
	ROM_Inst_1: ROM
		port map(
			address => address,
			clock => clk,
			q => DataOut
		);
		

end behavior;

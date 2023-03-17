library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_level is
end tb_top_level;

architecture testbench of tb_top_level is
	component top_level is
		generic(InternalAddrSize: integer := 8; OutAddrSize: integer := 20; DataBufferSize: integer := 16; FinalClockCount: integer := 1000);
		port(
			-- General Signals
			clk			: in std_logic;
			reset			: in std_logic;
			
			-- SRAM Outputs
			SRAM_ADDR	: out std_logic_vector(OutAddrSize - 1 downto 0);
			SRAM_DQ		: inout std_logic_vector(DataBufferSize - 1 downto 0);
			SRAM_CE_N	: out std_logic;
			SRAM_LB_N	: out std_logic;
			SRAM_UB_N	: out std_logic;
			SRAM_OE_N	: out std_logic;
			SRAM_WE_N	: out std_logic;
			
			-- 7-Segment Outputs
			HEX0			: out std_logic_vector(6 downto 0);
			HEX1			: out std_logic_vector(6 downto 0);
			HEX2			: out std_logic_vector(6 downto 0);
			HEX3			: out std_logic_vector(6 downto 0);
			HEX4			: out std_logic_vector(6 downto 0);
			HEX5			: out std_logic_vector(6 downto 0)
		);
	end component;
	
	-- Signals
	signal clk : std_logic := '0';
	signal reset, SRAM_CE_N, SRAM_LB_N, SRAM_UB_N, SRAM_OE_N, SRAM_WE_N: std_logic;
	signal SRAM_ADDR																		  : std_logic_vector(19 downto 0);
	signal SRAM_DQ																			  : std_logic_vector(15 downto 0);
	signal HEX0, HEX1, HEX2, HEX3, HEX4, HEX5										  : std_logic_vector(6 downto 0);
	
begin
	DUT: top_level
		port map(
			clk => clk,
			reset => reset,
			SRAM_CE_N => SRAM_CE_N,
			SRAM_LB_N => SRAM_LB_N,
			SRAM_OE_N => SRAM_OE_N,
			SRAM_WE_N => SRAM_WE_N,
			SRAM_UB_N => SRAM_UB_N,
			SRAM_ADDR => SRAM_ADDR,
			SRAM_DQ   => SRAM_DQ,
			HEX0 => HEX0,
			HEX1 => HEX1,
			HEX2 => HEX2,
			HEX3 => HEX3,
			HEX4 => HEX4,
			HEX5 => HEX5
		);
		
	clk <= not clk after 10 ns;
	process
	begin
	  reset <= '0';
	wait;
	end process;

end testbench;
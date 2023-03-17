--SRAM Controller
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAM_Controller is
	generic(AddrSize: integer := 8; DataSize: integer := 16; 
			  OutAddrSize: integer := 20; DataBufferSize: integer := 16);
	port(	
		clk		:		in std_logic;
		Address	:		in std_logic_vector(AddrSize - 1 downto 0);
		DataIn 	:		in std_logic_vector(DataSize - 1 downto 0);
		DataOut	:		out std_logic_vector(DataSize - 1 downto 0) := (others => '0');
		RW			:		in std_logic;
		pulseEN	:		in std_logic;
		Reset		:		in std_logic;
		Busy		:		out std_logic;
		SRAM_ADDR:		out std_logic_vector(OutAddrSize - 1 downto 0);
		SRAM_DQ	:		inout std_logic_vector(DataBufferSize - 1 downto 0);
		SRAM_CE_N:		out std_logic;
		SRAM_LB_N:		out std_logic;
		SRAM_UB_N:		out std_logic;
		SRAM_OE_N:		out std_logic;
		SRAM_WE_N:		out std_logic
	);
end SRAM_Controller;

architecture behavior of SRAM_Controller is
	-- State Machine Signals
	type SRAM_State is (Ready, Read1, Read2, Write1, Write2);
	signal state : SRAM_State;
	
	--	Internal Signals for Registering
	signal AddressInternal 	: std_logic_vector(OutAddrSize - 1 downto 0) := (others => '0');
	signal DataInInternal 	: std_logic_vector(DataSize - 1 downto 0) := (others => '0');
	signal DataInBuffer 		: std_logic_vector(DataSize - 1 downto 0) := (others => '0');
	signal DataOutInternal 	: std_logic_vector(DataSize - 1 downto 0) := (others => '0');
	
	-- Control Signals
	signal TristateEnable 	: std_logic := '0';
	signal DataOutEnable		: std_logic := '0';
begin

	process(clk)
	begin
		if rising_edge(clk) then
			
			-- Reset
			if Reset = '1' then
				-- Setting the State to Ready
				state <= Ready;
				
				-- Setting Outputs to Default
				SRAM_OE_N <= '1';
				SRAM_WE_N <= '1';
				Busy <= '1';
				TristateEnable <= '0';
				DataOutEnable <= '0';
				DataOut <= (others => '0');
				
			else
				-- Updating State Machine
				case state is
					when Ready =>
					
						-- Registering Necessary Signals
						AddressInternal(AddrSize-1 downto 0) <= Address;
						DataInInternal <= DataIn;
						
						-- Setting Outputs to Default
						SRAM_OE_N <= '1';
						SRAM_WE_N <= '1';
						Busy <= '0';
						TristateEnable <= '0';
						DataOutEnable <= '0';
						
						-- Setting the Next State Based on the Pulse and RW signals
						if PulseEN = '1' and RW = '1' then
							state <= Read1;
						elsif PulseEN = '1' and RW = '0' then
							state <= Write1;
						else
							state <= Ready;
						end if;
						
					when Read1 =>
					
						-- Setting Signals
						SRAM_OE_N <= '0';
						SRAM_WE_N <= '1';
						TristateEnable <= '1';
						DataOutEnable <= '1';
						Busy <= '1';
						
						-- Updating State
						state <= Read2;
						
					when Read2 =>
					
						-- Setting Signals
						SRAM_OE_N <= '1';
						SRAM_WE_N <= '1';
						TristateEnable <= '1';
						DataOutEnable <= '1';
						Busy <= '1';
						
						-- Updating State
						state <= Ready;
					
					when Write1 =>
					
						-- Setting Signals
						SRAM_OE_N <= '1';
						SRAM_WE_N <= '0';
						TristateEnable <= '0';
						DataOutEnable <= '0';
						Busy <= '1';
						
						-- Updating State
						state <= Write2;
					
					when Write2 =>
					
						-- Setting Signals
						SRAM_OE_N <= '1';
						SRAM_WE_N <= '1';
						TristateEnable <= '0';
						DataOutEnable <= '0';
						Busy <= '1';
						
						-- Updating State
						state <= Ready;
					
					when others => state <= Ready;
				end case;
			end if;
		
			-- Registering DataOut Signal and Integrating Enable
			if DataOutEnable = '1' then
				DataOut <= DataOutInternal;
			end if;
			
		end if;
	end process;
	
	-- Setting Outputs Permanently
	SRAM_UB_N <= '0';
	SRAM_LB_N <= '0';
	SRAM_CE_N <= '0';
	
	-- Creating the Tristate Buffer
	DataInBuffer <= DataInInternal when TristateEnable = '0' else
						 (others => 'Z');
	
			
	-- Mapping Internal Signals to Output Signals
	SRAM_ADDR <= AddressInternal;
	SRAM_DQ <= DataInBuffer;
	DataOutInternal <= SRAM_DQ;
		
end behavior;

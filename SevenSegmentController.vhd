-- Seven Segment Display Controller
-- Seven Segment Look Up Table
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSegmentController is
	generic(AddrSize : integer := 8; DataSize : integer := 16);
	port(
		clk					: in std_logic;
		reset					: in std_logic;
		
		-- Data Inputs
		DataIn				: in std_logic_vector(DataSize - 1 downto 0);
		AddrIn				: in std_logic_vector(AddrSize - 1 downto 0);
		
		-- Shift Input Enable
		EnableShiftInput 	: in std_logic;
		
		-- Data Outputs
		DataOut				: out std_logic_vector(DataSize - 1 downto 0);
		AddrOut				: out std_logic_vector(AddrSize - 1 downto 0);
		
		--Shift Controller
		DataShift			: in std_logic;
		AddrShift			: in std_logic;
		
		--Shift Inputs
		DataShiftIn			: in std_logic_vector(3 downto 0);
		AddrShiftIn			: in std_logic_vector(3 downto 0);
		
		--Seven Segment Outputs
		HEX0					: out std_logic_vector(6 downto 0);
		HEX1					: out std_logic_vector(6 downto 0);
		HEX2					: out std_logic_vector(6 downto 0);
		HEX3					: out std_logic_vector(6 downto 0);
		HEX4					: out std_logic_vector(6 downto 0);
		HEX5					: out std_logic_vector(6 downto 0)
	);
end SevenSegmentController;

architecture behavior of SevenSegmentController is
	
	component SevenSegmentLUT is
		port(
			DataIn	: in std_logic_vector(3 downto 0);
			HEX		: out std_logic_vector(6 downto 0)
		);
	end component;

	-- Internal Registers
	signal reg0, reg1, reg2, reg3, reg4, reg5 : std_logic_vector(3 downto 0);
	
begin
	
	process(clk)
	begin
		if rising_edge(clk) then
		
			if reset = '1' then -- Applying Reset Conditions
			
				reg0 <= (others => '0');
				reg1 <= (others => '0');
				reg2 <= (others => '0');
				reg3 <= (others => '0');
				reg4 <= (others => '0');
				reg5 <= (others => '0');
			
			else
			
				if EnableShiftInput = '0' then 		--If the Directional Input is Enabled, 
																--then the registers are populated with DataIn or Addr In
					reg0 <= DataIn(3 downto 0); 		
					reg1 <= DataIn(7 downto 4);
					reg2 <= DataIn(11 downto 8);
					reg3 <= DataIn(15 downto 12);
					
					reg4 <= AddrIn(3 downto 0);
					reg5 <= AddrIn(7 downto 4);
					
				else											--Else they are populated using the shift input
				
					if DataShift = '1' then
					
						-- Shifting In Data
						reg3 <= reg2;
						reg2 <= reg1;
						reg1 <= reg0;
						reg0 <= DataShiftIn;
					end if;
					
					if AddrShift = '1' then
					
						-- Shifting In Address
						reg5 <= reg4;
						reg4 <= AddrShiftIn;
					
					end if;
					
					-- Forcing Internal Data to the Output of the Module
					DataOut(3 downto 0)   <= reg0; 	
					DataOut(7 downto 4)   <= reg1; 
					DataOut(11 downto 8)  <= reg2;
					DataOut(15 downto 12) <= reg3;
					                          
					AddrOut(3 downto 0)   <= reg4;
					AddrOut(7 downto 4)   <= reg5;
					
				end if;
				
			end if;
		end if;
	end process;
	
	LUT_0_Inst: SevenSegmentLUT
		port map(
			DataIn => reg0,
			HEX => HEX0
		);
		
	LUT_1_Inst: SevenSegmentLUT
		port map(
			DataIn => reg1,
			HEX => HEX1
		);

	LUT_2_Inst: SevenSegmentLUT
		port map(
			DataIn => reg2,
			HEX => HEX2
		);

	LUT_3_Inst: SevenSegmentLUT
		port map(
			DataIn => reg3,
			HEX => HEX3
		);

	LUT_4_Inst: SevenSegmentLUT
		port map(
			DataIn => reg4,
			HEX => HEX4
		);
		
	LUT_5_Inst: SevenSegmentLUT
		port map(
			DataIn => reg5,
			HEX => HEX5
		);
		
	
end behavior;
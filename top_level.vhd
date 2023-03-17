--Top Level Entity
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	generic(InternalAddrSize: integer := 8; OutAddrSize: integer := 20; DataBufferSize: integer := 16; FinalClockCount: integer := 1000; ResetDelayLength : integer := 15);
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
		HEX5			: out std_logic_vector(6 downto 0);
		
		-- Keypad Controller I/O
		RowsInput	: in std_logic_vector(4 downto 0);
		ColsOutput	: out std_logic_vector(3 downto 0);
		
		-- Mode Indicator
		ModeIndicator : out std_logic
	);
end top_level;

architecture behavior of top_level is
	
	-- ROM_Controller Component Inclusion
	component ROM_Controller is
		generic(AddrSize: integer := 8; DataSize: integer := 16);
		port(
			clk, clk_en		: in std_logic;
			Address			: in std_logic_vector(AddrSize - 1 downto 0);
			delayedPulse	: out std_logic;
			DataOut			: out std_logic_vector(DataSize - 1 downto 0)
		);
	end component;
	
	-- SRAM_Controller Component Inclusion
	component SRAM_Controller is
		generic(AddrSize: integer := 8; DataSize: integer := 16; 
				  OutAddrSize: integer := 20; DataBufferSize: integer := 16);
		port(	
			clk		:		in std_logic;
			Address	:		in std_logic_vector(AddrSize - 1 downto 0);
			DataIn 	:		in std_logic_vector(DataSize - 1 downto 0);
			DataOut	:		out std_logic_vector(DataSize - 1 downto 0);
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
	end component;
	
	-- Counter Component Inclusion
	component univ_bin_counter is
		generic(N: integer := 8; N2: integer := 9; N1: integer := 0);
		port(
				clk, reset				: in std_logic;
				syn_clr, load, en, up: in std_logic;
				clk_en 					: in std_logic := '1';			
				d							: in std_logic_vector(N-1 downto 0);
				max_tick, min_tick	: out std_logic;
				q							: out std_logic_vector(N-1 downto 0)		
		);
	end component;
	
	-- Clock Enabler Inclusion
	component clk_enabler is
		GENERIC (CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz 
		port(	
			clock:		  in std_logic;	 
			reset:        in std_logic;
			clk_en: 	     out std_logic
		);
	end component;
	
	-- Advanced Clock Enabler Inclusion
	component clk_enabler_adv is
	GENERIC (CONSTANT cnt_max : integer := 49999999;  pulse_time : integer := 49999999);      --  1.0 Hz 
	port(	
		clock:		  in std_logic;	 
		reset:        in std_logic;
		clk_en: 	     out std_logic;
		enable:		  in std_logic
	);
	end component;
	
	-- Reset Delay Inclusion
	component Reset_Delay IS	
		generic(MAX: integer := 15);
		PORT (
			iCLK : IN std_logic;	
			oRESET : OUT std_logic
			);	
	END component;
	
	-- Falling Edge Detector Inclusion
	component FED is
		port(
			clk								:in std_logic;
			signal_input					:in std_logic;
			edge_detected					:out std_logic
		);
	end component;
	
	-- Seven Controller Inclusion
	component SevenSegmentController is
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
	end component;
	
	-- Keypad Controller Inclusions
	component KeypadController is
		generic(clk_cnt: integer := 250000);
		port(
			clk								:in  std_logic;
			reset								:in  std_logic;
			RowsIn							:in  std_logic_vector(4 downto 0);
			ColsOut							:out std_logic_vector(3 downto 0);
			
			-- Output Data
			KeyData							:out std_logic_vector(4 downto 0);
			DataEnable						:out std_logic
		);
	end component;

	
	-- State Declarations
	type TOPLEVEL_State is (Init, Counting_Up, Counting_Up_Halt, Counting_Down, Counting_Down_Halt, Prog_Addr_U, Prog_Data_U, Prog_Addr_D, Prog_Data_D);
	signal state : TOPLEVEL_State;
	
	-- Signal Declarations (ROM Controller)
	signal ROM_DataOut					: std_logic_vector(DataBufferSize - 1 downto 0); -- Intermediate DataOut Signal
	signal ROM_delayedPulse				: std_logic; 												 -- Intermediate DelayedPulseSignal
	
	-- Signal Declarations (SRAM Controller)
	signal SRAM_DataOut					: std_logic_vector(DataBufferSize - 1 downto 0); -- Intermediate DataOut Signal
	signal SRAM_pulseInput				: std_logic;												 -- Pulse Enable Intermediate
	signal SRAM_AddressInput			: std_logic_vector(InternalAddrSize-1 downto 0); -- SRAM Address
	signal SRAM_DataIn					: std_logic_vector(DataBufferSize - 1 downto 0); -- Intermediate DataIn Signal
	signal SRAM_RW							: std_logic;												 -- Intermediate RW Signal
	signal SRAM_Busy						: std_logic;												 -- Intermediate Busy Signal
	
	-- Signal Declarations (Counter)
	signal Counter_Dir_Control			: std_logic;												 -- Controls the Direction of the Counter
	signal Counter_En_Control			: std_logic;												 -- Controls Whether the Counter is Enabled
	signal Counter_Clock_Enable		: std_logic;												 -- Intermediate Clock Enable Signal for the Counter, Can be connected to 1Hz or 16MHz based on the state
	signal Counter_Max_Tick				: std_logic;												 -- Connected to the Max Tick of the Counter, used to determine if the ROM has been iterated through one full time
	signal Counter_Output				: std_logic_vector(InternalAddrSize-1 downto 0); -- Output of the Counter
	signal Counter_Reset					: std_logic;
	
	-- Signal Declarations (Clock Enabler)
	signal clock_enable_control		: std_logic; -- Controls whether the 1Hz clock enable or the 16MHz clock enable is utilized
	signal clock_enable_16				: std_logic; -- 16MHz Clock Enable
	signal clock_enable_1_adv			: std_logic; -- 1Hz Clock Advanced Enable
	signal clock_enable_1				: std_logic; -- 1Hz Clock Enable (Simple)
	signal clock_enable_1_en			: std_logic; -- Controls whether the 1Hz Clock Enable is enabled or disabled
	
	-- Signal Declarations (Reset Delay)
	signal reset_delay_output			: std_logic; -- Output of Reset Delay
	
	-- Signal Declarations (Falling Edge Detector)
	signal max_tick_falling_edge_detected		: std_logic; -- Output of Falling Edge Detector
	
	-- Signal Declarations (Seven Segment Controller)
	signal SSC_EnableShift				: std_logic;
	signal SSC_DataShift					: std_logic;
	signal SSC_AddrShift					: std_logic;
	signal SSC_DataToShift				: std_logic_vector(3 downto 0);
	signal SSC_AddrToShift				: std_logic_vector(3 downto 0);
	signal SSC_DataIn						: std_logic_vector(DataBufferSize - 1 downto 0);
	signal SSC_AddrIn						: std_logic_vector(InternalAddrSize - 1 downto 0);
	signal SSC_DataOut					: std_logic_vector(DataBufferSize - 1 downto 0);
	signal SSC_AddrOut					: std_logic_vector(InternalAddrSize - 1 downto 0);
	
	-- Signal Declarations (Keypad Controller)
	signal KC_Data							: std_logic_vector(4 downto 0);
	signal KC_DataValid					: std_logic;
	
	-- Signal Declarations (General)
	signal InternalReset 				: std_logic; -- Internal Reset
	signal ResetToZeroFallingEdge		: std_logic; -- Falling edge of the ResetToZeroSignal
	signal ResetToZero					: std_logic; -- Resets the device to the address 0x00, 
																 -- without resetting the contents of the SRAM
	
	-- Preventing Optimizations for Testing
	attribute keep: boolean;
	attribute keep of KC_Data: signal is true;
	attribute keep of KC_DataValid: signal is true;
	
	
begin

	-- State Machine
	process(clk)
	begin
		if rising_edge(clk) then
			if InternalReset = '1' then
			
				state <= Init; -- Returning to the Intial State Upon Reset
				
			else
				-- Updating States
				case state is
					when Init =>
					
						-- Configuring SRAM Controller
						SRAM_AddressInput <= Counter_Output;				-- Taking the Address from the Counter
						SRAM_DataIn <= ROM_DataOut;							-- Taking the Data from the ROM
						SRAM_PulseInput <= ROM_DelayedPulse;				-- Taking the Delayed Pulse from the ROM Controller
						SRAM_RW <= '0'; 											-- Writing to SRAM
						
						-- Configuring the Counter
						Counter_Clock_Enable <= clock_enable_16;			-- Using the Counter with a 16MHz Clock
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						-- Ensuring the Counter Does not Overshoot by Stopping The Counter After it Overflows
						if Counter_Output = X"00" and max_tick_falling_edge_detected = '1' then
							Counter_En_Control <= '0';							-- Enabling the Counter
						else
							Counter_En_Control <= '1';							-- Enabling the Counter
						end if;
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '1';								-- Enabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '0';
						SSC_DataShift	 <= '0';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= "0000";
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SSC_DataIn <= SRAM_DataOut;
						SSC_AddrIn <= Counter_Output;
						
						-- Indicating Operation Mode
						ModeIndicator <= '1';
						
						-- Negting Reset to Zero
						ResetToZero <= '0';
						
						-- Updating the State After Max Tick is Reached
						if max_tick_falling_edge_detected = '1' then
							state <= Counting_Up_Halt;
						else 
							state <= Init;
						end if;
						
					when Counting_Up =>
					
						-- Configuring SRAM_Controller
						SRAM_AddressInput <= Counter_Output;				-- Taking the Address from the Counter
						SRAM_PulseInput <= clock_enable_1_adv;					-- 1Hz Advance Clock Enable
						SRAM_RW <= '1';											-- Setting the SRAM Controller to Read
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '1';								-- Enabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '1';								-- Enabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '0';
						SSC_DataShift	 <= '0';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= "0000";
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SSC_DataIn <= SRAM_DataOut;
						SSC_AddrIn <= Counter_Output;
						
						-- Indicating Operation Mode
						ModeIndicator <= '1';
						
						-- Preventing Reset to Zero
						ResetToZero <= '0';
						
						-- Determining if a Command Was Issued
						if (KC_DataValid = '1') and (KC_Data(4) = '1') then
							case KC_Data(3 downto 0) is
								when "0000" => -- H Pressed
								
									-- Entering Halt Mode (Stop Counting)
									state <= Counting_Up_Halt;
							
								when "0001" => -- L Pressed
								
									-- Toggling Direction (Remaining In Count Mode)
									state <= Counting_Down;
								
								when "0010" => -- Shift Pressed
								
									-- Entering Programming Mode
									state <= Prog_Data_U;
									
								when others => state <= Counting_Up;
							end case;
						else
							-- Updating the State
							state <= Counting_Up;						
						end if;
						
					when Counting_Up_Halt =>
						
						-- Configuring SRAM_Controller
						SRAM_AddressInput <= Counter_Output;				-- Taking the Address from the Counter
						SRAM_PulseInput <= ResetToZeroFallingEdge;		-- Disabling the SRAM Controller's Ability to Read (Eexcept after Counter Reset)
						SRAM_RW <= '1';											-- Setting the SRAM Controller to Read
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '0';
						SSC_DataShift	 <= '0';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= "0000";
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SSC_DataIn <= SRAM_DataOut;
						SSC_AddrIn <= Counter_Output;
						
						-- Indicating Operation Mode
						ModeIndicator <= '1';
						
						-- Preventing Reset to Zero
						ResetToZero <= '0';
						
						-- Determining if a Command Was Issued
						if (KC_DataValid = '1') and (KC_Data(4) = '1') then
							case KC_Data(3 downto 0) is
								when "0000" => -- H Pressed
								
									-- Exiting Halt Mode (Resuming Counting)
									state <= Counting_Up;
							
								when "0001" => -- L Pressed
								
									-- Toggling Direction (Remaining In Halt)
									state <= Counting_Down_Halt;
								
								when "0010" => -- Shift Pressed
								
									-- Entering Programming Mode
									state <= Prog_Data_U;
									
								when others => state <= Counting_Up_Halt;
							end case;
						else
							-- Updating the State
							state <= Counting_Up_Halt;						
						end if;
						
					when Counting_Down =>
						
						-- Configuring SRAM_Controller
						SRAM_AddressInput <= Counter_Output;				-- Taking the Address from the Counter
						SRAM_PulseInput <= clock_enable_1_adv;					-- 1Hz Advance Clock Enable
						SRAM_RW <= '1';											-- Setting the SRAM Controller to Read
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '1';								-- Enabling the Counter
						Counter_Dir_Control <= '0';							-- Setting the Counter to Count Down
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '1';								-- Enabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '0';
						SSC_DataShift	 <= '0';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= "0000";
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SSC_DataIn <= SRAM_DataOut;
						SSC_AddrIn <= Counter_Output;
						
						-- Indicating Operation Mode
						ModeIndicator <= '1';
						
						-- Preventing Reset to Zero
						ResetToZero <= '0';
						
						-- Determining if a Command Was Issued
						if (KC_DataValid = '1') and (KC_Data(4) = '1') then
							case KC_Data(3 downto 0) is
								when "0000" => -- H Pressed
								
									-- Entering Halt Mode
									state <= Counting_Down_Halt;
							
								when "0001" => -- L Pressed
								
									-- Toggling Direction (Remaining In Counting Mode)
									state <= Counting_Up;
								
								when "0010" => -- Shift Pressed
								
									-- Entering Programming Mode
									state <= Prog_Data_D;
									
								when others => state <= Counting_Down;
							end case;
						else
							-- Updating the State
							state <= Counting_Down;						
						end if;
						
					when Counting_Down_Halt =>
						
						-- Configuring SRAM_Controller
						SRAM_AddressInput <= Counter_Output;				-- Taking the Address from the Counter
						SRAM_PulseInput <= ResetToZeroFallingEdge;		-- Disabling the SRAM Controller's Ability to Read (Eexcept after Counter Reset)
						SRAM_RW <= '1';											-- Setting the SRAM Controller to Read
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '0';							-- Setting the Counter to Count Down
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '0';
						SSC_DataShift	 <= '0';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= "0000";
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SSC_DataIn <= SRAM_DataOut;
						SSC_AddrIn <= Counter_Output;
						
						-- Indicating Operation Mode
						ModeIndicator <= '1';
						
						-- Preventing Reset to Zero
						ResetToZero <= '0';
						
						-- Determining if a Command Was Issued
						if (KC_DataValid = '1') and (KC_Data(4) = '1') then
							case KC_Data(3 downto 0) is
								when "0000" => -- H Pressed
								
									-- Exiting Halt Mode
									state <= Counting_Down;
							
								when "0001" => -- L Pressed
								
									-- Toggling Direction (Remaining In Counting Mode)
									state <= Counting_Up_Halt;
								
								when "0010" => -- Shift Pressed
								
									-- Entering Programming Mode
									state <= Prog_Data_D;
									
								when others => state <= Counting_Down_Halt;
							end case;
						else
							-- Updating the State
							state <= Counting_Down_Halt;						
						end if;
						
					when Prog_Addr_U =>
						
						-- Checking for Keypad Input
						if KC_DataValid = '1' then
							
							-- Checking if the key press is a command or data
							if KC_Data(4) = '1' then -- Command
							
								-- Determining Which Command Was Issued (State Transition)
								case KC_Data(3 downto 0) is
									when "0000" => -- H Pressed
									
										-- Switching to Data Programming
										state <= Prog_Data_U;
								
									when "0001" => -- L Pressed
									
										-- Remaining in the same state
										state <= Prog_Addr_U;
										
										-- Setting Pulse Input Accordingly (Programming SRAM)
										SRAM_PulseInput <= '1';
									
									when "0010" => -- Shift Pressed
									
										state <= Counting_Up_Halt;
										
									when others => state <= Prog_Addr_U;
								end case;
								
							else -- Data
								
								-- Shifting Register
								SSC_AddrShift	 <= '1';
								
								-- Remaining in the same state
								state <= Prog_Addr_U;
								
							end if;
							
						else
							
							-- Setting SRAM Pulse Input
							SRAM_PulseInput <= '0';
							
							-- Disabling Addr Shift
							SSC_AddrShift	 <= '0';
							
							-- Remaining in the same state
							state <= Prog_Addr_U;
							
						end if;
						
						-- Configuring SRAM_Controller
						SRAM_RW <= '0';											-- Setting the SRAM Controller to Write
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SRAM_DataIn <= SSC_DataOut;
						SRAM_AddressInput <= SSC_AddrOut;
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '1';
						SSC_DataShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= KC_Data(3 downto 0);
						
						-- Indicating Programming Mode
						ModeIndicator <= '0';	
												
						-- Asserting Reset to Zero
						ResetToZero <= '1';
						
					when Prog_Addr_D =>
						
						-- Checking for Keypad Input
						if KC_DataValid = '1' then
							
							-- Checking if the key press is a command or data
							if KC_Data(4) = '1' then -- Command
							
								-- Determining Which Command Was Issued (State Transition)
								case KC_Data(3 downto 0) is
									when "0000" => -- H Pressed
									
										-- Switching to Data Programming
										state <= Prog_Data_D;
								
									when "0001" => -- L Pressed
									
										-- Remaining in the same state
										state <= Prog_Addr_D;
										
										-- Setting Pulse Input Accordingly (Programming SRAM)
										SRAM_PulseInput <= '1';
									
									when "0010" => -- Shift Pressed
									
										state <= Counting_Down_Halt;
										
									when others => state <= Prog_Addr_D;
								end case;
								
							else -- Data
								
								-- Shifting Register
								SSC_AddrShift	 <= '1';
								
								-- Remaining in the same state
								state <= Prog_Addr_D;
								
							end if;
							
						else
							
							-- Setting SRAM Pulse Input
							SRAM_PulseInput <= '0';
							
							-- Disabling Addr Shift
							SSC_AddrShift	 <= '0';
							
							-- Remaining in the same state
							state <= Prog_Addr_D;
							
						end if;
						
						-- Configuring SRAM_Controller
						SRAM_RW <= '0';											-- Setting the SRAM Controller to Write
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SRAM_DataIn <= SSC_DataOut;
						SRAM_AddressInput <= SSC_AddrOut;
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '1';
						SSC_DataShift	 <= '0';
						SSC_DataToShift <= "0000";
						SSC_AddrToShift <= KC_Data(3 downto 0);
						
						-- Indicating Programming Mode
						ModeIndicator <= '0';
						
						-- Asserting Reset to Zero
						ResetToZero <= '1';	
						
					when Prog_Data_U =>
					
						-- Checking for Keypad Input
						if KC_DataValid = '1' then
							
							-- Checking if the key press is a command or data
							if KC_Data(4) = '1' then -- Command
							
								-- Determining Which Command Was Issued (State Transition)
								case KC_Data(3 downto 0) is
									when "0000" => -- H Pressed
										
										-- Switching to Address Programming
										state <= Prog_Addr_U;
								
									when "0001" => -- L Pressed
									
										-- Remaining in the same state
										state <= Prog_Data_U;
										
										-- Setting Pulse Input Accordingly (Programming SRAM)
										SRAM_PulseInput <= '1';
									
									when "0010" => -- Shift Pressed
									
										state <= Counting_Up_Halt;
										
									when others => state <= Prog_Data_U;
								end case;
								
							else -- Data
								
								-- Shifting Register
								SSC_DataShift	 <= '1';
								
								-- Remaining in the same state
								state <= Prog_Data_U;
								
							end if;
							
						else
							
							-- Setting SRAM Pulse Input
							SRAM_PulseInput <= '0';
							
							-- Disabling Addr Shift
							SSC_DataShift	 <= '0';
							
							-- Remaining in the same state
							state <= Prog_Data_U;
							
						end if;
						
						-- Configuring SRAM_Controller
						SRAM_RW <= '0';											-- Setting the SRAM Controller to Write
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SRAM_DataIn <= SSC_DataOut;
						SRAM_AddressInput <= SSC_AddrOut;
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '1';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= KC_Data(3 downto 0);
						SSC_AddrToShift <= "0000";
						
						-- Indicating Programming Mode
						ModeIndicator <= '0';
						
						-- Asserting Reset to Zero
						ResetToZero <= '1';
					
					when Prog_Data_D =>
						
						-- Checking for Keypad Input
						if KC_DataValid = '1' then
							
							-- Checking if the key press is a command or data
							if KC_Data(4) = '1' then -- Command
							
								-- Determining Which Command Was Issued (State Transition)
								case KC_Data(3 downto 0) is
									when "0000" => -- H Pressed
									
										-- Switching to Address Programming
										state <= Prog_Addr_D;
								
									when "0001" => -- L Pressed
									
										-- Remaining in the same state
										state <= Prog_Data_D;
										
										-- Setting Pulse Input Accordingly (Programming SRAM)
										SRAM_PulseInput <= '1';
									
									when "0010" => -- Shift Pressed
									
										state <= Counting_Down_Halt;
										
									when others => state <= Prog_Data_D;
								end case;
								
							else -- Data
								
								-- Shifting Register
								SSC_DataShift	 <= '1';
								
								-- Remaining in the same state
								state <= Prog_Data_D;
								
							end if;
							
						else
							
							-- Setting SRAM Pulse Input
							SRAM_PulseInput <= '0';
							
							-- Disabling Addr Shift
							SSC_DataShift	 <= '0';
							
							-- Remaining in the same state
							state <= Prog_Data_D;
							
						end if;
						
						-- Configuring SRAM_Controller
						SRAM_RW <= '0';											-- Setting the SRAM Controller to Write
						
						-- Connecting the Necessary Outputs to the Seven Segment Controller
						SRAM_DataIn <= SSC_DataOut;
						SRAM_AddressInput <= SSC_AddrOut;
						
						-- Configuring Counter to use alternative clock enable source
						Counter_Clock_Enable <= clock_enable_1;			-- Using the Counter with a 1 Hz Clock
						Counter_En_Control <= '0';								-- Disabling the Counter
						Counter_Dir_Control <= '1';							-- Setting the Counter to Count Up
						
						-- Controlling the 1Hz Clock Enable
						clock_enable_1_en <= '0';								-- Disabling the 1Hz Clock Enable
						
						-- Configuring the Seven Segment Controller
						SSC_EnableShift <= '1';
						SSC_AddrShift	 <= '0';
						SSC_DataToShift <= KC_Data(3 downto 0);
						SSC_AddrToShift <= "0000";
						
						-- Indicating Programming Mode
						ModeIndicator <= '0';
						
						-- Asserting Reset to Zero
						ResetToZero <= '1';
						
					when others => state <= Init;
				end case;
			end if;
		end if;
	end process;

	-- ROM Instance
	ROM_Inst: ROM_Controller
		port map(
			clk => clk,
			clk_en => clock_enable_16,
			Address => Counter_Output,
			delayedPulse => ROM_delayedPulse,
			DataOut => ROM_DataOut
		);
	
	-- SRAM Instance
	SRAM_Inst: SRAM_Controller
		port map(
			clk => clk,
			Address => SRAM_AddressInput,
			DataIn => SRAM_DataIn,
			DataOut => SRAM_DataOut,
			RW => SRAM_RW,
			pulseEN => SRAM_pulseInput,
			Reset => InternalReset,
			Busy => SRAM_Busy,
			SRAM_ADDR => SRAM_ADDR,
			SRAM_DQ	 => SRAM_DQ,
			SRAM_CE_N => SRAM_CE_N,
			SRAM_LB_N => SRAM_LB_N,
			SRAM_UB_N => SRAM_UB_N,
			SRAM_OE_N => SRAM_OE_N,
			SRAM_WE_N => SRAM_WE_N
		);
		
	-- Creating the Reset for the Counters
	Counter_Reset <= InternalReset or ResetToZero;
	
	-- Counter Instance
	Counter_Inst: univ_bin_counter
		generic map(N => 8, N2 => 255, N1 => 0)
		port map(
			clk => clk,
			reset => Counter_Reset,
			syn_clr => '0',
			load => '0',
			en => Counter_En_Control,
			up => Counter_Dir_Control,
			clk_en => Counter_Clock_Enable,
			d => (others => '0'),
			max_tick => Counter_Max_Tick,
			min_tick => open,
			q => Counter_Output
		);
	
	-- Clock Enable 16 MHz Instance
	CLK_EN_INST_16: clk_enabler  -- ~16MHz Clock Enable
		generic map(cnt_max => 2)
		port map(
			clock => clk,
			reset => InternalReset,
			clk_en => clock_enable_16
		);
		
	-- Clock Enable 1 Hz Instance (Simple)
	CLK_EN_INST_1: clk_enabler_adv  -- 1Hz Clock Enable
		generic map(cnt_max => FinalClockCount, pulse_time => (FinalClockCount - 1))
		port map(
			clock => clk,
			reset => Counter_Reset,
			clk_en => clock_enable_1,
			enable => clock_enable_1_en
	);
	
	-- Clock Enable Advanced 1 Hz Instance
	CLK_EN_INST_1_ADV: clk_enabler_adv  -- 1Hz Clock Enable
		generic map(cnt_max => FinalClockCount, pulse_time => 810) -- Should be 49999999 for Actual Implementation, Use 1000 for testing
		port map(
			clock => clk,
			reset => Counter_Reset,
			clk_en => clock_enable_1_adv,
			enable => clock_enable_1_en
		);
	
	InternalReset <= reset_delay_output or reset;
	-- Reset Delay Inclusion
	RESET_DELAY_Inst: Reset_Delay
		generic map(MAX => ResetDelayLength)
		port map(
			iCLK => clk,
			oRESET => reset_delay_output
		);
	
	-- Falling Edge Detector Instance (Counter)
	FED_Inst_Counter: FED
		port map(
			clk => clk,
			signal_input => Counter_Max_Tick,
			edge_detected => max_tick_falling_edge_detected
		);
		
	-- Falling Edge Detector Instance (ResetToZero)
	FED_Inst_ResetToZero: FED
		port map(
			clk => clk,
			signal_input => ResetToZero,
			edge_detected => ResetToZeroFallingEdge
		);
	
	-- Seven Segment Controller Instance
	SevenSegmentController_Inst : SevenSegmentController
		port map(
			clk => clk,			
			reset => InternalReset,
			DataIn => SSC_DataIn,
			AddrIn => SSC_AddrIn,
			DataOut => SSC_DataOut,
			AddrOut => SSC_AddrOut,		
			EnableShiftInput 	=> SSC_EnableShift,
			DataShift => SSC_DataShift,
			AddrShift => SSC_AddrShift,
			DataShiftIn	=> SSC_DataToShift,
			AddrShiftIn	=> SSC_AddrToShift,
			HEX0 => HEX0,	
			HEX1 => HEX1,				
			HEX2 => HEX2,					
			HEX3 => HEX3,					
			HEX4 => HEX4,					
			HEX5 => HEX5				
		);
		
	-- Keypad Controller Instance
	KeypadController_Inst : KeypadController
		port map(
			clk => clk,
			reset => InternalReset,
			RowsIn => RowsInput,
			ColsOut => ColsOutput,
			KeyData => KC_Data,
			DataEnable => KC_DataValid
		);
		
end behavior;
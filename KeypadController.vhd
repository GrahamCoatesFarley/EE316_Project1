-- Keypad Controller
-- Falling Edge Detector
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KeypadController is
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
end KeypadController;

architecture behavior of KeypadController is

	-- Clock Enable Declaration
	component clk_enabler is
		GENERIC (CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz 
		port(	
			clock:		  in std_logic;	 
			reset:        in std_logic;
			clk_en: 	     out std_logic
		);
	end component;
	
	-- Rising Edge Detector Inclusion
	component RED is
		port(
			clk								:in std_logic;
			signal_input					:in std_logic;
			edge_detected					:out std_logic
		);
	end component;

	-- State Declaration
	type KeypadControllerStates is (Init, Col1, Col2, Col3, Col4);
	signal state : KeypadControllerStates;
	
	-- Internal Signal Declarations
	signal keyPressed					: std_logic; -- Determines if a key is pressed
	signal sig1, sig2					: std_logic; -- Used in rising edge detector to generate a 20ns pulse
	signal clk_en						: std_logic; -- Used as an internal clock enable signal
	signal DataValid					: std_logic; -- Internal 5ms Data Valid Signal
	
begin
	process(clk)
	begin
		if rising_edge(clk) then
			
			if reset = '1' then
			
				-- Setting Initial Configuration
				state <= Init;
				sig1 <= '0';
				sig2 <= '0';
				
				-- Resetting KeyData
				KeyData <= (others => '0');
			
			else
				
				-- Checking for Clock Enable
				if clk_en = '1' then
					if KeyPressed = '0' then
					
						-- Updating State Information
						case state is
							when Init => state <= Col1;
							when Col1 => state <= Col2;
							when Col2 => state <= Col3;
							when Col3 => state <= Col4;
							when Col4 => state <= Col1;
						end case;
						
						-- Setting Data Valid to '0'
						DataValid <= '0';
						
					else 
						
						-- Setting DataValid to '1'
						DataValid <= '1';
					
						-- Maintaining the Same State
						state <= state;
						
						-- Determining Which Key was Pressed
						case state is
							when Col1 =>
							
								-- Determining Which Key Was Pressed
								if RowsIn(0) = '0' then
									KeyData <= '0' & X"D";
								elsif RowsIn(1) = '0' then
									KeyData <= '0' & X"E";
								elsif RowsIn(2) = '0' then
									KeyData <= '0' & X"F";
								elsif RowsIn(3) = '0' then
									KeyData <= '1' & X"2";  -- Shift
								elsif RowsIn(4) = '0' then
									KeyData <= '1' & X"1";  -- H
								end if;
								
							when Col2 =>

								-- Determining Which Key Was Pressed
								if RowsIn(0) = '0' then
									KeyData <= '0' & X"C";
								elsif RowsIn(1) = '0' then
									KeyData <= '0' & X"3";
								elsif RowsIn(2) = '0' then
									KeyData <= '0' & X"6";
								elsif RowsIn(3) = '0' then
									KeyData <= '0' & X"9";
								elsif RowsIn(4) = '0' then
									KeyData <= '1' & X"0"; -- L
								end if;
								
							when Col3 =>
							
								-- Determining Which Key Was Pressed
								if RowsIn(0) = '0' then
									KeyData <= '0' & X"B";
								elsif RowsIn(1) = '0' then
									KeyData <= '0' & X"2";
								elsif RowsIn(2) = '0' then
									KeyData <= '0' & X"5";
								elsif RowsIn(3) = '0' then
									KeyData <= '0' & X"8";
								elsif RowsIn(4) = '0' then
									KeyData <= '0' & X"0";
								end if;
								
							when Col4 =>
							
								-- Determining Which Key Was Pressed
								if RowsIn(0) = '0' then
									KeyData <= '0' & X"A";
								elsif RowsIn(1) = '0' then
									KeyData <= '0' & X"1";
								elsif RowsIn(2) = '0' then
									KeyData <= '0' & X"4";
								elsif RowsIn(3) = '0' then
									KeyData <= '0' & X"7";
								end if;
								
							when others => state <= Init;
						end case;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- Sets the Columns Based on the State
	ColsOut <= "1111" when state = Init else
				  "1110" when state = Col1 else
				  "1101" when state = Col2 else
				  "1011" when state = Col3 else
				  "0111" when state = Col4;
	
	-- Detects if a Key is Pressed
	KeyPressed <= (not (RowsIn(0) and RowsIn(1) and RowsIn(2) and RowsIn(3) and RowsIn(4)));
	
	Rising_Edge_Inst: RED
		port map(
			clk => clk,
			signal_input => DataValid,
			edge_detected => DataEnable
		);
	
	CLK_EN_5MS : clk_enabler
		generic map(cnt_max => clk_cnt)
		port map(
			clock => clk,
			reset => reset,
			clk_en => clk_en
		);

end behavior;
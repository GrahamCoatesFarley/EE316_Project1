library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- use IEEE.STD_LOGIC_ARITH;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Reset_Delay IS	
    generic(MAX: integer := 15);
    PORT (
        iCLK : IN std_logic;	
        oRESET : OUT std_logic
			);	
END Reset_Delay;


ARCHITECTURE Arch OF Reset_Delay IS
	
    SIGNAL Cont : unsigned(19 DOWNTO 0):=X"00000";

BEGIN

 PROCESS
 BEGIN

	  WAIT UNTIL rising_edge (iCLK);
	  IF Cont /= to_unsigned(MAX, Cont'length) THEN
		  Cont <= Cont + 1;	
		  oRESET <= '1';	
	  ELSE
		  oRESET <= '0';	
	  END IF;
 END PROCESS;
	
END Arch;
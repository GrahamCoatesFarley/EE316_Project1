EE 316 Computer Engineering Junior Lab (Spring 2023)
Design Project 1

Specification:  SRAM based Programmable Counter

Lab 1
Demonstration Due Date:        January 31, 2023 

Written Report
Due Date:               February 2, 2023         

Parts
List:       
 Altera DE2-115  Board
 A breadboard  and five 5K resistors
 A 19-Key Keypad


Design a SRAM based "programmable 8-bit counter of arbitrary
sequence" that runs on a one Hz clock. Note that the DE2-115 board has a 2
Mbyte (1M x 16) of fast asynchronous SRAM. 

The SRAM address is 18-bit long (needed for 256K memory locations of
16-bit wide). Theoretically, the arbitrary counter sequence (of 16-bit) can be 256K
long. However, since we do not have time to manually "program" the
counter, we will restrict to a length to 256. In other words, the project will
use memory addresses from 0x00000 to 0x0000F. 
Additionally, we can choose  not UB =0 or 1 and not LB =1 or 0 to write/read to upper or lower bytes, respectively. For simplicity we will refer to the address
as from 0x00 to 0xFF with the understanding that the rest of the higher order
address bits are always 0s. 

Note: we will refer to the six 7-segment displays on the DE2 board by the
names: HEX5 to HEX0. (See documentations on the DE2 system CDROM in the box or
in Moodle).

Other specifications are the following:
     
System will use a power-on reset to initialize
the content of the SRAM by loading a default data sequence from a 1-Port ROM. 
The 256 x 16 bit ROM will be built using Quartus II’s Megawizard plug-in Manager and a memory initialization file “sine.mif”
(posted on Moodle). The counter should also use a reset button (KEY0) to reload the default sequence into the SRAM.

 The counter can be programmed manually using a keypad attached to
     the DE2 board via the 40 pin ribbon cable and a bread board.  

 When the design in downloaded in the Cyclone IV FPGA, the counter
     will be in the operation mode and the 7-seg displays (HEX3-HEX0)
     will show the contents of the SRAM at address 0x00. The address will be
     displayed on HEX5 & HEX4.




 The "shift-key" on the keypad is used to toggle
     between (a) the programming mode and (b) the operation mode.
     In mode (a), the LED named LEDG0, on the DE2 board, will be “off”. In mode
     (b), LEDG0 will be “on” indicating the counter is in the “operation” mode.
     

 If the
     counter is not programmed and in the operation mode, the counter cycles
     through the addresses of the SRAM in the forward direction and displays
     the default contents of the SRAM at one second interval.

 When the counter is in the
     programming mode, the “H” key is used to toggle between two
     modes: (1) SRAM address setup mode and (2) SRAM data mode.




 In the SRAM address setup mode, when any of the numbers between 0-9
     and A-F is pressed on the keypad, HEX4 will display its HEX value. If the
     second such key is pressed, the digit occupying HEX4 location will move to
     HEX5 location and the new value will be shown at HEX4. The 8-bit
     number represents an SRAM address.

 In the data mode, when any of the numbers between 0-9 and A-F is
     pressed on the keypad the right most 7-segment display HEX0 will display
     its HEX value. If the second such key is pressed, the digit occupying HEX0
     location will move to HEX1 location and the new value will be shown at HEX0.
     If the third and the forth key press with shift the display to the
     left until HEX3 through HEX0 will show a 16-bit
     binary number. This number will be used as a data that will be loaded into
     the SRAM.




 In the programming mode, when the "L" key is pressed (once), the 4 digit HEX data
     displayed on HEX3 down to HEX0 will be loaded in to the SRAM memory
     address location displayed on HEX5 – HEX4. 


 When the SRAM data modification is done, a shift-key press will toggle
     to the operation mode. The 7-seg displays (HEX3- HEX0) will show the 16-bit content of the
     SRAM memory at address location 0X00 of which will be displayed on HEX5 - HEX4.
     

 The counter will begin counting only when the "H" key is
     pressed.  During this time, HEX5 – HEX4
     will cycle through the address locations from 0X00 to 0XFF and the
     contents of the SRAM will be shown on HEX3- HEX0. Pressing the H key in the operation mode will enable and disable
     the counter. 

 In the “operation” mode, the key “L” can
     be used to toggle the direction of the counter, between the forward and
     the backward directions.



Report:
You should investigate if the parts used in this project are RoHS compliant.

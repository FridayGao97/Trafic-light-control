----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/08/2019 02:31:02 PM
-- Design Name:
-- Module Name: traffic_intersection_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity traffic_intersection_tb is
--  Port ( );
end traffic_intersection_tb;

architecture Behavioral of traffic_intersection_tb is
    component traffic_intersection is
    Port (
            clk:    in STD_LOGIC;
            btn :   in STD_LOGIC_VECTOR(3 DOWNTO 0);    -- btn(0) press to see traffic light status for North/South or East/West lights.
                                                        -- btn(3) press to emulate vehicle passing from North/South direction, btn(2) for East/West.
            --Write design line here to get inputs from switches, refer to constraints file.  
                                                        -- SW(0)='1'=>Vehicle present on East/West direction of travel, SW(1)=>'1' for North/South
                                                        -- SW(3)='1'=> Lgiht Sensor Emulation '0'=>Day '1'=>Night            
            sw:     in STD_LOGIC_VECTOR(3 DOWNTO 0);
           
            led6_r : out STD_LOGIC;     --Traffic light status as Red
            led6_g : out STD_LOGIC;     --Traffic light status as Green
            led6_b : out STD_LOGIC;     --Traffic light status as Yello=>Blue on board
           
            led: out STD_LOGIC_VECTOR(1 downto 0);        --Monitor states [ led(0), led(1) ]
            red_led: out STD_LOGIC_VECTOR (1 downto 0):="00";    -- Red Light Camera [red_led(0), red_led(1) ];
            CC :        out STD_LOGIC;                     --Common cathode input to select respective 7-segment digit.
            out_7seg :  out STD_LOGIC_VECTOR (6 downto 0)  -- Output  signal for selected 7 Segment display.
    );
    end component;
    --Input Signals
    signal clk: STD_LOGIC;
    signal sw: STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
    signal btn: STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";  
 
    --Output Signal
    signal CC: STD_LOGIC:='0';
    signal led: std_logic_vector(1 downto 0);
    signal red_led: std_logic_vector(1 downto 0);
    signal led6_r,led6_b,led6_g : STD_LOGIC;
    signal out_7seg : STD_LOGIC_VECTOR (6 downto 0);
   
   --Clock period definition
   constant clock_period: time:= 1ns;  

begin
    tra: traffic_intersection port map
    (
        clk => clk,
        btn=>btn,
        sw => sw,
        led6_r => led6_r,
        led6_g => led6_g,
        led6_b => led6_b,
        led=>led,
        red_led=>red_led,
        CC => CC,
        out_7seg => out_7seg);

    clock:
        process
        begin
            clk <='0';
            wait for clock_period/2;
            clk <='1';
            wait for clock_period/2;
        end process;
       
--    Normal: process-- Normal operation
--    begin
--          btn<="0000";--display the EW side
--          wait for 200ns;
--          btn<="0001";--display the NS side
--          wait for 200ns;
--    end process;

--    RedLightCamera : process -- Red light camera shots in both directions.
--    begin
--          btn<="0100";--When in state 0, EW is green, and a veichel acrossin the EW direction, nothing
--          wait for 50ns;
--          btn<="1000";--When in state 0, EW is green, and a veichel acrossin the NS direction, should see red_led="10"
--          wait for 100ns;
--          btn<="1000";--When in state 0, NS is green, and a veichel acrossin the NS direction, nothing
--          wait for 50ns;
--          btn<="0100";--When in state 0, NS is green, and a veichel acrossin the EW direction, should see red_led="01"
--          wait for 100ns;
--    end process;

        -- Night mode operation.
    NightMode : process -- Red light camera shots in both directions.
    begin
          sw<="0000";--When in state 0, EW is green, and a veichel acrossin the EW direction, nothing
          wait for 50ns;
          sw<="1010";--When in state 0, EW is green, and a veichel acrossin the NS direction, should see red_led="10"
          wait for 50ns;
          sw<="1001";--When in state 0, NS is green, and a veichel acrossin the NS direction, nothing
          wait for 50ns;
    end process;
        -- Pedestrian cross walk signals.
   
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2019 02:33:08 PM
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
    Port(   
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
            out_7seg :  out STD_LOGIC_VECTOR (6 downto 0);  -- Output  signal for selected 7 Segment display. 
            je: in STD_LOGIC_VECTOR (7 downto 0)
           );
end component traffic_intersection;

signal clk: STD_LOGIC;
signal sw: STD_LOGIC_VECTOR(3 downto 0);
signal btn: STD_LOGIC_VECTOR(3 downto 0);
signal led6_r: STD_LOGIC;
signal led6_b: STD_LOGIC;
signal led6_g: STD_LOGIC;
signal CC : STD_LOGIC;   
signal out_7seg : STD_LOGIC_VECTOR (6 downto 0);
signal led: STD_LOGIC_VECTOR(1 downto 0);
signal red_led: STD_LOGIC_VECTOR (1 downto 0);
signal je: STD_LOGIC_VECTOR(7 downto 0);
constant clock_period: time:= 4 ns;

begin
    tfinsec: traffic_intersection port map
    (   
        CC => CC,
        clk => clk,
        sw => sw,
        btn => btn,
        led6_r => led6_r,
        led6_b => led6_b,
        led6_g => led6_g,
        out_7seg => out_7seg,
        led => led,
        red_led => red_led,
        je => je);
        
    clock: 
        process
        begin
            clk <='0';
            wait for clock_period/2;
            clk <='1';
            wait for clock_period/2;
        end process;
    
    simulation:
        process
        begin
        --for normal 
            btn <= "0000";
            sw <= "0000";
            je <= "11111111";
            wait for 200 ns;
            btn <= "0001";
            wait for 200 ns;
            sw <= "0001";
            wait for 200 ns;
            sw <= "0010";  
            wait for 200 ns;
            sw <= "0011";
            wait for 200 ns;
            
         --for red light camera
            btn <= "0101";
            wait for 200 ns;
            btn <= "1001";
            wait for 200 ns;
            btn <= "1000";
            wait for 200 ns;
            btn <= "0000";
            wait for 200 ns;
            
----         --for night mode
--            sw <= "1000";
--            wait for 50 ns;
--            sw <= "1000";
--            wait for 50 ns;
--            sw <= "1001";
--            wait for 200 ns;
--            sw <= "1000";
--            wait for 50 ns;
--            sw <= "1001";
--            wait for 200 ns;
--            sw <= "1000";
--            wait for 50 ns;
--            sw <= "1001";
--            wait for 200 ns;
--            sw <= "1000";
--            wait for 50 ns;
--            sw <= "1001";
--            wait for 200 ns;
--KeyPad
            je <= "10111011";
            --CC <= '1';
            wait for 200 ns;
            je <= "10111011";
           -- CC <= '0';
            wait for 200 ns;
            je <= "10111011";
           -- CC <= '1';
            wait for 200 ns;
            je <= "10111011";
           -- CC <= '0';
            wait for 200 ns;
            je <= "11111111";
            wait for 200 ns;
        end process;
       

end Behavioral;

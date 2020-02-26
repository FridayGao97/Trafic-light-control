----------------------------------------------------------------------------------
-- Company: University of Alberta
-- Engineer: Raza Bhatti
-- 
-- Create Date: 05/11/2018 11:22:20 AM
-- Design Name: traffic_intersection
-- Module Name: traffic_intersection - Behavioral
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
-- East/West and North/South intersection working. btn(0) used to see status of lights on respective direction of travel.
-- Red light camera on each direction of travel.
-- Night time quick green if red on direction of travel (e.g. North/South or East/West) and no vehicles on other direction of travel (e.g. North/South or East/West) 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity traffic_intersection is
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
            out_7seg :  out STD_LOGIC_VECTOR (6 downto 0);  -- Output  signal for selected 7 Segment display. 
            je: inout STD_LOGIC_VECTOR (7 downto 0)
           );
end traffic_intersection;

architecture Behavioral of traffic_intersection is
component Clock_OneHz is
    port (  clk: in STD_LOGIC;
            clk_1Hz: out STD_LOGIC
          );
end component;

signal clk_1Hz: std_logic;
signal count, Count_OneSecDelay_MSD, Count_OneSecDelay_LSD, digit_7seg_display, count_7seg: natural;
signal Count_OneSecDelay: natural:=9;       
signal states_mon: std_logic_vector(1 downto 0):="00";



TYPE STATES IS (S0,S1,S2,S3,S4,S5,S6);
signal state: STATES:=S0;

-- You can use following signals to implement design requirements or make your own.
signal NTSwitch: std_logic:='0';
signal VehiclesPresence: std_logic_vector(1 downto 0);
signal red_light_camera: std_logic_vector(1 downto 0):="00";
signal Count_RedLight: natural:=0;
signal blinking:STD_LOGIC:='0';
signal clk_out: std_logic:='0';
signal select_segment, clk_7seg_cc:std_logic:='0';


signal KeyPad_out: STD_LOGIC_VECTOR(3 downto 0) := "1000";

begin

    Decoder_4to7Segment: process (clk)
    begin

    -- Update following case statement to display complete range of digit_7seg_display values on 7-segments.
        case digit_7seg_display is
            when 0 =>  
                          out_7seg<="0111111";          --digit 0 display on segment #1 when CC='0' on segment #2 when CC='1'
            when 1 =>  
                          out_7seg<="0110000";          --digit 1 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 2 =>  
                          out_7seg<="1011011";          --digit 2 display on segment #1  when CC='0' on segment #2 when CC='1'          
            when 3 =>  
                          out_7seg<="1111001";          --digit 3 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 4 =>  
                          out_7seg<="1110100";          --digit 4 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 5 =>  
                          out_7seg<="1101101";          --digit 5 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 6 =>  
                          out_7seg<="1101111";          --digit 6 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 7 =>  
                          out_7seg<="0111000";          --digit 7 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 8 =>  
                          out_7seg<="1111111";          --digit 8 display on segment #1  when CC='0' on segment #2 when CC='1'
            when 9 =>  
                          out_7seg<="1111101";          --digit 9 display on segment #1  when CC='0' on segment #2 when CC='1'
        when others =>

    end case;
    -- End of your design lines.
    end process;


    --Instatitiate components
    clock_1Hz: process(clk)
    begin
        if rising_edge(clk) then
--           if(count<125000000) then    
            if(count<1) then    
                count<=count+1;
            else
                count<=0;
                clk_out<=not clk_out;
                clk_1Hz<=clk_out;
            end if;

--           if (count_7seg<10000) then
            if (count_7seg<1) then
                count_7seg<=count_7seg+1;
            else
                select_segment<=not select_segment;
                count_7seg<=0;
            end if;
        end if;
    end process;
    
    KeyPad_decoder: process (clk)
    begin
        if rising_edge(clk) then
           je(3 downto 0) <= "1011";
            if je(7 downto 4) = "1011" then
                KeyPad_out <= "1000";
            else
                KeyPad_out <= "1100";
            end if;
        end if;
    end process KeyPad_decoder;

    Select_7Segment: process (clk,clk_1Hz,select_segment,states_mon,KeyPad_out)
    begin

--        if(Count_OneSecDelay>9) then
--            --Write your design lines here 
--            --End of your design lines.
--            Count_OneSecDelay_MSD<= Count_OneSecDelay/10;
--            Count_OneSecDelay_LSD<=Count_OneSecDelay - Count_OneSecDelay_MSD*10;
--        else
--            Count_OneSecDelay_MSD<= 0;
--            Count_OneSecDelay_LSD<=Count_OneSecDelay;
--for requirement 5            
--            Count_OneSecDelay_MSD<= to_integer(unsigned(states_mon));
--            Count_OneSecDelay_LSD<=Count_OneSecDelay;
--        end if;
        
        
        
        if KeyPad_out = "1000" then
            if states_mon = "00" then
                Count_OneSecDelay_MSD <= 1;
                Count_OneSecDelay_LSD <= 0;
            elsif states_mon = "01" then
                Count_OneSecDelay_MSD <= 0;
                Count_OneSecDelay_LSD <= 0;
            elsif states_mon = "10" then
                Count_OneSecDelay_MSD <= 0;
                Count_OneSecDelay_LSD <= 1;
            elsif states_mon = "11" then
                Count_OneSecDelay_MSD <= 0;
                Count_OneSecDelay_LSD <= 0;
            else
                Count_OneSecDelay_MSD <= 0;
                Count_OneSecDelay_LSD <= 0;
            end if;
        elsif KeyPad_out = "1100" then
            Count_OneSecDelay_LSD<=Count_OneSecDelay;
        
            if states_mon = "00" then
                Count_OneSecDelay_MSD <= 0;
            elsif states_mon = "01" then
                Count_OneSecDelay_MSD <= 1;
            elsif states_mon = "10" then
                Count_OneSecDelay_MSD <= 2;
            elsif states_mon = "11" then
                Count_OneSecDelay_MSD <= 3;
            else
                Count_OneSecDelay_MSD <= 4;
            end if;
        

        end if;
        
        
        
        if select_segment='1' then
            digit_7seg_display<= Count_OneSecDelay_LSD;           
        else
            digit_7seg_display<= Count_OneSecDelay_MSD;           
        end if;

        CC<=select_segment;
          
    end process;

   TrafficIntersection: process (clk, clk_1Hz)
   begin

--You can write design lines here to capture vehicles presence and Night Time input (LDR).

-- Write your design line here to update VehiclesPresence(0)
    VehiclesPresence(0)<=sw(0);
-- Write your design line here to update VehiclesPresence(1)
    VehiclesPresence(1)<=sw(1);
-- Write your design line here to update NTSwitch

    NTSwitch<=sw(3);

--End of design lines.

        if btn(1)='1' then --Reset
            state<=S0;
            
        end if;
        
        if rising_edge(clk_1Hz) then
            Count_OneSecDelay<=Count_OneSecDelay-1;     --Increment one second count. ~1.84 sec delay here

            case state is
                when S0 =>                              --East/West direction light green
                        if Count_OneSecDelay>0 then
                            if btn(0)='0' then              --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='0';
                                led6_b<='0';
                                led6_g<='1';
                            else
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            end if;
                        else
                            state<=S1;                      
                            Count_OneSecDelay<=2;
                            if btn(0)='0' then         --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='0';
                                led6_b<='1';
                                led6_g<='0';
                            else
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            end if;
                        end if;
                        if (NTSwitch = '1' and  VehiclesPresence(1) = '1' and VehiclesPresence(0) = '0') then
                            Count_OneSecDelay<=2;
                            state<=S1;
                        end if;  
                    
                    states_mon<="00";
                    -- ~1.7 sec delay here

                when S1 =>                             --East/West direction light yellow=>blue on board                    
                        if Count_OneSecDelay>0 then
                            if btn(0)='0' then         --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='0';
                                led6_b<='1';
                                led6_g<='0';
                            else
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            end if;
                        else
                            state<=S2;
                            --Count_OneSecDelay<=20;
                            Count_OneSecDelay<=9;
                            if btn(0)='0' then          --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            else
                                led6_r<='0';
                                led6_b<='0';
                                led6_g<='1';
                            end if;                                
                        end if;
                    states_mon<="01";

                when S2 =>                              -- East/West direction light red and North/South direction green.
                        if Count_OneSecDelay>0 then
                            if btn(0)='0' then          --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            else
                                led6_r<='0';
                                led6_b<='0';
                                led6_g<='1';
                            end if;            
                        else
                            state<=S3;
                            Count_OneSecDelay<=2;
                            if btn(0)='0' then            --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            else
                                led6_r<='0';
                                led6_b<='1';
                                led6_g<='0';
                            end if;                                
                        end if;
                        if (NTSwitch = '1' and VehiclesPresence(0) = '1'and VehiclesPresence(1) = '0') then
                                Count_OneSecDelay<=2;
                                state<=S3;
                        end if;
        
                    states_mon<="10";

                    -- ~1.7 sec delay here

                when S3 =>
                        if Count_OneSecDelay>0 then
                            if btn(0)='0' then            --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                led6_r<='1';
                                led6_b<='0';
                                led6_g<='0';
                            else
                                led6_r<='0';
                                led6_b<='1';
                                led6_g<='0';
                            end if;                                
                        else
                            state<=S0;
                            --Count_OneSecDelay<=20;
                            Count_OneSecDelay<=9;
                            if Count_OneSecDelay>0 then
                                if btn(0)='0' then              --Since only have one RGB light, else no need. btn(0)='0' => East/West  btn(0)='1'=> North/South
                                    led6_r<='0';
                                    led6_b<='0';
                                    led6_g<='1';
                                else
                                    led6_r<='1';
                                    led6_b<='0';
                                    led6_g<='0';
                                end if;
                            end if;
                          end if;
                        states_mon<="11";
     
                        -- ~1.7 sec delay here

                when others =>                      --Error condition
                        state<=S0;
                        --Count_OneSecDelay<=20;
                        Count_OneSecDelay<=9;
                        led6_r<='1';
                        led6_b<='1';
                        led6_g<='1';
            end case;
         end if;
         
    end process;

    -- Write a process for Red Light Camera feature at the intersection.
    -- Hint: Since a flash light demo is desired, you can write a process to turn LED ON and another for OFF, in respective direction of travel.
    -- Start of your design
 RedLightCamera: process (clk)
    begin
        case state is
            when S0  =>              --EW is green
                if btn(3)='1' then        -- A car from NS
                    red_led <= "10";
                else
                    red_led <= "00";
                end if;
            when S1 =>                    --EW is green
                if btn(3)='1' then        -- A car from NS
                    red_led <= "10";
                else
                    red_led <= "00";
                end if;
            when S2  =>             --NS is green
                if btn(2)='1' then       -- A car from EW
                    red_led <= "01";
                else
                    red_led <= "00";
                end if;
           when S3  =>             --NS is green
                if btn(2)='1' then       -- A car from EW
                    red_led <= "01";
                else
                    red_led <= "00";
                end if;    
            when others =>
                red_led <= "00";
             
        end case;
    end process;
    -- End of your design

    led<=states_mon;
    
    

        
end Behavioral;

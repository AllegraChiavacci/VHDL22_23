-- Progetto Allegra Chiavacci (10733258), Alessandro Cavallo (10734387)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;


entity project_reti_logiche is
port ( i_clk : in std_logic; 
	i_rst : in std_logic; 
	i_start : in std_logic; 
	i_w : in std_logic; 
	o_z0 : out std_logic_vector(7 downto 0); 
	o_z1 : out std_logic_vector(7 downto 0); 
	o_z2 : out std_logic_vector(7 downto 0); 
	o_z3 : out std_logic_vector(7 downto 0); 
	o_done : out std_logic; 
	o_mem_addr : out std_logic_vector(15 downto 0); 
	i_mem_data : in std_logic_vector(7 downto 0); 
	o_mem_we : out std_logic; 
	o_mem_en : out std_logic );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type S is (WAIT_START, READ_INPUT, WAIT_CALC, ASK_MEM, WAIT_MEM, SAVE_DATA,
    WRITE_OUTPUT);
signal current_state: S;
signal curr_counter : std_logic_vector (4 downto 0);
 signal next_counter : std_logic_vector(4 downto 0);
 signal counter_ovf  : std_logic;
 signal counter_rst  : std_logic;
 signal generate_addr: std_logic;

 signal regnumoutput : std_logic_vector (1 downto 0);
 signal regaddress : std_logic_vector (15 downto 0);
 signal regbuffer_00 : std_logic_vector (7 downto 0);
 signal regbuffer_01 : std_logic_vector (7 downto 0);
 signal regbuffer_10 : std_logic_vector (7 downto 0);
 signal regbuffer_11 : std_logic_vector (7 downto 0);
 signal save_data_sign : std_logic;
 
 
 --contatore
component inc5 is
        port (
                input : in std_logic_vector (4 downto 0);
                output: out std_logic_vector (4 downto 0);
                overflow: out std_logic
                );
    end component;
    
    begin
    increment : inc5 port map(
            input => curr_counter,
            output => next_counter,
            overflow => counter_ovf
            );

--gestione avanzamento stati
	fsm: process(i_clk, i_rst)
	begin
		if(i_rst = '1') then
			current_state<= WAIT_START;
		elsif i_clk'event and i_clk = '1' then
			case current_state is
	           when WAIT_START =>
			     if i_start = '1' then
			             current_state <=READ_INPUT;
			     elsif i_start = '0' then
			             current_state <= WAIT_START;   
			         end if;
			  when READ_INPUT =>
			     if i_start = '1' then
			         current_state <= READ_INPUT;  
			    elsif i_start = '0' then
			         current_state <= WAIT_CALC; 
			         elsif counter_ovf = '1' then
			             current_state <=WAIT_START;
			     end if;
			    when WAIT_CALC =>
			         current_state <=ASK_MEM;
			    when ASK_MEM =>
			         current_state <= WAIT_MEM;
			    when WAIT_MEM =>
			    current_state <= SAVE_DATA;
			    when SAVE_DATA =>
			         current_state <=WRITE_OUTPUT;
			    when WRITE_OUTPUT =>
			          if i_start = '1' then
			             current_state <= READ_INPUT;
			          else
			          current_state <= WAIT_START;
			          end if;
		      end case;
		end if;
	end process;
	
	
	--gestione segnali 
	process (i_rst, current_state, regbuffer_00, regbuffer_01, regbuffer_10, regbuffer_11)
	begin 
	o_z0 <= "00000000";
	o_z1 <= "00000000";
	o_z2 <= "00000000";
	o_z3 <= "00000000";
	o_done <= '0';
	o_mem_we<= '0';
	o_mem_en <= '1';
	
	
	case current_state is
	   when WAIT_START =>
	   o_done <= '0';
	   generate_addr<='0';
	   counter_rst <='1'; 
	   save_data_sign <= '0';
	   
	   when READ_INPUT => 
	       counter_rst <= '0';
	       generate_addr<='0';
	       save_data_sign <= '0';
	   when WAIT_CALC =>
	       counter_rst <= '0';
	       generate_addr<='0';
	       save_data_sign <= '0';
	   when ASK_MEM =>
	   counter_rst <='0';
	   generate_addr <= '1';
	   save_data_sign <= '0';
	   when WAIT_MEM =>
	   counter_rst <='0';
	   generate_addr <= '1';
	   save_data_sign <= '0';
	   when SAVE_DATA =>
	   counter_rst <='1';
	   generate_addr<='1';
	   save_data_sign <= '1';
	   when WRITE_OUTPUT =>
	   counter_rst <='1';
	   generate_addr<='0';
	       o_done <= '1';
	       save_data_sign <= '0';
	      
	           o_z0<= regbuffer_00;
	      
	           o_z1<= regbuffer_01;
	     
	       o_z2<= regbuffer_10;
	      
	           o_z3<= regbuffer_11;
	       
	   
	   end case;
	end process;


--gestione salvataggio bit in ingresso
demux_counter: process (i_clk, i_start, curr_counter, i_w, current_state)
	begin
	if  i_clk'event and i_clk = '1' and i_start= '1' then
		case curr_counter is 
		when "00000" =>
		                  if (current_state = WAIT_START) then
		                  regnumoutput(1) <= i_w;
		                  elsif (current_state = WRITE_OUTPUT) then 
		                  regnumoutput(1) <= i_w;
		                  else
		                     regnumoutput(0) <= i_w;
		                  end if;
		when "00001" =>
		                  regaddress(15)<=i_w;
		                
		when "00010" =>
		                  regaddress(14)<=i_w;
		when "00011" =>
		regaddress(13)<=i_w;
		when "00100" => regaddress (12)<=i_w;
		when "00101" => regaddress (11)<=i_w;
		when "00110" => regaddress (10)<=i_w;
		when "00111" => regaddress (9)<=i_w;
		when "01000" => regaddress (8)<=i_w;
		when "01001" => regaddress (7)<=i_w;
		when "01010" => regaddress (6)<=i_w;
		when "01011" => regaddress (5)<=i_w;
		when "01100" => regaddress (4)<=i_w;
		when "01101" => regaddress (3)<=i_w;
		when "01110" => regaddress (2)<=i_w;
		when "01111" => regaddress (1)<=i_w;
		when "10000" => regaddress (0)<=i_w;
		when others => regaddress <= "0000000000000000";
		              regnumoutput <= "00";
		
	end case;
	end if;
	end process;


--incremento contatore
counter_reg: process(current_state, i_clk, counter_rst, i_start, next_counter)
	begin
		if counter_rst = '1' then
			curr_counter <= "00000";
		elsif i_clk'event and i_clk = '1' then 
		     case current_state is 
		     when READ_INPUT =>
			     curr_counter <= next_counter;
			 when WAIT_START =>
			     if i_start = '1' then
			     curr_counter <= next_counter;
			     end if;
			 when others =>
			 end case;
		end if;
	end process;

--Calcolo indirizzo
mem_addr_calc: process(generate_addr, regaddress, curr_counter)
	variable mycounter: integer range 0 to 18; --variabile contatore
	variable i: integer range 0 to 15;   --variabile per il for
	begin 
	   if generate_addr'event and generate_addr = '1' then
	   mycounter:= to_integer(unsigned(curr_counter));
		save_address: for i in 0 to 15 loop
        if i<(mycounter-2) then
            
            o_mem_addr(i) <= regaddress(18-mycounter+i); 
        else
            o_mem_addr(i) <= '0';
        end if;
        end loop save_address;
        end if;
        end process;
        
 process (i_rst, save_data_sign, regnumoutput)
  begin
    if i_rst = '1' then
        regbuffer_00 <= "00000000";
          regbuffer_01 <= "00000000";
          regbuffer_10 <= "00000000";
          regbuffer_11 <= "00000000";
    elsif save_data_sign'event and save_data_sign = '1' then
    case regnumoutput is 
    when "00" => 
            regbuffer_00 <= i_mem_data;
    when "01" => 
        regbuffer_01 <= i_mem_data;
    when "10" => 
        regbuffer_10 <= i_mem_data;
    when "11" => 
        regbuffer_11 <= i_mem_data;
    when others =>
          regbuffer_00 <= "XXXXXXXX";
          regbuffer_01 <= "XXXXXXXX";
          regbuffer_10 <= "XXXXXXXX";
          regbuffer_11 <= "XXXXXXXX";
    end case;
    end if;
  end process;
  
  end Behavioral;
 
 --INCREMENTER--
  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity inc5 is
port( input    : in std_logic_vector(4 downto 0);
    output   : out std_logic_vector(4 downto 0);
         overflow : out std_logic
     );
end inc5;

    architecture Behavioral of inc5 is
    begin
        output(0)<= not input(0);
        output(1)<= input (0) xor input(1);
        output(2)<=(input (0) and input(1)) xor input(2);
        output(3)<= (input (0) and input(1) and input(2)) xor input(3);
    output(4)<= (input (0) and input(1) and input(2) and input(3)) xor input(4);
    overflow <= input(0) and input(1) and input(2) and input(3) and input(4);
        end Behavioral;






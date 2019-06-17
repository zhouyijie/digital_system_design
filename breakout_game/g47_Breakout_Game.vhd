
-- entity name:g47_Breakout_Game
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: November 25, 2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
use IEEE.STD_logic_unsigned.all;

entity g47_Breakout_Game is
port (clock			:	in std_logic; --50MHz
		rst			:	in std_logic; --reset		
		level			:	in std_logic_vector(2 downto 0); --3 bits		
		paddle_left_button 		: in std_logic;
		paddle_right_button 		: in std_logic;
		reset_ball 	: in std_logic;
		R, G, B		:	out std_logic_vector (3 downto 0);		
		HSYNC			:	out std_logic; -- horizontal sync signal
		VSYNC			:	out std_logic --vertical sync signal)		
		);
end g47_Breakout_Game;


Architecture archlab4 of g47_Breakout_Game is
--Signals
Signal vga_Row, vga_Col : unsigned(9 downto 0); -- to store ROW and COL output from vga
Signal vga_blk_signal : std_logic;
Signal tag_font_col	:	std_logic_vector(2 downto 0);   -- 0 - 7
Signal tag_font_row	:	std_logic_vector(3 downto 0);  -- 0 - 15
Signal reg1_font_col	:	std_logic_vector(2 downto 0);   -- 0 - 7
Signal reg1_font_row	:	std_logic_vector(3 downto 0);  -- 0 - 15	
Signal tag_text_col	:	std_logic_vector(5 downto 0);  -- 0 - 50
Signal tag_text_row	:	std_logic_vector(4 downto 0);  -- 0 - 18
Signal tg_ASCII : std_logic_vector(6 downto 0);
Signal tg_R, tg_G, tg_B, other_R, other_G, other_B : std_logic_vector (3 downto 0); --not using the other_... stuff
Signal reg2_R, reg2_G, reg2_B: std_logic_vector (3 downto 0);
Signal CROM_pixel 	:	std_logic;
Signal slow_clock, fast_score_clear, score_clear	: std_logic;
Signal fast_score_count: std_logic_vector(23 downto 0);
Signal score_count:	std_logic_vector(15 downto 0);
Signal R1, G1, B1	:	std_logic_vector (3 downto 0);

--lab 5 signals
-- wall
--signal count_row: std_logic_vector (9 downto 0);--prob not used 
--signal count_col: std_logic_vector (9 downto 0);-- prob not used
--signal clear_col, clear_row : std_logic;--prob not used
--
--signal int_count_row : integer range 8 to 591;--not used
--signal int_count_col : integer range 8 to 791;--not used

signal intCol : integer range 0 to 800;
signal intRow : integer range 0 to 600;
signal currentRow : integer range 0 to 20; 

signal R_tg, G_tg, B_tg, R_other, G_other, B_other : std_logic_vector (3 downto 0);
--signal enableLine : std_logic;

--ball and paddle signals
signal ball_direction_row : std_logic;
signal ball_direction_col : std_logic;
signal ball_enable_row : std_logic;
signal ball_enable_col : std_logic;
signal ball_row : std_logic_vector(9 downto 0);
signal ball_col : std_logic_vector(9 downto 0);
signal ball_enable_line1 : std_logic;
signal ball_enable_line2 : std_logic;
signal rst_Ball : std_logic;
signal clear_Ball : std_logic;
signal rst_inGame : std_logic := '0';
signal rst_level : std_logic := '0';
signal ball_touches_top : std_logic := '0';
signal ball_touches_bottom : std_logic := '0';
signal ball_touches_paddle : std_logic := '0';
signal ball_touches_left : std_logic := '0';
signal ball_touches_right : std_logic := '0';
signal paddle_position : std_logic_vector(9 downto 0);
signal paddle_enable : std_logic;
signal paddle_direction : std_logic;

signal clear1, clear2, clear3 : std_logic;
signal count1, count2 : std_logic_vector(15 downto 0);
signal count3 : std_logic_vector(2 downto 0);
signal stop : std_logic := '0';

--Blocks
signal blocks : std_logic_vector(59 downto 0);
signal score_enable : std_logic;
signal life_enable : std_logic := '0';
signal life_now : std_logic_vector(2 downto 0) := "101";
signal initial_lives : integer range 0 to 21 :=21;
signal level_now : std_logic_vector(2 downto 0) := "001";

--Componenets
-- VGA
Component g47_VGA
	port(	clock			:	in std_logic; --50MHz
			rst			:	in std_logic; --reset
			BLANKING		:	out std_logic; -- blank display when 0
			ROW			:	out unsigned(9 downto 0);	-- line 0 to 599
			COLUMN		: 	out unsigned(9 downto 0);	-- column 0 to 799
			HSYNC			:	out std_logic; -- horizontal sync signal
			VSYNC			:	out std_logic --vertical sync signal)
			);
end component;

-- Text_Address_Generator
Component g47_Text_Address_Generator is
	port(	ROW			:	in unsigned(9 downto 0);	-- line 0 to 599
			COLUMN		: 	in unsigned(9 downto 0);	-- column 0 to 799
			text_row		:	out std_logic_vector(4 downto 0);  -- 0 - 18
			text_col		:	out std_logic_vector(5 downto 0);  -- 0 - 50
			font_row		:	out std_logic_vector(3 downto 0);  -- 0 - 15
			font_col		:	out std_logic_vector(2 downto 0)   -- 0 - 7
			);
end component;

--Text_Generator
Component g47_Text_Generator is
	port(	text_row		: in std_logic_vector(4 downto 0);  -- 0 - 18
			text_col		: in std_logic_vector(5 downto 0);  -- 0 - 50
			score			: in std_logic_vector(15 downto 0); --16 bits
			level			: in std_logic_vector(2 downto 0); --3 bits
			life			: in std_logic_vector(2 downto 0); --3 bits
			ASCII			: out std_logic_vector(6 downto 0); -- 7bit ASCII code
			R, G, B		: out std_logic_vector (3 downto 0)
			);			
end component;

--Text_Pattern_Generator (will not need)
Component g47_VGA_Test_Pattern is
port (clock		: 	in std_logic; 
		rst		:	in std_logic; --reset
		R, G, B	:	out std_logic_vector (3 downto 0);
		HSYNC		:	out std_logic; -- horizontal sync signal
		VSYNC		:	out std_logic --vertical sync signal)
		);
end component;


--fontROM
Component fontROM is
	generic(
		addrWidth: integer := 11;
		dataWidth: integer := 8
	);
	port(
		clkA: in std_logic;
		char_code : in std_logic_vector(6 downto 0); -- 7-bit ASCII character code
		font_row : in std_logic_vector(3 downto 0); -- 0-15 row address in single character
		font_col : in std_logic_vector(2 downto 0); -- 0-7 column address in single character
		font_bit : out std_logic -- pixel value at the given row and column for the selected character code
	);
end component;

--Video Overlay
Component g47_VGA_Overlay is
port (pixel		: 	in std_logic; --selection line
		R_in_TG, G_in_TG, B_in_TG	:	in std_logic_vector (3 downto 0);
		R_in_other, G_in_other, B_in_other	:	in std_logic_vector (3 downto 0);		
		R, G, B	:	out std_logic_vector (3 downto 0)
		);
end component;

Begin

--score counting		
--have first counter count to a very high number, when it recheases that number, it triggers the clock of the second counter
ScoreCounter1 :	lpm_counter
						generic map (LPM_WIDTH => 24)
						port map (clock => clock, sclr => fast_score_clear, aclr => rst, q => fast_score_count);	
	
with fast_score_count select
	slow_clock <= 	'1' when "111111111111111111111111",
						'0' when others;
--slow_clock <= '0' when stop = '1' else '0';						
--	with fast_score_count select
--	fast_score_clear <= 	'1' when "1111111111111111",
--								'0' when others;
				
ScoreCounter2 : 	lpm_counter
						generic map (LPM_WIDTH => 16)
						--port map (clock => slow_clock, sclr => score_clear, aclr => rst, q => score_count);
						port map (clock => clock, aclr => rst, cnt_en => slow_clock, q => score_count);
							
--paddle speed counter						
PaddleSpeedCounter: lpm_counter
generic map(LPM_WIDTH =>16)
port map(clock => clock, sclr => clear1, q => count1);
with count1 select 
ball_enable_line1 <= '1' when "1111111111111111",
							'0' when others;
clear1 <='1' when count1 = "1111111111111111" or rst = '1' else
			'0';		 

	
--ball speeed counter
BallSpeedCounter: lpm_counter
generic map(LPM_WIDTH => 3)
port map(clock => clock, sclr => clear3, q=>count3, cnt_en => ball_enable_line1 );
	ball_enable_line2 <= '1' when count3 = "111" or stop = '1' else
								'0';
	clear3 <='1' when count3 = "111" or rst = '1' else						
				'0';
							


---- Counter for ball row and collumn
BallRowCounter: lpm_counter
generic map(LPM_WIDTH => 10)
port map(clock => clock, sclr => rst, sload => clear_Ball, data => "0011100110", q=> ball_row, cnt_en => ball_enable_line2, updown => ball_direction_row);
					 
BallColCounter: lpm_counter
generic map(LPM_WIDTH => 10)
port map(clock => clock, sclr => rst, sload => clear_Ball, data => "0110010000", q=> ball_col, cnt_en => ball_enable_line2, updown => ball_direction_col);

---- Counter for paddle
PaddlePositionCounter: lpm_counter
generic map(LPM_WIDTH => 10)
port map(clock=>clock, sclr =>rst, sload => clear_Ball, data => "0110010000", q=>paddle_position, cnt_en => (paddle_enable and ball_enable_line1), updown=>paddle_direction);
		--clear_Ball <='0' when reset_ball = '0' else
					-- '1';		
	
	
--component connections			
compVGA : g47_VGA port map (clock => clock, rst => rst, ROW =>vga_Row, COLUMN =>vga_Col, BLANKING => vga_blk_signal, HSYNC => HSYNC, VSYNC => VSYNC);
compTAG : g47_Text_Address_Generator port map (ROW => vga_Row, COLUMN => vga_Col, text_row => tag_text_row, text_col => tag_text_col, font_row => tag_font_row, font_col=> tag_font_col);
compTG :	g47_Text_Generator port map (text_row => tag_text_row, text_col => tag_text_col, score => score_count, level => level, life => life_now, ASCII => tg_ASCII, R => tg_R, G => tg_G, B=> tg_B);
compCROM : fontROM port map (clkA => clock, char_code => tg_ASCII, font_row => reg1_font_row, font_col => reg1_font_col, font_bit => CROM_pixel);	
compVO : g47_VGA_Overlay port map (pixel => CROM_pixel, R_in_TG => R_tg, G_in_TG => G_tg, B_in_TG => B_tg, R_in_other=> R_other, G_in_other=> G_other , B_in_other=> B_other, R => R1, G => G1, B => B1 ); 

--Final Output, this are the same output from the VGA_overlay circuit	
R <= R1; 
B <= B1;
G <= G1;
--life <= life_now;

-- register process to make score look clear, to account for timing delays
process_register1: process(clock, rst)
begin
	if (rst = '1') then
		reg1_font_col	<= (others => '0');
		reg1_font_row	<= (others => '0');
		reg2_R <= (others => '0');
		reg2_G <= (others => '0');
		reg2_B <= (others => '0');
	elsif (rising_edge(clock)) then
		reg1_font_col	<= tag_font_col;
		reg1_font_row	<= tag_font_row;
		reg2_R <= tg_R;
		reg2_G <= tg_G;
		reg2_B <= tg_B;
	end if;	
end process;	
	
--lab5 start	
--	
process_main : process(clock)
variable int_ball_row : integer range 0 to 600;
variable int_ball_col : integer range 0 to 800;	
variable block_row_no : integer range 0 to 5; 
variable int_paddle_position : integer range 0 to 800;


begin
--converting to integer the current row value from text address generator
currentRow <= to_integer(unsigned(tag_text_row));	

if(rising_edge(clock)) then
	if(vga_blk_signal = '1')then
		intCol <= to_integer(vga_Col); 
		intRow <= to_integer(vga_Row);
		int_ball_row := to_integer(unsigned(ball_row))+20;
		int_ball_col := to_integer(unsigned(ball_col))+20;
		int_paddle_position := to_integer(unsigned(paddle_position))+80;
		
		-- if row 17 (from text_Address_Generator), print score on screen	
		if (currentRow = 17) then  
			if (CROM_pixel = '1') then
				R_tg	<=	reg2_R;			
				G_tg	<=	reg2_G;				
				B_tg	<=	reg2_B;				
			else					
				R_other<="0000";
				G_other<="0000";
				B_other<="0000";								
			end if;
		-- if i am not in current row 17 (anywhere else), this includes blocks, ball, paddle and wall 		
		else 
			--and it is not the border, then output is black
			if(intCol > 16) and (intCol < 784) and (intRow> 16) then 
				R_other<="0000";
				G_other<= "0000";
				B_other<= "0000";
				
			--The construction of blocks
				for i in 0 to 59 loop
					if(blocks(i)='1') then
						block_row_no := i/12;  
						if(block_row_no = 0) then
							if(i*64+16 < intCol) and ((i+1)*64+16 > intCol) 
								and (16*(block_row_no+1) < intRow) and (48*(block_row_no+1) > intRow) then
								R_other <= "0000";
								G_other <= "1111";
								B_other <= "0000";
							end if;		
						elsif(block_row_no = 1) then
							if((i-block_row_no*12)*64+16 < intCol) and (((i-block_row_no*12)+1)*64+16 > intCol) 
								and (32*(block_row_no)+16 < intRow) and (32*(block_row_no+1)+16 > intRow) then
								R_other <= "1111";
								G_other <= "0000";
								B_other <= "0000";
							end if;
						elsif(block_row_no = 2) then
							if((i-block_row_no*12)*64+16 < intCol) and (((i-block_row_no*12)+1)*64+16 > intCol) 
								and (32*(block_row_no)+16 < intRow) and (32*(block_row_no+1)+16 > intRow) then
								R_other <= "0000";
								G_other <= "0000";
								B_other <= "1111";
							end if;
						elsif(block_row_no = 3) then
							if((i-block_row_no*12)*64+16 < intCol) and (((i-block_row_no*12)+1)*64+16 > intCol) 
								and (32*(block_row_no)+16 < intRow) and (32*(block_row_no+1)+16 > intRow) then
								R_other <= "0110";
								G_other <= "0110";
								B_other <= "0110";
							end if;
						elsif(block_row_no > 3) then
							if((i-block_row_no*12)*64+16 < intCol) and (((i-block_row_no*12)+1)*64+16 > intCol) 
								and (32*(block_row_no)+16 < intRow) and (32*(block_row_no+1)+16 > intRow) then
								R_other <= "0000";
								G_other <= "1111";
								B_other <= "0000";
							end if;
						end if;
						
					--Deconstruction of blocks 	
					elsif(blocks(i)='0') then
						block_row_no := i/12; 
							if(block_row_no = 0) then
								if(i*64+16 < intCol) and ((i+1)*64+16 > intCol) 
								and (16*(block_row_no+1) < intRow) and (48*(block_row_no+1) > intRow) then
									R_other <= "0000";
									G_other <= "0000";
									B_other <= "0000";
								end if;		
							elsif(block_row_no > 0) then
								if((i-block_row_no*12)*64+16 < intCol) and (((i-block_row_no*12)+1)*64+16 > intCol) 
								and (32*(block_row_no)+16 < intRow) and (32*(block_row_no+1)+16 > intRow) then
									R_other <= "0000";
									G_other<= "0000";
									B_other<= "0000";
								end if;													
							end if;
					end if;	
				end loop;		
			--construction of BALL 
				if (int_ball_col-4 < intCol) and (intCol < int_ball_col+4) and (intRow >int_ball_row-4) and (intRow < int_ball_row+4) then
					R_other<= "1111";
					G_other<= "1111";
					B_other<= "1111";
				end if;
			--construction of PADDLE 
				if(int_paddle_position-64 < intCol) and (intCol< int_paddle_position+64) and (intRow >528) and (intRow < 544) then
					R_other<= "1110";
					G_other<= "1110";
					B_other<= "1110";
				end if;
			--------
				else			
					--top border					
					if(intRow < 16) then					
						R_other<= "1111";
						G_other<= "1111";
						B_other<= "0000";
					--left border and right border
					elsif (intCol < 16) or (intCol > 783) then
						R_other<= "1111";
						G_other<= "1111";
						B_other<= "0000";
					--all other stuff = black	
					else
						R_other<= "0000";
						G_other<= "0000";
						B_other<= "0000";											
					end if;					
			end if;
		end if;
	end if;
end if;
end process;


--block breaking process
BlockBreaker : process(clock)
variable int_ball_row1 : integer range 0 to 600;
variable int_ball_col1 : integer range 0 to 800;
variable int_ball_row_on : integer range 0 to 600;
variable int_ball_col_on : integer range 0 to 800;
variable int_paddle1: integer range 0 to 800;
variable int_paddle_on: integer range 0 to 800;
variable temp : integer range 0 to 59;
variable int_life_now : integer range 0 to 10;
variable life_counter_now : integer range 0 to 21;
begin
		
if(rising_edge(clock)) then
ball_touches_bottom <='0';
ball_touches_left <= '0';
ball_touches_right <= '0';
ball_touches_top <= '0';
ball_touches_paddle <='0';
score_enable <='0';
rst_inGame <= '0';
life_enable <= '0';
int_life_now := to_integer(unsigned(life_now));
life_counter_now := initial_lives; 
	if(reset_ball = '1') then
		blocks <= (others => '1');
		life_counter_now :=15;
		level_now <="001";
		stop <= '0';
	elsif(rst_level = '1') then
		blocks<=(others =>'1');
	end if;
	
	rst_level <= '0';	
	int_ball_row1 := to_integer(unsigned(ball_row))+20;
	int_ball_col1 := to_integer(unsigned(ball_col))+20;
	int_paddle1 := to_integer(unsigned(paddle_position))+80;
	
	int_ball_row_on := (int_ball_row1-4);
	int_ball_col_on :=(int_ball_col1-4);
	int_paddle_on :=(int_paddle1-16);
	--when ball touches the bottom of the block 
	if((int_ball_row_on=48) or (int_ball_row_on=80)	or (int_ball_row_on=112) or (int_ball_row_on=144) or (int_ball_row_on=176))
		AND (ball_direction_row='0') then
		temp := (int_ball_row_on-16-1)/32*12+((int_ball_col1-4-16)/64); 
		if(blocks(temp)= '1') then
			blocks(temp) <= '0';
			ball_touches_bottom <='1';
			score_enable <='1';				
	   end if;
	--when ball touches the top of the block 
	elsif((int_ball_row_on=48) or (int_ball_row_on=80) or (int_ball_row_on=112) or (int_ball_row_on=144)) 
			AND (ball_direction_row='1') then	
			temp := (int_ball_row_on-16)/32*12+((int_ball_col1-4-16)/64); 
			if(blocks(temp)= '1') then
				blocks(temp) <= '0';
				ball_touches_top <='1';
				score_enable <='1';				
		   end if;
	--when ball touches the right side of the block 
	elsif (((int_ball_col_on -16)mod 64 ) = 0) AND (int_ball_row_on<=176) AND (ball_direction_col = '0')then			
		temp := ((int_ball_col_on-16-1)/64)+((int_ball_row_on-16-1)/32*12);
		if(blocks(temp)= '1') then
			blocks(temp) <= '0';
			ball_touches_right <='1';
			score_enable <='1';				
		end if;
	--when ball touches the left side of the block
	elsif (((int_ball_col_on -16)mod 64 ) = 0) AND (int_ball_row_on<=176) AND (ball_direction_col = '1')then			
		temp := ((int_ball_col_on-16)/64)+((int_ball_row_on-16-1)/32*12);
		if(blocks(temp)= '1') then
			blocks(temp) <= '0';
			ball_touches_left <='1';
			score_enable <='1';
	   end if;
	--when ball touches paddle
	elsif (int_ball_row_on = 524) and (int_ball_col_on<int_paddle_on+64) and(int_ball_col_on > int_paddle_on-64) then
		ball_touches_paddle <='1';
	--when ball goes out of bounds
	elsif((ball_row = "1000000111")) then
		if(life_counter_now = 3) then
		stop <= '1';
	end if;
		life_counter_now := life_counter_now - 1;
		rst_inGame <='1';
	end if;
			
	initial_lives <= life_counter_now;
	life_now <= std_logic_vector(to_unsigned(life_counter_now/3, 3));
	if ((to_integer(unsigned(blocks))) = 0) then
		level_now <= std_logic_vector( unsigned(level_now) + 1 );
		rst_level <= '1';
	end if;		
end if;
end process;
--ball control process	
ballControl : process(clock)
begin
	if(rising_edge(clock)) then
		if(reset_ball = '1') or (rst_inGame = '1') then
			clear_Ball <= '1';
		else 
			clear_Ball <='0';			
		end if;

		if(reset_ball = '1') or (rst_inGame = '1') then
			ball_direction_row  <= '1';
		elsif (ball_touches_top = '1')  or (ball_touches_paddle='1') then
			ball_direction_row  <= '0';
		elsif(ball_row = "0000000000") or (ball_touches_bottom='1')then
			ball_direction_row  <= '1';
		elsif((ball_row = "1000000111")) then
			ball_direction_row  <= '0';		
		end if;
		
		if(reset_ball = '1') or (rst_inGame = '1')then				
			ball_direction_col  <= '1';					
		elsif(ball_col = "1011110111") or (ball_touches_left = '1') then
			ball_direction_col  <= '0';
		elsif(ball_col = "0000000000") or (ball_touches_right = '1') then
			ball_direction_col  <= '1';
		end if;	

end if;
end process;

--paddle control process
paddleControl : process(clock)
begin
if(rising_edge(clock)) then
	paddle_enable<= '0';	
	if(paddle_left_button = '0') and (paddle_position > "0000000000") then
		paddle_enable <='1';
		paddle_direction <= '0';	
	elsif(paddle_right_button='0') and (paddle_position < "1001111111")then
		paddle_enable <= '1';
		paddle_direction <= '1';
	end if;
end if;
end process paddleControl;


end Archlab4;

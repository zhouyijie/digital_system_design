--
-- entity name:g47_vga
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: October 28, 2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
use IEEE.STD_logic_unsigned.all;

entity g47_VGA is
	port(	clock			:	in std_logic; --50MHz
			rst			:	in std_logic; --reset
			BLANKING		:	out std_logic; -- blank display when 0
			ROW			:	out unsigned(9 downto 0);	-- line 0 to 599
			COLUMN		: 	out unsigned(9 downto 0);	-- column 0 to 799
			HSYNC			:	out std_logic; -- horizontal sync signal
			VSYNC			:	out std_logic --vertical sync signal)
			);
end g47_VGA;

Architecture archvga of g47_VGA is

Signal vcount	:	std_logic_vector(9 downto 0);
Signal hcount	:	std_logic_vector(10 downto 0);
Signal hclear, vclear	:	std_logic;
signal int_hcount	:	integer range 0 to 1039;
signal int_vcount	: 	integer range 0 to 665;

Begin
Hcounter : 	lpm_counter
				generic map (LPM_WIDTH => 11)
				port map (clock => clock, sclr => hclear, aclr => rst, q => hcount);
with hcount select
hclear <= 	'1' when "10000001111", -- when the value reaches 1039, clear the hsync
				'0' when others;				
				
				
Vcounter : 	lpm_counter
				generic map (LPM_WIDTH => 10)
				port map (clock => clock, cnt_en => hclear, sclr => vclear, aclr => rst, q => vcount);
with vcount select
vclear <=	hclear when "1010011001", -- when the value reaches 665, clear the hsync
				'0' when others;
			
--conversion of hcount and vcount to integer values
int_hcount <= to_integer(unsigned(hcount));  
int_vcount <= to_integer(unsigned(vcount));

--the row is set to unsigned 10 bit, with max value 599 
ROW <=	to_unsigned(599,10) when (((int_vcount) > to_unsigned(642,10)) or ((int_vcount) < to_unsigned(43,10))) --599 when (vcount>642 or <43)
			else
			((int_vcount) - to_unsigned(43,10));		-- (vertical counter value - 43)
		
--the column is set unsigned 10 bit, with max value 799 		
COLUMN <=	to_unsigned(799,10) when (((int_hcount) > to_unsigned(975,10)) or ((int_hcount) < to_unsigned(176,10))) --799 when (hcount>975 or <176)
				else
				((int_hcount)- to_unsigned(176,10));		-- (horizontal counter value - 176)
		 
--Vsync is 0 when vertical counter is 0 to 6 else it is 1 	 
VSYNC <=		'1' when int_vcount >= to_unsigned(6,10)
				else
				'0';
--Hsync is 0 when horizontal counter is 0 to 120 else it is 1 			
HSYNC <= 	'1' when int_hcount >= to_unsigned(120,10)
				else
				'0';

-- from diagram blanked (RGB set to 0) when,
-- vcount <43 or >642
-- or when hcount <176 or >975  
BLANKING <=	'0' when (((int_vcount) < to_unsigned(43,10)) or ((int_vcount) > to_unsigned(642,10)) 
				or ((int_hcount) < to_unsigned(176,10)) or ((int_hcount) > to_unsigned(975,10))) 
				else
				'1';
end archvga;

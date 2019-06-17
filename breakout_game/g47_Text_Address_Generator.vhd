--
-- entity name:g47_vga
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: November 14, 2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_logic_unsigned.all;

entity g47_Text_Address_Generator is
	port(	ROW			:	in unsigned(9 downto 0);	-- line 0 to 599
			COLUMN		: 	in unsigned(9 downto 0);	-- column 0 to 799
			text_row		:	out std_logic_vector(4 downto 0);  -- 0 - 18
			text_col		:	out std_logic_vector(5 downto 0);  -- 0 - 50
			font_row		:	out std_logic_vector(3 downto 0);  -- 0 - 15
			font_col		:	out std_logic_vector(2 downto 0)   -- 0 - 7
			);
end g47_Text_Address_Generator;

Architecture arch1 of g47_Text_Address_Generator is
--conversion of unsigned to integer
signal int_ROW		:	integer range 0 to 599;
signal int_COL		: 	integer range 0 to 799;

Begin

--int_ROW 		<= to_integer(ROW);
--text_row 	<= std_logic_vector(to_unsigned((int_ROW/32),5));
--font_row 	<= std_logic_vector(to_unsigned(((int_ROW/2) mod 16),4));
--
--int_COL 		<= to_integer(COLUMN);
--text_col 	<= std_logic_vector(to_unsigned((int_COL/16),6));
--font_col		<= std_logic_vector(to_unsigned(((int_COL/2) mod 8),3));

-- has the same function as above commented out code
text_row <= std_logic_vector(ROW(9 downto 5));  --right shift by 5 bits (div by 32=2^5)
text_col <= std_logic_vector(COLUMN(9 downto 4)); --right shift by 4 bits (div by 16=2^4)
font_row <= std_logic_vector(ROW(4 downto 1)); -- right shift by 1 bit (div by 2=2^1),this removes bit 0, and then take remaining 4 LSB (MOD 16=2^4)
font_col <= std_logic_vector(COLUMN(3 downto 1)); -- right shift by 1 bit (div by 2=2^1),this removes bit 0, and then take remaining 3 LSB (MOD 8=2^3) 

End arch1;  

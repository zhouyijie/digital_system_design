--
-- entity name:g47_keyboard_encoder
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: October 16, 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
use IEEE.STD_logic_unsigned.all;

entity g47_keyboard_encoder is 
	port(	keys	: in std_logic_vector(63 downto 0); 
			ASCII_CODE	:	out std_logic_vector(6 downto 0));
end g47_keyboard_encoder;

Architecture archkeyboard of g47_keyboard_encoder is
	signal encoder64_6: std_logic_vector(5 downto 0);
	
Component g47_64_6_encoder
	port(input: in std_logic_vector(63 downto 0);
			codeA: out std_logic_vector(5 downto 0);
			errorA: out std_logic);
end Component;

begin	
	--component instantiation
	gate5: g47_64_6_encoder port map(input=>keys, codeA=>encoder64_6);
	
	--If the msb of the encoder signal is 1 we do a cancatnation of '01' with the remaining 5 bits of the signal
	--else we do a cancatnation of '10' with the remaining 5 bits of the signal giving a 7 bit output
	--So the possible values of the first three bits are either '010','011','100' or '101'
	--which when converted to base 10, are 2,3,4 and 5. i.e. The column number of the required keys in the given ASCII table
	--the final 4 bit represent the row number of the keys
	ASCII_CODE <= 	"01" & encoder64_6(4 downto 0) when encoder64_6(5) = '0' else		-- for keys 0 to 31, columns 2 and 3 	
						"10" & encoder64_6(4 downto 0) when encoder64_6(5) = '1' else  		-- for keys 32 to 63, columns 4 and 5
						"1111111";

end archkeyboard;	
	

 

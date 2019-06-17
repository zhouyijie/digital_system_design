--
-- entity name:g47_64_6_encoder
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: October 14, 2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
use IEEE.STD_logic_unsigned.all;

entity g47_7_segment_decoder is
	port(asci_code : in std_logic_vector(6 downto 0);
			segments: out std_logic_vector(6 downto 0));
end g47_7_segment_decoder;

Architecture arch7segmentdecoder of g47_7_segment_decoder is
	--signal kbencodersignal: std_logic_vector(6 downto 0);

begin

	
	with asci_code select
		segments <=
		  --6543210
			"1000000" when "0110000",	--key at column 3 row 0, 0 
			"1111001" when "0110001",	--key at column 3 row 1, 1
			"0100100" when "0110010",	--key at column 3 row 2, 2
			"0110000" when "0110011",	--key at column 3 row 3, 3
			"0011001" when "0110100",	--key at column 3 row 4, 4
			"0010010" when "0110101",	--key at column 3 row 5, 5
			"0000011" when "0110110",	--key at column 3 row 6, 6
			"1111000" when "0110111",	--key at column 3 row 7, 7
			"0000000" when "0111000",	--key at column 3 row 8, 8
			"0011000" when "0111001",	--key at column 3 row 9, 9
			
		  --6543210 
			"0001000" when "1000001",	--key at column 4 row 1, A
			"0000011" when "1000010",	--key at column 4 row 2, B
			"1000110" when "1000011",	--key at column 4 row 3, C
			"0100001" when "1000100",	--key at column 4 row 4, D
			"0000110" when "1000101",	--key at column 4 row 5, E
			"0001110" when "1000110",	--key at column 4 row 6, F
			"1000010" when "1000111",	--key at column 4 row 7, G
			"0001011" when "1001000",	--key at column 4 row 8, H
			"1001111" when "1001001",	--key at column 4 row 9, I
			"1100001" when "1001010",	--key at column 4 row 10, J
			"0001111" when "1001011",	--key at column 4 row 11, K
			"1000111" when "1001100",	--key at column 4 row 12, L
			"1001000" when "1001101",	--key at column 4 row 13, M
			"0101011" when "1001110",	--key at column 4 row 14, N
			"1000000" when "1001111",	--key at column 4 row 15, O

		  --6543210	
			"0001100" when "1010000",	--key at column 5 row 0, P
			"0100011" when "1010001",	--key at column 5 row 1, Q
			"1001110" when "1010010",	--key at column 5 row 2, R
			"0010010" when "1010011",	--key at column 5 row 3, S
			"0000111" when "1010100",	--key at column 5 row 4, T
			"1000001" when "1010101",	--key at column 5 row 5, U
			"1011001" when "1010110",	--key at column 5 row 6, V
			"1100011" when "1010111",	--key at column 5 row 7, W
			"0001001" when "1011000",	--key at column 5 row 8, X
			"0010001" when "1011001",	--key at column 5 row 9, Y
			"0100100" when "1011010",	--key at column 5 row 10, Z
		
			"1111111" when others;


end arch7segmentdecoder;
		
	

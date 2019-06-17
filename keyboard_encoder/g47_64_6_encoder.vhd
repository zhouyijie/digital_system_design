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

entity g47_64_6_encoder is
	port( input	:	in std_logic_vector(63 downto 0);
			codeA	:	out std_logic_vector(5 downto 0);
			errorA	:	out std_logic );
end g47_64_6_encoder;

Architecture arch2 of g47_64_6_encoder is
	Signal encoder1: std_logic_vector (3 downto 0);
	Signal encoder2: std_logic_vector (3 downto 0);
	Signal encoder3: std_logic_vector (3 downto 0);
	Signal encoder4: std_logic_vector (3 downto 0);
	Signal error1: std_logic_vector (3 downto 0);

--declaring the 16:4 encoder that we previously made as our componenet
Component g47_16_4_Encoder
	port
	(
		BLOCK_COL : in std_logic_vector(15 downto 0);
		CODE : out std_logic_vector(3 downto 0);
		ERROR	:	out std_logic		
	);
end component;

--declaring the 4 gates which are the 4 16:4 encoders
Begin	
	gate1: g47_16_4_Encoder port map (BLOCK_COL=>input(15 downto 0), CODE=>encoder1, ERROR=>error1(0));
	gate2: g47_16_4_Encoder port map (BLOCK_COL=>input(31 downto 16), CODE=>encoder2, ERROR=>error1(1));
	gate3: g47_16_4_Encoder port map (BLOCK_COL=>input(47 downto 32), CODE=>encoder3, ERROR=>error1(2));
	gate4: g47_16_4_Encoder port map (BLOCK_COL=>input(63 downto 48), CODE=>encoder4, ERROR=>error1(3));
	
	--the six bit output has the form 00e1 or 01e2 or 10e3 or 11e4
	--where e1 to e4 are the respective 4 bit out of encoders1 to encoder4 
	codeA <= "000000" + encoder1 when error1(0) = '0' else
				"010000" + encoder2 when error1(1) = '0' else
				"100000" + encoder3 when error1(2) = '0' else
				"110000" + encoder4 when error1(3) = '0' else
				"000000";
	--the error line is high i.e. '1' when the error lines of all the 4 16:4 encoders are also high			
	errorA <=	'0' when error1(0) = '0' else
					'0' when error1(1) = '0' else
					'0' when error1(2) = '0' else
					'0' when error1(3) = '0' else
					'1';	
End arch2;

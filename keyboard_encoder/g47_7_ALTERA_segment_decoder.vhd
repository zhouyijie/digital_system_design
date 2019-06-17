-- entity name: g38_7__ALTERA_segment_decoder
--
-- Copyright (C) 2016 Sadnan Saquif, Yijie Zhou
-- Version 1.0
-- Author: Sadnan Saquif, Yijie Zhou 
-- Date: October 06, 2016


library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm;
use lpm.lpm_components.all;
use IEEE.STD_logic_unsigned.all;

entity g47_7_ALTERA_segment_decoder is
	port (inputlines: in std_logic_vector(9 downto 0);
			outputlines : out std_logic_vector(6 downto 0)); 
end g47_7_ALTERA_segment_decoder;

architecture archaltera of g47_7_ALTERA_segment_decoder is 
	signal midwaysignal  :  std_logic_vector(6 downto 0);
	
	component g47_keyboard_encoder
		port ( 	keys: in std_logic_vector(63 downto 0);
					ASCII_CODE : out std_logic_vector(6 downto 0));
	end component;
	
	component  g47_7_segment_decoder 
		port ( 	asci_code: in std_logic_vector(6 downto 0);
					segments: out std_logic_vector(6 downto 0));
	end component;
	
	begin
	--Instantiating Componenets
	--keepinf the first 38 and the last 16 bit 0, while the middle 10 bits, the values of 0-9, are from the 10 input lines 
	gate6: g47_keyboard_encoder port map (keys=>"00000000000000000000000000000000000000" & inputlines & "0000000000000000", ASCII_CODE=>midwaysignal);
	gate7: g47_7_segment_decoder port map (asci_code=>midwaysignal, segments=>outputlines);

end archaltera;
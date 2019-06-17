--
-- entity name:g47_VGA_Overlay
--
-- Copyright (C) 2016 Sadnan Saquif
--	Version 1.0
--	Author:	Sadnan Saquif Yijie Zhou
-- Date: November 14, 2016
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_logic_unsigned.all;

entity g47_VGA_Overlay is
port (pixel		: 	in std_logic; --selection line
		R_in_TG, G_in_TG, B_in_TG 	:	in std_logic_vector (3 downto 0);
		R_in_other, G_in_other, B_in_other	:	in std_logic_vector (3 downto 0);
		R, G, B	:	out std_logic_vector (3 downto 0)
		);
end g47_VGA_Overlay;


Architecture archvgao of g47_VGA_Overlay is

Begin	
	
	with pixel select
		R	<=	R_in_TG when '1',
				--"0000" when others;
				R_in_other when others;
				
	with pixel select	
		G	<=	G_in_TG when '1',
				--"0000" when others;
				G_in_other when others;
				
	with pixel select	
		B	<=	B_in_TG when '1',
				--"0000" when others;
				B_in_other when others;
	
	
--	process_output: process(R_in_TG, G_in_TG, B_in_TG, R_in_TP, B_in_TP, G_in_TP, pixel)
--	begin
--	case pixel is
--		when '1' => 		R	<=	R_in_TG;
--								G	<=	G_in_TG;
--								B	<=	B_in_TG;
--		when others =>		R	<=	R_in_TP;
--								G	<=	G_in_TP;
--								B	<=	B_in_TP;
--	end case;
--	end process;
End archvgao;


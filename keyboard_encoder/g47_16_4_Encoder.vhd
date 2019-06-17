Library IEEE;
use ieee.std_logic_1164.all;

entity g47_16_4_Encoder is
	port(BLOCK_COL : in std_logic_vector(15 downto 0);
		CODE : out std_logic_vector(3 downto 0);
		ERROR : out std_logic);
	end g47_16_4_Encoder;
	
	Architecture arch1 of g47_16_4_Encoder is
	
	begin 
	
		CODE <= 		"0000" when BLOCK_COL(0) = '1' else
						"0001" when BLOCK_COL(1) = '1' else
						"0010" when BLOCK_COL(2) = '1' else
						"0011" when BLOCK_COL(3) = '1' else
						"0100" when BLOCK_COL(4) = '1' else
						"0101" when BLOCK_COL(5) = '1' else
						"0110" when BLOCK_COL(6) = '1' else
						"0111" when BLOCK_COL(7) = '1' else
						"1000" when BLOCK_COL(8) = '1' else
						"1001" when BLOCK_COL(9) = '1' else
						"1010" when BLOCK_COL(10) = '1' else
						"1011" when BLOCK_COL(11) = '1' else
						"1100" when BLOCK_COL(12) = '1' else
						"1101" when BLOCK_COL(13) = '1' else
						"1110" when BLOCK_COL(14) = '1' else
						"1111" when BLOCK_COL(15) = '1' else
						"0000";
						
	ERROR <= '1' when BLOCK_COL = "0000000000000000" else
				'0' ;
	end  arch1;
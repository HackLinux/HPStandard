-- 
-- Copyright Technical University of Denmark. All rights reserved.
-- This file is part of the Yamp MIPS processor.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
-- 


--------------------------------------------------------------------------------
-- Execution stage.
--
-- Author: Martin Schoeberl (martin@jopdesign.com)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.yamp_types.all;

entity yamp_execute is
	port(
		clk   : in  std_logic;
		reset : in  std_logic;
		ena   : in  std_logic;
		din   : in  decex_type;
		dout  : out exmem_type);
end entity yamp_execute;

architecture rtl of yamp_execute is
	signal decex_reg : decex_type;
	signal exout     : exmem_type;

	signal op2 : std_logic_vector(31 downto 0);

begin
	-- Pipeline register, with an enable for stalling
	-- Reset to an inactive value (nop instruction)
	process(clk, reset)
	begin
		if reset = '1' then
			decex_reg.instr <= (others => '0');
		elsif rising_edge(clk) then
			if ena = '1' then
				decex_reg <= din;
			end if;
		end if;
	end process;

	exout.instr <= decex_reg.instr;

	exout.rdest.reg.regnr <= decex_reg.rdest.regnr;
	exout.rdest.wrena     <= decex_reg.rdest.wrena;

	process(decex_reg, op2)
	begin
		-- This might be better done in decode, but then we need two forwarding paths
		if decex_reg.sel_imm='1' then
			op2 <= decex_reg.immval;
		else
			op2 <= decex_reg.rt.val;
		end if;
		if decex_reg.sel_add='1' then
--			exout.rdest.reg.val <= std_logic_vector(unsigned(decex_reg.rs.val) + unsigned(op2));
			exout.rdest.reg.val <= std_logic_vector(unsigned(decex_reg.rs.val) + unsigned(op2) + unsigned(op2) + unsigned(op2) + unsigned(op2));
		else
			exout.rdest.reg.val <= (others => '0');
		end if;
	end process;

	dout <= exout;

end;
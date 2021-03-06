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
-- Type definitions for Yamp.
--
-- Author: Martin Schoeberl (martin@jopdesign.com)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package yamp_types is

	-- should this later go to a yamp_config package?
	constant DM_BITS : integer := 8;
	constant IM_BITS : integer := 9;

	-- A register read
	type reg_type is record
		regnr : std_logic_vector(4 downto 0);
		val   : std_logic_vector(31 downto 0);
	end record;

	-- destination register from decode
	type regdest_dec_type is record
		regnr : std_logic_vector(4 downto 0);
		wrena : std_logic;
	end record;

	-- write back for the destination register
	type regdest_type is record
		reg   : reg_type;
		wrena : std_logic;
	end record;

	-- Each pipeline stage has a single record output
	-- The output is the combinational output and
	-- is registered in the consuming stage
	type fedec_type is record
		instr : std_logic_vector(31 downto 0);
	end record;

	type decex_type is record
		instr     : std_logic_vector(31 downto 0);
		rs, rt    : reg_type;
		rdest     : regdest_dec_type;
		sa        : std_logic_vector(4 downto 0);
		immval    : std_logic_vector(31 downto 0);
		sel_imm   : std_logic;
		sel_add   : std_logic;
		sel_sub   : std_logic;
		sel_or    : std_logic;
		sel_and   : std_logic;
		sel_nor   : std_logic;
		sel_ldimm : std_logic;
	end record;

	type exmem_type is record
		instr : std_logic_vector(31 downto 0);
		rdest : regdest_type;
	end record;

	type memwb_type is record
		instr : std_logic_vector(31 downto 0);
		rdest : regdest_type;
	end record;

	type wb_type is record
		instr : std_logic_vector(31 downto 0);
		rdest : regdest_type;
	end record;

	-- Simple IO records for a start with a UART
	type io_out_type is record
		addr   : std_logic_vector(7 downto 0);
		rd     : std_logic;
		wr     : std_logic;
		wrdata : std_logic_vector(31 downto 0);
	end record;

	type io_in_type is record
		rddata : std_logic_vector(31 downto 0);
	end record;

end package;


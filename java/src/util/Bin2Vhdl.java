/*
   Copyright 2012 Martin Schoeberl <masca@imm.dtu.dk>,
                  Technical University of Denmark, DTU Informatics. 
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

      1. Redistributions of source code must retain the above copyright notice,
         this list of conditions and the following disclaimer.

      2. Redistributions in binary form must reproduce the above copyright
         notice, this list of conditions and the following disclaimer in the
         documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
   OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
   NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
   THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   The views and conclusions contained in the software and documentation are
   those of the authors and should not be interpreted as representing official
   policies, either expressed or implied, of the copyright holder.
 */

package util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedList;
import java.util.List;

/**
 * Small tool to generate a VHDL table from the binary.
 * 
 * @author martin
 *
 */
public class Bin2Vhdl {

	static final int ADDRBITS = 10;
	static final int DATABITS = 32;
	static final int ROM_LEN = 1 << ADDRBITS;

	String fname;
	String dstDir = "./";
	String srcDir = "./";

	public Bin2Vhdl(String[] args) {
		srcDir = System.getProperty("user.dir");
		dstDir = System.getProperty("user.dir");
		processOptions(args);
		if (!srcDir.endsWith(File.separator))
			srcDir += File.separator;
		if (!dstDir.endsWith(File.separator))
			dstDir += File.separator;
	}

	String bin(int val, int bits) {

		String s = "";
		for (int i = 0; i < bits; ++i) {
			s += (val & (1 << (bits - i - 1))) != 0 ? "1" : "0";
		}
		return s;
	}

	String getRomHeader() {

		String line = "--\n";
		line += "--\tyamp_rom.vhd\n";
		line += "--\n";
		line += "--\tgeneric VHDL version of ROM\n";
		line += "--\n";
		line += "--\t\tDONT edit this file!\n";
		line += "--\t\tgenerated by " + this.getClass().getName() + "\n";
		line += "--\n";
		line += "\n";
		line += "library ieee;\n";
		line += "use ieee.std_logic_1164.all;\n";
		line += "\n";
		line += "entity yamp_rom is\n";
		// line +=
		// "generic (width : integer; addr_width : integer);\t-- for compatibility\n";
		line += "port (\n";
		line += "    address : in std_logic_vector(" + (ADDRBITS - 1)
				+ " downto 0);\n";
		line += "    q : out std_logic_vector(" + (DATABITS - 1)
				+ " downto 0)\n";
		line += ");\n";
		line += "end yamp_rom;\n";
		line += "\n";
		line += "architecture rtl of yamp_rom is\n";
		line += "\n";
		line += "begin\n";
		line += "\n";
		line += "process(address) begin\n";
		line += "\n";
		line += "case address is\n";

		return line;
	}

	String getRomFeet() {

		String line = "\n";
		line += "    when others => q <= \"" + bin(0, DATABITS) + "\";\n";
		line += "end case;\n";
		line += "end process;\n";
		line += "\n";
		line += "end rtl;\n";

		return line;
	}

	public void dump(List list) {

		try {

			FileWriter romvhd = new FileWriter(dstDir + "yamp_rom.vhd");
			romvhd.write(getRomHeader());

			Object o[] = list.toArray();
			for (int i = 0; i < o.length; ++i) {
				int val = ((Integer) o[i]).intValue();
				romvhd.write("    when \"" + bin(i, ADDRBITS) + "\" => q <= \""
						+ bin(val, DATABITS) + "\";");
//				romvhd.write(" -- " + inraw.readLine() + "\n");
				romvhd.write("\n");

			}

			romvhd.write(getRomFeet());
			romvhd.close();

			// PrintStream rom_mem = new PrintStream(new FileOutputStream(dstDir
			// + "mem_rom.dat"));
			// for (int i=0; i<ROM_LEN; ++i) {
			// rom_mem.println(romData[i]+" ");
			// }
			// rom_mem.close();

		} catch (IOException e) {
			System.out.println(e.getMessage());
			System.exit(-1);
		}
	}

	private boolean processOptions(String clist[]) {
		boolean success = true;

		for (int i = 0; i < clist.length; i++) {
			if (clist[i].equals("-s")) {
				srcDir = clist[++i];
			} else if (clist[i].equals("-d")) {
				dstDir = clist[++i];
			} else {
				fname = clist[i];
			}
		}

		return success;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {

		if (args.length < 1) {
			System.out.println("usage: java Bin2Vhdl [-s srcDir] [-d dstDir] filename");
			System.exit(-1);
		}
		Bin2Vhdl la = new Bin2Vhdl(args);

		// this is dumb code, but to lazy to write something more elaborate
		FileInputStream istr = new FileInputStream(la.srcDir + la.fname);
		List code = new LinkedList();
		byte data[] = new byte[4];
		// TODO: we need to check byte order for Patmos binaries.
		// I would argue for network order, which is not the x86 order
		while (istr.available()>=4) {
			istr.read(data);
			int val = ((((int) data[0]) & 0xff) << 24) +
					((((int) data[1]) & 0xff) << 16) +
					((((int) data[2]) & 0xff) << 8) +
					((((int) data[3]) & 0xff) << 0);
			code.add(new Integer(val));
			System.out.println(Integer.toHexString(val));
		}

		la.dump(code);
	}

}

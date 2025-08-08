package wdgrv_regs_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class wdcsr_reg_model extends rggen_ral_reg;
    rand rggen_ral_field wden;
    rand rggen_ral_field rvd1;
    rand rggen_ral_custom_field #("DEFAULT", "CLEAR_0", 0, 1) s1wto;
    rand rggen_ral_custom_field #("DEFAULT", "CLEAR_0", 0, 1) s2wto;
    rand rggen_ral_field wtocnt;
    rand rggen_ral_field rvd2;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(wden, 0, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rvd1, 1, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(s1wto, 2, 1, "CUSTOM", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(s2wto, 3, 1, "CUSTOM", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(wtocnt, 4, 10, "RW", 0, 10'h3ff, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rvd2, 14, 18, "RO", 1, 18'h00000, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class wdcnt_reg_model extends rggen_ral_reg;
    rand rggen_ral_field cnt;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(cnt, 0, 32, "RO", 1, 32'h00000000, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class wdgrv_regs_block_model extends rggen_ral_block;
    rand wdcsr_reg_model wdcsr;
    rand wdcnt_reg_model wdcnt;
    function new(string name);
      super.new(name, 4, 0);
    endfunction
    function void build();
      `rggen_ral_create_reg(wdcsr, '{}, '{}, 3'h0, "RW", "g_wdcsr.u_register")
      `rggen_ral_create_reg(wdcnt, '{}, '{}, 3'h4, "RO", "g_wdcnt.u_register")
    endfunction
  endclass
endpackage

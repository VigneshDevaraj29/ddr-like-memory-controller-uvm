`ifndef MEM_PKG_SV
`define MEM_PKG_SV

package mem_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

`include "agent/mem_seq_item.sv"
`include "agent/mem_sequencer.sv"
`include "agent/mem_driver.sv"
`include "agent/mem_monitor.sv"
`include "agent/mem_agent.sv"
`include "env/mem_scoreboard.sv"
`include "env/mem_coverage.sv"
`include "env/mem_env.sv"
`include "sequences/mem_basic_seq.sv"
`include "sequences/mem_write_read_seq.sv"
`include "sequences/mem_reset_seq.sv"
`include "sequences/mem_burst_stress_seq.sv"
`include "tests/mem_base_test.sv"
`include "tests/mem_write_read_test.sv"
`include "tests/mem_reset_test.sv"
`include "tests/mem_burst_stress_test.sv"

endpackage

`endif
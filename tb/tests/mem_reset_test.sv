`ifndef MEM_RESET_TEST_SV
`define MEM_RESET_TEST_SV

class mem_reset_test extends mem_base_test;

  `uvm_component_utils(mem_reset_test)

  mem_reset_seq seq;

  function new(string name = "mem_reset_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task apply_mid_reset();
    `uvm_info("MEM_RESET_TEST", "Applying mid-test reset", UVM_LOW)

    vif.valid     <= 0;
    vif.write_en  <= 0;
    vif.addr      <= 0;
    vif.wdata     <= 0;
    vif.bank      <= 0;
    vif.burst_len <= 0;

    env.scoreboard.reset_model();

    vif.rst_n <= 0;
    repeat (3) @(posedge vif.clk);
    vif.rst_n <= 1;
    repeat (2) @(posedge vif.clk);

    `uvm_info("MEM_RESET_TEST", "Mid-test reset completed", UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("MEM_RESET_TEST", "Starting reset stress test", UVM_LOW)

    seq = mem_reset_seq::type_id::create("seq_before_reset");
    seq.start(env.agent.sequencer);

    repeat (5) @(posedge vif.clk);

    apply_mid_reset();

    seq = mem_reset_seq::type_id::create("seq_after_reset");
    seq.start(env.agent.sequencer);

    #50;

    `uvm_info("MEM_RESET_TEST", "Finished reset stress test", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass

`endif
`ifndef MEM_BURST_STRESS_TEST_SV
`define MEM_BURST_STRESS_TEST_SV

class mem_burst_stress_test extends mem_base_test;

  `uvm_component_utils(mem_burst_stress_test)

  mem_burst_stress_seq seq;

  function new(string name = "mem_burst_stress_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("MEM_BURST_STRESS_TEST", "Starting back-to-back burst stress test", UVM_LOW)

    seq = mem_burst_stress_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);

    #50;

    `uvm_info("MEM_BURST_STRESS_TEST", "Finished back-to-back burst stress test", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass

`endif
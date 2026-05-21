`ifndef MEM_WRITE_READ_TEST_SV
`define MEM_WRITE_READ_TEST_SV

class mem_write_read_test extends mem_base_test;

  `uvm_component_utils(mem_write_read_test)

  mem_write_read_seq seq;

  function new(string name = "mem_write_read_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("MEM_WRITE_READ_TEST", "Starting write-read test", UVM_LOW)

    seq = mem_write_read_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);

    #50;

    `uvm_info("MEM_WRITE_READ_TEST", "Finished write-read test", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass

`endif
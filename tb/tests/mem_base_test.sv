`ifndef MEM_BASE_TEST_SV
`define MEM_BASE_TEST_SV

class mem_base_test extends uvm_test;

  `uvm_component_utils(mem_base_test)

  mem_env env;
  virtual mem_if vif;

  function new(string name = "mem_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = mem_env::type_id::create("env", this);

    if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MEM_BASE_TEST", "Failed to get virtual interface")
    end
  endfunction

endclass

`endif
`ifndef MEM_DRIVER_SV
`define MEM_DRIVER_SV

class mem_driver extends uvm_driver #(mem_seq_item);

  `uvm_component_utils(mem_driver)

  virtual mem_if vif;

  function new(string name = "mem_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MEM_DRIVER", "Failed to get virtual interface")
    end
  endfunction

task run_phase(uvm_phase phase);
  mem_seq_item req;

  wait(vif.rst_n == 1'b1);

  forever begin
    seq_item_port.get_next_item(req);
    drive_item(req);
    seq_item_port.item_done();
  end
endtask

  task drive_item(mem_seq_item req);

  @(posedge vif.clk);

  wait(vif.ready == 1'b1);

  vif.valid     <= 1'b1;
  vif.write_en  <= req.write_en;
  vif.addr      <= req.addr;
  vif.wdata     <= req.wdata;
  vif.bank      <= req.bank;
  vif.burst_len <= req.burst_len;

  @(posedge vif.clk);

  vif.valid     <= 1'b0;
  vif.write_en  <= 1'b0;
  vif.addr      <= '0;
  vif.wdata     <= '0;
  vif.bank      <= '0;
  vif.burst_len <= '0;

  // Wait until burst transaction completes and DUT becomes ready again
  wait(vif.ready == 1'b1);

  // Add one clean idle cycle between transactions
  @(posedge vif.clk);

endtask

endclass

`endif
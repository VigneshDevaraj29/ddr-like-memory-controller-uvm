`ifndef MEM_MONITOR_SV
`define MEM_MONITOR_SV
class mem_monitor extends uvm_monitor;
  `uvm_component_utils(mem_monitor)
  virtual mem_if vif;
  uvm_analysis_port #(mem_seq_item) item_collected_port;
  function new(string name = "mem_monitor", uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MEM_MONITOR", "Failed to get virtual interface")
    end
  endfunction
  task run_phase(uvm_phase phase);
    mem_seq_item item;
    bit [1:0] beat_total;
    bit [7:0] base_addr;
    bit [31:0] base_wdata;
    bit [1:0] bank_q;
    bit [1:0] burst_q;
    bit write_q;
    forever begin
      @(posedge vif.clk);
      if (vif.valid && vif.ready) begin
        write_q    = vif.write_en;
        base_addr  = vif.addr;
        base_wdata = vif.wdata;
        bank_q     = vif.bank;
        burst_q    = vif.burst_len;
        beat_total = vif.burst_len;
        if (write_q) begin
          for (int i = 0; i <= beat_total; i++) begin
            item = mem_seq_item::type_id::create("item");
            item.write_en  = 1'b1;
            item.addr      = base_addr + i;
            item.wdata     = base_wdata;        
            item.bank      = bank_q;
            item.burst_len = burst_q;
            item.rdata     = 0;
            item_collected_port.write(item);
            `uvm_info("MEM_MONITOR",
                      $sformatf("Captured WRITE beat %0d: addr=%0h wdata=%0h bank=%0d burst_len=%0d",
                                i, item.addr, item.wdata, item.bank, item.burst_len),
                      UVM_MEDIUM)
          end
        end
        else begin
          for (int i = 0; i <= beat_total; i++) begin
            if (i == 0) begin
              #1;
            end
            else begin
              @(posedge vif.clk);
              #1;
            end
            if (vif.rvalid) begin
              item = mem_seq_item::type_id::create("item");
              item.write_en  = 1'b0;
              item.addr      = base_addr + i;
              item.wdata     = 0;
              item.bank      = bank_q;
              item.burst_len = burst_q;
              item.rdata     = vif.rdata;
              item_collected_port.write(item);
              `uvm_info("MEM_MONITOR",
                        $sformatf("Captured READ beat %0d: addr=%0h rdata=%0h bank=%0d burst_len=%0d",
                                  i, item.addr, item.rdata, item.bank, item.burst_len),
                        UVM_MEDIUM)
            end
          end
        end
      end
    end
  endtask
endclass
`endif
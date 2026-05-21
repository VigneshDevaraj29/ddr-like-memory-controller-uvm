`ifndef MEM_COVERAGE_SV
`define MEM_COVERAGE_SV

class mem_coverage extends uvm_subscriber #(mem_seq_item);

  `uvm_component_utils(mem_coverage)

  mem_seq_item item;

  covergroup mem_cg;

    option.per_instance = 1;

    cp_write_en: coverpoint item.write_en {
      bins read  = {0};
      bins write = {1};
    }

    cp_bank: coverpoint item.bank {
      bins bank0 = {0};
      bins bank1 = {1};
      bins bank2 = {2};
      bins bank3 = {3};
    }

    cp_burst_len: coverpoint item.burst_len {
      bins burst0 = {0};
      bins burst1 = {1};
      bins burst2 = {2};
      bins burst3 = {3};
    }

    cp_addr_range: coverpoint item.addr {
      bins low  = {[8'h00:8'h3F]};
      bins mid  = {[8'h40:8'hBF]};
      bins high = {[8'hC0:8'hFF]};
    }

    rw_bank_cross: cross cp_write_en, cp_bank;

  endgroup

  function new(string name = "mem_coverage", uvm_component parent);
    super.new(name, parent);
    mem_cg = new();
  endfunction

  function void write(mem_seq_item t);
    item = t;
    mem_cg.sample();

    `uvm_info("MEM_COVERAGE",
              $sformatf("Sampled coverage: write_en=%0d addr=%0h bank=%0d burst_len=%0d",
                        item.write_en, item.addr, item.bank, item.burst_len),
              UVM_MEDIUM)
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("MEM_COVERAGE",
              $sformatf("Functional Coverage = %0.2f%%", mem_cg.get_coverage()),
              UVM_LOW)
  endfunction

endclass

`endif
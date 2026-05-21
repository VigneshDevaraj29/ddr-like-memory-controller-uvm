`ifndef MEM_SCOREBOARD_SV
`define MEM_SCOREBOARD_SV

class mem_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(mem_scoreboard)

  uvm_analysis_imp #(mem_seq_item, mem_scoreboard) item_collected_export;

  bit [31:0] exp_mem [bit [9:0]];

  function new(string name = "mem_scoreboard", uvm_component parent);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);
  endfunction

  function bit [9:0] get_key(bit [1:0] bank, bit [7:0] addr);
    return {bank, addr};
  endfunction

  function void write(mem_seq_item item);
    bit [9:0] key;

    key = get_key(item.bank, item.addr);

    if (item.write_en) begin
      exp_mem[key] = item.wdata;

      `uvm_info("MEM_SCOREBOARD",
                $sformatf("WRITE stored: bank=%0d addr=%0h data=%0h",
                          item.bank, item.addr, item.wdata),
                UVM_MEDIUM)
    end
    else begin
      if (exp_mem.exists(key)) begin
        if (item.rdata == exp_mem[key]) begin
          `uvm_info("MEM_SCOREBOARD",
                    $sformatf("READ PASS: bank=%0d addr=%0h expected=%0h actual=%0h",
                              item.bank, item.addr, exp_mem[key], item.rdata),
                    UVM_MEDIUM)
        end
        else begin
          `uvm_error("MEM_SCOREBOARD",
                     $sformatf("READ FAIL: bank=%0d addr=%0h expected=%0h actual=%0h",
                               item.bank, item.addr, exp_mem[key], item.rdata))
        end
      end
      else begin
        `uvm_info("MEM_SCOREBOARD",
                  $sformatf("READ from unwritten location: bank=%0d addr=%0h actual=%0h",
                            item.bank, item.addr, item.rdata),
                  UVM_LOW)
      end
    end
  endfunction

  function void reset_model();
    exp_mem.delete();
    `uvm_info("MEM_SCOREBOARD", "Scoreboard expected memory cleared due to reset", UVM_LOW)
  endfunction

endclass

`endif
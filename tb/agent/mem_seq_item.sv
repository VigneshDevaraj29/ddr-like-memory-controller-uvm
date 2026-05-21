`ifndef MEM_SEQ_ITEM_SV
`define MEM_SEQ_ITEM_SV

class mem_seq_item extends uvm_sequence_item;

  rand bit        write_en;
  rand bit [7:0]  addr;
  rand bit [31:0] wdata;
  rand bit [1:0]  bank;
  rand bit [1:0]  burst_len;

       bit [31:0] rdata;

  `uvm_object_utils_begin(mem_seq_item)
    `uvm_field_int(write_en,  UVM_ALL_ON)
    `uvm_field_int(addr,      UVM_ALL_ON)
    `uvm_field_int(wdata,     UVM_ALL_ON)
    `uvm_field_int(bank,      UVM_ALL_ON)
    `uvm_field_int(burst_len, UVM_ALL_ON)
    `uvm_field_int(rdata,     UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "mem_seq_item");
    super.new(name);
  endfunction

  constraint burst_len_c {
    burst_len inside {[0:3]};
  }

endclass

`endif
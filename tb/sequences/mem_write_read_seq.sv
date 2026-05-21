`ifndef MEM_WRITE_READ_SEQ_SV
`define MEM_WRITE_READ_SEQ_SV

class mem_write_read_seq extends uvm_sequence #(mem_seq_item);

  `uvm_object_utils(mem_write_read_seq)

  function new(string name = "mem_write_read_seq");
    super.new(name);
  endfunction

  task body();
    mem_seq_item req;
    bit [7:0]  addr_q;
    bit [31:0] data_q;
    bit [1:0]  bank_q;
    bit [1:0]  burst_q;

    repeat (25) begin

      burst_q = $urandom_range(0, 3);
      addr_q  = $urandom_range(0, 255 - burst_q);
      data_q  = $urandom();
      bank_q  = $urandom_range(0, 3);

      // WRITE transaction
      req = mem_seq_item::type_id::create("write_req");
      start_item(req);
      req.write_en  = 1'b1;
      req.addr      = addr_q;
      req.wdata     = data_q;
      req.bank      = bank_q;
      req.burst_len = burst_q;
      finish_item(req);

      `uvm_info("MEM_WRITE_READ_SEQ",
                $sformatf("WRITE generated: bank=%0d addr=%0h data=%0h burst_len=%0d",
                          bank_q, addr_q, data_q, burst_q),
                UVM_MEDIUM)

      // READ transaction from same location
      req = mem_seq_item::type_id::create("read_req");
      start_item(req);
      req.write_en  = 1'b0;
      req.addr      = addr_q;
      req.wdata     = 32'h0;
      req.bank      = bank_q;
      req.burst_len = burst_q;
      finish_item(req);

      `uvm_info("MEM_WRITE_READ_SEQ",
                $sformatf("READ generated: bank=%0d addr=%0h burst_len=%0d",
                          bank_q, addr_q, burst_q),
                UVM_MEDIUM)
    end
  endtask

endclass

`endif
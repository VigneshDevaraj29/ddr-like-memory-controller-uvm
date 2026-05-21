`ifndef MEM_BASIC_SEQ_SV
`define MEM_BASIC_SEQ_SV

class mem_basic_seq extends uvm_sequence #(mem_seq_item);

  `uvm_object_utils(mem_basic_seq)

  function new(string name = "mem_basic_seq");
    super.new(name);
  endfunction

  task body();
    mem_seq_item req;

    repeat (10) begin
      req = mem_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize()) begin
        `uvm_error("MEM_BASIC_SEQ", "Randomization failed")
      end

      finish_item(req);

      `uvm_info("MEM_BASIC_SEQ",
                $sformatf("Generated transaction: write_en=%0d addr=%0h wdata=%0h bank=%0d burst_len=%0d",
                          req.write_en, req.addr, req.wdata, req.bank, req.burst_len),
                UVM_MEDIUM)
    end
  endtask

endclass

`endif
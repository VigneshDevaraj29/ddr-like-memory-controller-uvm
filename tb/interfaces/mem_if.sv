interface mem_if #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32,
  parameter BANK_WIDTH = 2
)(
  input  logic clk
);
  logic                     rst_n;
  logic                     valid;
  logic                     ready;
  logic                     write_en;
  logic [ADDR_WIDTH-1:0]    addr;
  logic [DATA_WIDTH-1:0]    wdata;
  logic [1:0]               burst_len;
  logic [BANK_WIDTH-1:0]    bank;
  logic [DATA_WIDTH-1:0]    rdata;
  logic                     rvalid;

  // Assertion 1: valid should never be unknown after reset
  property valid_not_unknown_p;
    @(posedge clk) disable iff (!rst_n)
      !$isunknown(valid);
  endproperty

  assert property (valid_not_unknown_p)
    else $error("ASSERTION FAILED: valid is unknown");

  // Assertion 2: ready should never be unknown after reset
  property ready_not_unknown_p;
    @(posedge clk) disable iff (!rst_n)
      !$isunknown(ready);
  endproperty

  assert property (ready_not_unknown_p)
    else $error("ASSERTION FAILED: ready is unknown");

  // Assertion 3: rvalid should be low during reset
  property no_rvalid_during_reset_p;
    @(posedge clk)
      !rst_n |-> !rvalid;
  endproperty

  assert property (no_rvalid_during_reset_p)
    else $error("ASSERTION FAILED: rvalid is high during reset");

  // Assertion 4: when valid is high, address should not be unknown
  property addr_known_when_valid_p;
    @(posedge clk) disable iff (!rst_n)
      valid |-> !$isunknown(addr);
  endproperty

  assert property (addr_known_when_valid_p)
    else $error("ASSERTION FAILED: addr is unknown when valid is high");

  // Assertion 5: when valid is high, bank should not be unknown
  property bank_known_when_valid_p;
    @(posedge clk) disable iff (!rst_n)
      valid |-> !$isunknown(bank);
  endproperty

  assert property (bank_known_when_valid_p)
    else $error("ASSERTION FAILED: bank is unknown when valid is high");

  // Assertion 6: read transaction should produce rvalid in next cycle
  property read_gets_rvalid_p;
    @(posedge clk) disable iff (!rst_n)
      (valid && ready && !write_en) |=> rvalid;
  endproperty

  assert property (read_gets_rvalid_p)
    else $error("ASSERTION FAILED: read did not produce rvalid in next cycle");

endinterface
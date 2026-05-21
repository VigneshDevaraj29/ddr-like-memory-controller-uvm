module top_tb;

  import uvm_pkg::*;
  import mem_pkg::*;

  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 32;
  parameter BANK_WIDTH = 2;
  parameter DEPTH      = 256;

  logic clk;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

initial begin
  vif.rst_n = 0;
  #20;
  vif.rst_n = 1;
end

  mem_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .BANK_WIDTH(BANK_WIDTH)
  ) vif (
    .clk(clk)
  );

  ddr_like_mem_ctrl #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .BANK_WIDTH(BANK_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk       (clk),
    .rst_n     (vif.rst_n),
    .valid     (vif.valid),
    .ready     (vif.ready),
    .write_en  (vif.write_en),
    .addr      (vif.addr),
    .wdata     (vif.wdata),
    .burst_len (vif.burst_len),
    .bank      (vif.bank),
    .rdata     (vif.rdata),
    .rvalid    (vif.rvalid)
  );

  initial begin
    vif.valid     = 0;
    vif.write_en  = 0;
    vif.addr      = 0;
    vif.wdata     = 0;
    vif.burst_len = 0;
    vif.bank      = 0;
  end

  initial begin
    uvm_config_db#(virtual mem_if)::set(null, "*", "vif", vif);
    run_test("mem_base_test");
  end

endmodule
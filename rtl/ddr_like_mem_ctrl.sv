module ddr_like_mem_ctrl #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32,
  parameter BANK_WIDTH = 2,
  parameter DEPTH      = 256
)(
  input  logic                     clk,
  input  logic                     rst_n,

  input  logic                     valid,
  output logic                     ready,

  input  logic                     write_en,
  input  logic [ADDR_WIDTH-1:0]    addr,
  input  logic [DATA_WIDTH-1:0]    wdata,
  input  logic [1:0]               burst_len,
  input  logic [BANK_WIDTH-1:0]    bank,

  output logic [DATA_WIDTH-1:0]    rdata,
  output logic                     rvalid
);

  logic [DATA_WIDTH-1:0] mem [0:(1 << BANK_WIDTH)-1][0:DEPTH-1];

  typedef enum logic [1:0] {
    IDLE,
    WRITE_BURST,
    READ_BURST
  } state_t;

  state_t state;

  logic [ADDR_WIDTH-1:0] base_addr;
  logic [BANK_WIDTH-1:0] bank_reg;
  logic [DATA_WIDTH-1:0] wdata_reg;
  logic [1:0]            burst_len_reg;
  logic [1:0]            beat_count;

  assign ready = (state == IDLE);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state         <= IDLE;
      rdata         <= '0;
      rvalid        <= 1'b0;
      base_addr     <= '0;
      bank_reg      <= '0;
      wdata_reg     <= '0;
      burst_len_reg <= '0;
      beat_count    <= '0;
    end
    else begin
      rvalid <= 1'b0;

      case (state)

        IDLE: begin
          if (valid && ready) begin
            base_addr     <= addr;
            bank_reg      <= bank;
            wdata_reg     <= wdata;
            burst_len_reg <= burst_len;
            beat_count    <= 0;

            if (write_en) begin
              mem[bank][addr] <= wdata;

              if (burst_len == 0)
                state <= IDLE;
              else
                state <= WRITE_BURST;
            end
            else begin
              rdata  <= mem[bank][addr];
              rvalid <= 1'b1;

              if (burst_len == 0)
                state <= IDLE;
              else
                state <= READ_BURST;
            end
          end
        end

        WRITE_BURST: begin
          beat_count <= beat_count + 1;
          mem[bank_reg][base_addr + beat_count + 1] <= wdata_reg;  
          if (beat_count >= burst_len_reg - 1) begin               
            state      <= IDLE;
            beat_count <= '0;                                       
          end
        end

        READ_BURST: begin
          beat_count <= beat_count + 1;
          rdata  <= mem[bank_reg][base_addr + beat_count + 1];
          rvalid <= 1'b1;
          if (beat_count >= burst_len_reg - 1) begin               
            state      <= IDLE;
            beat_count <= '0;                                       
          end
        end

        default: begin
          state <= IDLE;
        end

      endcase
    end
  end

// =============================================
  // ASSERTIONS
  // =============================================

  // 1. ready must only be asserted in IDLE state
  property p_ready_only_in_idle;
    @(posedge clk) disable iff (!rst_n)
    ready |-> (state == IDLE);
  endproperty
  assert property (p_ready_only_in_idle)
    else $error("ASSERT: ready asserted outside IDLE state");

  // 2. rvalid must never be asserted during reset
  property p_no_rvalid_during_reset;
    @(posedge clk)
    (!rst_n) |-> (!rvalid);
  endproperty
  assert property (p_no_rvalid_during_reset)
    else $error("ASSERT: rvalid asserted during reset");

  // 3. valid must never be X or Z
  property p_valid_known;
    @(posedge clk) disable iff (!rst_n)
    !$isunknown(valid);
  endproperty
  assert property (p_valid_known)
    else $error("ASSERT: valid is X or Z");

  // 4. addr must be known during a valid transaction
  property p_addr_known_when_valid;
    @(posedge clk) disable iff (!rst_n)
    (valid && ready) |-> !$isunknown(addr);
  endproperty
  assert property (p_addr_known_when_valid)
    else $error("ASSERT: addr is X or Z during valid transaction");

  // 5. every read command must eventually produce rvalid
  //    ##[0:10] covers same-cycle rvalid for single-word reads
  //    and delayed rvalid for burst reads
  property p_read_gets_rvalid;
    @(posedge clk) disable iff (!rst_n)
    (valid && ready && !write_en) |-> ##[0:10] rvalid;
  endproperty
  assert property (p_read_gets_rvalid)
    else $error("ASSERT: rvalid never came after read command");

  // 6. burst_len must be within valid range 0-3
  property p_valid_burst_len;
    @(posedge clk) disable iff (!rst_n)
    (valid && ready) |-> (burst_len inside {[0:3]});
  endproperty
  assert property (p_valid_burst_len)
    else $error("ASSERT: burst_len out of valid range");

endmodule

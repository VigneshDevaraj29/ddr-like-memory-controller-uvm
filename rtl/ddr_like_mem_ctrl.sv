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

          mem[bank_reg][base_addr + beat_count + 1] <= wdata_reg + beat_count + 1;

          if (beat_count + 1 == burst_len_reg) begin
            state <= IDLE;
          end
        end

        READ_BURST: begin
          beat_count <= beat_count + 1;

          rdata  <= mem[bank_reg][base_addr + beat_count + 1];
          rvalid <= 1'b1;

          if (beat_count + 1 == burst_len_reg) begin
            state <= IDLE;
          end
        end

        default: begin
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
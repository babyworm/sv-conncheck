// latch_sram_tp.sv — legitimate single-clock two-port SRAM (1W1R).
// MUST be CLEAN under --check-synth. `mem` is variable-index written
// (`mem[i_waddr] <= i_wdata`) but read only through a REGISTERED port
// (`o_rdata <= mem[i_raddr]` inside an always_ff), never combinationally.
// The discriminator (no combinational multi-read) keeps this RAM clean.
// Trimmed self-contained copy of rtl/common/sram_tp.sv.
module latch_sram_tp #(
  parameter  int unsigned DEPTH    = 256,
  parameter  int unsigned WIDTH    = 128,
  localparam int unsigned L_ADDR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH)
) (
  input  logic                 clk,
  input  logic                 i_wen,
  input  logic [L_ADDR_W-1:0]  i_waddr,
  input  logic [WIDTH-1:0]     i_wdata,
  input  logic                 i_ren,
  input  logic [L_ADDR_W-1:0]  i_raddr,
  output logic [WIDTH-1:0]     o_rdata     // 1-cycle latency
);
  logic [WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin
    if (i_wen) mem[i_waddr] <= i_wdata;
  end

  always_ff @(posedge clk) begin
    if (i_ren) o_rdata <= mem[i_raddr];   // registered read, NOT combinational
  end
endmodule

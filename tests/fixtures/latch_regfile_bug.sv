// latch_regfile_bug.sv — register-file misused as a variable-address memory.
// MUST be FLAGGED by --check-synth: the clocked block writes only the
// variable-index diagonal element of `px` each cycle (partial write) while
// `px` is read combinationally at every index, so DC infers a latch/memory
// (ELAB-978). Self-contained; no package dependency.
module latch_regfile_bug (input logic clk, rst_n, input logic [6:0] diag,
  input logic signed [8:0] res_in, output logic [2047:0] o_px);
  logic [7:0] px [0:7][0:63];
  // BUG: only the diagonal element written each cycle, variable index, conditional
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) for (int y=0;y<8;y++) for (int x=0;x<64;x++) px[y][x] <= '0;
    else for (int y=0;y<8;y++)
      if ((int'(diag) >= y) && ((int'(diag)-y) < 64))
        px[y][6'(int'(diag)-y)] <= px[y][0] + 8'(res_in);   // variable-index partial write
  end
  always_comb begin                                          // combinational MULTI-read -> reg-file
    for (int y=0;y<8;y++) for (int x=0;x<64;x++)
      o_px[(y*64+x)*8 +: 8] = px[y][x];
  end
endmodule

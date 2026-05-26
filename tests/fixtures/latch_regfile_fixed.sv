// latch_regfile_fixed.sv — the corrected register file (full next-state).
// MUST be CLEAN under --check-synth. Same design intent as
// latch_regfile_bug.sv, but the clocked block now drives the FULL next
// state every cycle (`px[y][x] <= px_n[y][x]` over all elements), so the
// array synthesizes as a plain flop register-file, not a latch/memory.
// The variable-index diagonal overwrite lives in combinational `px_n`,
// which is not a clocked write. Modeled on rtl/fbd/fbd_med_wavefront.sv.
module latch_regfile_fixed (input logic clk, rst_n, input logic [6:0] diag,
  input logic signed [8:0] res_in, output logic [2047:0] o_px);
  logic [7:0] px   [0:7][0:63];
  logic [7:0] px_n [0:7][0:63];

  // combinational read fan-out (whole array)
  always_comb begin
    for (int y=0;y<8;y++) for (int x=0;x<64;x++)
      o_px[(y*64+x)*8 +: 8] = px[y][x];
  end

  // combinational next-state: default-hold ALL, then overwrite the diagonal.
  always_comb begin
    for (int y=0;y<8;y++) for (int x=0;x<64;x++)
      px_n[y][x] = px[y][x];                                 // default: hold
    for (int y=0;y<8;y++)
      if ((int'(diag) >= y) && ((int'(diag)-y) < 64))
        px_n[y][6'(int'(diag)-y)] = px[y][0] + 8'(res_in);   // overwrite (combinational, not clocked)
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) for (int y=0;y<8;y++) for (int x=0;x<64;x++) px[y][x] <= '0;
    else        for (int y=0;y<8;y++) for (int x=0;x<64;x++) px[y][x] <= px_n[y][x]; // FULL next-state
  end
endmodule

// latch_incomplete_comb.sv — secondary rule: incomplete always_comb -> latch.
// `y_latch` is assigned only inside an `if (en)` with no else and no
// unconditional default, then read -> the synthesizer infers a latch (WARN).
// `y_ok` has a default-then-override and `y_full` has a complete if/else, so
// both stay clean. Self-contained.
module latch_incomplete_comb (
  input  logic       en,
  input  logic [7:0] a,
  output logic [7:0] y_latch,
  output logic [7:0] y_ok,
  output logic [7:0] y_full
);
  // BUG: no else, no default -> y_latch holds its value when !en -> latch.
  always_comb begin
    if (en)
      y_latch = a;
  end

  // OK: unconditional default first, then conditional override.
  always_comb begin
    y_ok = '0;
    if (en)
      y_ok = a;
  end

  // OK: complete if/else covers every path.
  always_comb begin
    if (en)
      y_full = a;
    else
      y_full = '0;
  end
endmodule

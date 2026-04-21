module tb();

  reg [3:0] a, b;
  reg cin;

  wire [3:0] sum;
  wire cout;

  reg [4:0] expected;

  integer i, j, k;
  integer pass_count = 0;
  integer fail_count = 0;

  top uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  initial begin
$dumpfile("ripple_adder.vcd");
$dumpvars(0, tb);
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        for (k = 0; k < 2; k = k + 1) begin

          // apply inputs
          a = i;
          b = j;
          cin = k;

          #10;

          // expected result
          expected = a + b + cin;

          // check
          if ({cout, sum} != expected) begin
            fail_count = fail_count + 1;
            $display("ERROR: a=%0d b=%0d cin=%0d | sum=%0d cout=%0d | expected=%0d",
                      a, b, cin, sum, cout, expected);
          end else begin
            pass_count = pass_count + 1;
          end

        end
      end
    end

    // summary
    $display("================================");
    $display("SIMULATION COMPLETE");
    $display("PASS = %0d", pass_count);
    $display("FAIL = %0d", fail_count);
    $display("================================");

    $finish;

  end

endmodule

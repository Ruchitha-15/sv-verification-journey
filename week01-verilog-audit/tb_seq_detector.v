module tb_seq_detector();
    reg clk, rst, in;
    wire detected;
    // instantiate DUT
    seq_detector_1011 uut (
        .clk(clk),
        .rst(rst),
        .in(in),
        .detected(detected)
    );
    // clock generation
    always #5 clk = ~clk;
    initial begin
        $dumpfile("seq_detector.vcd");
        $dumpvars(0, tb_seq_detector);
        // initialise
        clk = 0; rst = 1; in = 0;
        #10 rst = 0;
        // Test 1: apply sequence 1,0,1,1 — detected must go high
        // Test 1: send 1,0,1,1
in = 1; #10;   // clock edge 1 — S1
in = 0; #10;   // clock edge 2 — S10
in = 1; #10;   // clock edge 3 — S101
in = 1; #10;   // clock edge 4 — S1011, detected = 1
check(1);       // verify detected is high
     
        // Test 2: overlapping — 1,0,1,1,0,1,1
// first detection already happened above
// continue from where Test 1 left off
in = 0; #10;   // bit 5
in = 1; #10;   // bit 6
in = 1; #10;   // bit 7 — detected again
check(1);
        
        // Test 3: wrong sequence 1,0,1,0 — no detection
rst = 1; #10; rst = 0;
in = 1; #10;
in = 0; #10;
in = 1; #10;
in = 0; #10;
check(0);
        #10 $finish;
    end
    // self-checker
    task check(input exp);
        #1;
        if (detected !== exp)
            $display("FAIL at time %0t | in=%b | detected=%b | expected=%b",
                      $time, in, detected, exp);
        else
            $display("PASS at time %0t | detected=%b", $time, detected);
    endtask
endmodule

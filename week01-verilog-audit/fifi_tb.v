module fifo_tb();
    reg        clk, rst, wr_en, rd_en;
    reg  [7:0] din;
    wire [7:0] dout;
    wire       full, empty;

    sync_fifo uut (
        .clk  (clk),
        .rst  (rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din  (din),
        .dout (dout),
        .full (full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_tb);
        clk=0; rst=1; wr_en=0; rd_en=0; din=0;
        #10 rst=0;

        // Test 1: normal write then read
        write_fifo(8'hAA);
        write_fifo(8'hBB);
        write_fifo(8'hCC);
        write_fifo(8'hDD);
        read_fifo(8'hAA);
        read_fifo(8'hBB);
        read_fifo(8'hCC);
        read_fifo(8'hDD);
        $display("--- Test 1 complete ---");

        // Test 2: fill to full
        write_fifo(8'hAA);
        write_fifo(8'hBB);
        write_fifo(8'hCC);
        write_fifo(8'hDD);
        write_fifo(8'hEE);
        write_fifo(8'hFF);
        write_fifo(8'h11);
        if (full)
            $display("PASS: full flag correct after 7 writes");
        else
            $display("FAIL: full flag not asserted");
        read_fifo(8'hAA);
        read_fifo(8'hBB);
        read_fifo(8'hCC);
        read_fifo(8'hDD);
        read_fifo(8'hEE);
        read_fifo(8'hFF);
        read_fifo(8'h11);
        $display("--- Test 2 complete ---");

        // Test 3: overflow protection
        write_fifo(8'hAA);
        write_fifo(8'hBB);
        write_fifo(8'hCC);
        write_fifo(8'hDD);
        write_fifo(8'hEE);
        write_fifo(8'hFF);
        write_fifo(8'h11);
        write_fifo(8'h22);  // overflow attempt — should be rejected
        read_fifo(8'hAA);
        read_fifo(8'hBB);
        read_fifo(8'hCC);
        read_fifo(8'hDD);
        read_fifo(8'hEE);
        read_fifo(8'hFF);
        read_fifo(8'h11);
        $display("--- Test 3 complete: no FAIL = overflow protected ---");

        // Test 4: underflow protection
        rst = 1; #10; rst = 0;
        if (empty)
            $display("PASS: empty flag correct after reset");
        else
            $display("FAIL: empty flag not asserted");
        rd_en = 1; @(posedge clk); rd_en = 0; #1;
        $display("INFO: dout after underflow attempt = %0h", dout);
        if (empty)
            $display("PASS: rd_ptr did not move on underflow attempt");
        else
            $display("FAIL: rd_ptr moved when FIFO was empty");
        $display("--- Test 4 complete ---");

        #10 $finish;
    end

    task write_fifo(input [7:0] data);
        @(posedge clk);
        wr_en = 1;
        din   = data;
        #1;
        if (full)
            $display("WARN: write attempted when full at time %0t", $time);
        @(posedge clk);
        wr_en = 0;
    endtask

    task read_fifo(input [7:0] expected);
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        #1;
        if (dout !== expected)
            $display("FAIL: dout=%0h expected=%0h at time %0t",
                      dout, expected, $time);
        else
            $display("PASS: dout=%0h correct", dout);
    endtask

endmodule

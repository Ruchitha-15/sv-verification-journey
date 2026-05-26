`timescale 1ns/1ps

class fifo_transaction;
    rand logic [7:0] data;
    rand logic        wr_en;
    rand logic        rd_en;

    constraint no_simultaneous_rw {
        !(wr_en == 1 && rd_en == 1);
    }
    constraint data_range {
        data inside {[8'h00 : 8'hFF]};
    }

    function void print();
        $display("data=%0h wr_en=%0b rd_en=%0b",
                  data, wr_en, rd_en);
    endfunction
endclass

module fifo_rand_tb;
    logic        clk, rst, wr_en, rd_en;
    logic [7:0]  din, dout;
    logic        full, empty;
    logic [7:0]  expected;
    logic [7:0]  scoreboard[$];

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
        $dumpfile("fifo_rand.vcd");
        $dumpvars(0, fifo_rand_tb);

        clk=0; rst=1; wr_en=0; rd_en=0; din=0;
        #10 rst=0;

        begin
            fifo_transaction tr = new();

            repeat(20) begin
                tr.randomize();

                @(posedge clk);
                wr_en = tr.wr_en;
                rd_en = tr.rd_en;
                din   = tr.data;
                #1;

                // write check
                if (wr_en && !full) begin
                    scoreboard.push_back(din);
                    $display("WRITE: data=%0h", din);
                end else if (wr_en && full) begin
                    $display("INFO: write skipped — FIFO full");
                end

                
               // read check — wait one extra cycle for dout to settle
if (rd_en && !empty) begin
    @(posedge clk);    // wait for FIFO to put data on dout
    #1;
    expected = scoreboard.pop_front();
    if (dout !== expected)
        $display("FAIL: got=%0h expected=%0h", dout, expected);
    else
        $display("PASS: dout=%0h correct", dout);
end

                tr.print();
            end
        end

        @(posedge clk);
        wr_en=0; rd_en=0;
        #10 $finish;
    end
endmodule

`timescale 1ns/1ps

interface fifo_if(input logic clk);
    logic        rst, wr_en, rd_en;
    logic [7:0]  din, dout;
    logic        full, empty;
endinterface

// Transaction class — carries data between components
class fifo_transaction;
    logic [7:0] data;
    logic        wr_en;
    logic        rd_en;
endclass

// Driver — drives transactions onto DUT
class fifo_driver;
    virtual fifo_if vif;
    mailbox #(fifo_transaction) mbx_in;  // receives transactions to drive

    function new(virtual fifo_if vif, mailbox #(fifo_transaction) mbx);
        this.vif    = vif;
        this.mbx_in = mbx;
    endfunction

    task run();
        fifo_transaction tr;
        forever begin
            mbx_in.get(tr);          // wait for transaction
            @(posedge vif.clk);
            vif.wr_en = tr.wr_en;
            vif.rd_en = tr.rd_en;
            vif.din   = tr.data;
            @(posedge vif.clk);
            vif.wr_en = 0;
            vif.rd_en = 0;
            #1;
            $display("DRIVER: wr=%0b rd=%0b data=%0h",
                      tr.wr_en, tr.rd_en, tr.data);
        end
    endtask
endclass

// Monitor — observes DUT outputs
class fifo_monitor;
    virtual fifo_if vif;
    mailbox #(fifo_transaction) mbx_out; // sends observed data to scoreboard

    function new(virtual fifo_if vif, mailbox #(fifo_transaction) mbx);
        this.vif     = vif;
        this.mbx_out = mbx;
    endfunction

    task run();
        fifo_transaction tr;
        forever begin
            @(posedge vif.clk);
            #1;
            if (vif.rd_en) begin
                tr = new();
                tr.data = vif.dout;
                mbx_out.put(tr);     // send to scoreboard
                $display("MONITOR: saw dout=%0h", tr.data);
            end
        end
    endtask
endclass

// Scoreboard — checks actual vs expected
class fifo_scoreboard;
    mailbox #(fifo_transaction) mbx_exp;  // expected from driver side
    mailbox #(fifo_transaction) mbx_act;  // actual from monitor

    function new(mailbox #(fifo_transaction) exp,
                 mailbox #(fifo_transaction) act);
        this.mbx_exp = exp;
        this.mbx_act = act;
    endfunction

    task run();
        fifo_transaction exp_tr, act_tr;
        forever begin
            mbx_exp.get(exp_tr);    // get expected
            mbx_act.get(act_tr);    // get actual
            if (act_tr.data !== exp_tr.data)
                $display("FAIL: got=%0h expected=%0h",
                          act_tr.data, exp_tr.data);
            else
                $display("PASS: data=%0h correct", act_tr.data);
        end
    endtask
endclass

module fifo_env_tb;
    logic clk;
    fifo_if dut_if(.clk(clk));

    sync_fifo uut (
        .clk  (dut_if.clk),
        .rst  (dut_if.rst),
        .wr_en(dut_if.wr_en),
        .rd_en(dut_if.rd_en),
        .din  (dut_if.din),
        .dout (dut_if.dout),
        .full (dut_if.full),
        .empty(dut_if.empty)
    );

    always #5 clk = ~clk;

    initial begin
        // mailboxes
        mailbox #(fifo_transaction) drv_mbx  = new();
        mailbox #(fifo_transaction) mon_mbx  = new();
        mailbox #(fifo_transaction) exp_mbx  = new();

        // components
        fifo_driver      drv = new(dut_if, drv_mbx);
        fifo_monitor     mon = new(dut_if, mon_mbx);
        fifo_scoreboard  scb = new(exp_mbx, mon_mbx);

        clk=0; dut_if.rst=1;
        dut_if.wr_en=0; dut_if.rd_en=0; dut_if.din=0;
        #10 dut_if.rst=0;

        // start driver, monitor, scoreboard in parallel
        fork
            drv.run();
            mon.run();
            scb.run();
        join_none

        // send write transactions
        begin
            fifo_transaction tr;

            tr = new(); tr.wr_en=1; tr.rd_en=0; tr.data=8'hAA;
            drv_mbx.put(tr);
            exp_mbx.put(tr);   // also tell scoreboard to expect AA

            tr = new(); tr.wr_en=1; tr.rd_en=0; tr.data=8'hBB;
            drv_mbx.put(tr);
            exp_mbx.put(tr);

            tr = new(); tr.wr_en=1; tr.rd_en=0; tr.data=8'hCC;
            drv_mbx.put(tr);
            exp_mbx.put(tr);

            // send read transactions
            tr = new(); tr.wr_en=0; tr.rd_en=1; tr.data=8'h00;
            drv_mbx.put(tr);

            tr = new(); tr.wr_en=0; tr.rd_en=1; tr.data=8'h00;
            drv_mbx.put(tr);

            tr = new(); tr.wr_en=0; tr.rd_en=1; tr.data=8'h00;
            drv_mbx.put(tr);
        end

        #200 $finish;
    end
endmodule

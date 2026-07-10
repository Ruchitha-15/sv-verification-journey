
`timescale 1ns/1ps

interface fifo_if(input logic clk);
    logic        rst;
    logic        wr_en;
    logic        rd_en;
    logic [7:0]  din;
    logic [7:0]  dout;
    logic        full;
    logic        empty;
endinterface

class fifo_driver;
    virtual fifo_if vif;

    function new(virtual fifo_if vif);
        this.vif = vif;
    endfunction

    task drive(logic wr, logic rd, logic [7:0] data);
        @(posedge vif.clk);
        vif.wr_en = wr;
        vif.rd_en = rd;
        vif.din   = data;
        @(posedge vif.clk);
vif.wr_en = 0;     // de-assert immediately
    vif.rd_en = 0;
        #1;
        $display("drove: wr=%0b rd=%0b data=%0h | full=%0b empty=%0b",
                  wr, rd, data, vif.full, vif.empty);
    endtask

endclass
class fifo_monitor;
    virtual fifo_if vif;

    function new(virtual fifo_if vif);
        this.vif = vif;
    endfunction

  task monitor(input logic is_read);
        @(posedge vif.clk);
        #1;
      if (is_read)
            $display("MONITOR: dout=%0h at time %0t",
                      vif.dout, $time);
    endtask

endclass

module fifo_vif_tb;
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
        fifo_driver drv;
      fifo_monitor mon;
        clk=0; dut_if.rst=1; dut_if.wr_en=0;
        dut_if.rd_en=0; dut_if.din=0;
        #10 dut_if.rst=0;

        drv = new(dut_if);
		mon = new(dut_if);

        drv.drive(1, 0, 8'hAA);
      mon.monitor(0);
        drv.drive(1, 0, 8'hBB);
      mon.monitor(0);
        drv.drive(1, 0, 8'hCC);
      mon.monitor(0);
        drv.drive(0, 1, 8'h00);
      mon.monitor(1);
        drv.drive(0, 1, 8'h00);
      mon.monitor(1);
      drv.drive(0, 1, 8'h00);
      mon.monitor(1);

        #10 $finish;
    end
endmodule

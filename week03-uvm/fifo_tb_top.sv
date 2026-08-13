
`timescale 1ns/1ps

// Interface
interface fifo_if(input logic clk);
    logic        rst, wr_en, rd_en;
    logic [7:0]  din, dout;
    logic        full, empty;
endinterface

// FIFO DUT
module sync_fifo (
    input  logic        clk,
    input  logic        rst,
    input  logic        wr_en,
    input  logic        rd_en,
    input  logic [7:0]  din,
    output logic [7:0]  dout,
    output logic        full,
    output logic        empty
);
    logic [7:0] mem [0:7];
    logic [2:0] wr_ptr, rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr + 1 == rd_ptr);

    always @(posedge clk) begin
        if (rst) wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr      <= wr_ptr + 1;
        end
    end

    always @(posedge clk) begin
        if (rst) rd_ptr <= 0;
        else if (rd_en && !empty) begin
            dout   <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end
endmodule

// UVM imports
import uvm_pkg::*;
`include "uvm_macros.svh" 
class fifo_seq_item extends uvm_sequence_item;

    `uvm_object_utils(fifo_seq_item)

    rand logic [7:0] data;
    rand logic        wr_en;
    rand logic        rd_en;

    constraint no_sim_rw {
        !(wr_en == 1 && rd_en == 1);
    }

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction

endclass
//DRIVER//

class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if)::get(
            this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        fifo_seq_item tr;
        forever begin
            seq_item_port.get_next_item(tr);
            @(posedge vif.clk);
            vif.wr_en = tr.wr_en;
            vif.rd_en = tr.rd_en;
            vif.din   = tr.data;
            @(posedge vif.clk);
            vif.wr_en = 0;
            vif.rd_en = 0;
            #1;
            `uvm_info("DRIVER",
                $sformatf("drove: wr=%0b rd=%0b data=%0h",
                tr.wr_en, tr.rd_en, tr.data), UVM_MEDIUM)
            seq_item_port.item_done();
        end
    endtask
endclass
//MONITOR//
class fifo_monitor extends uvm_monitor;

  `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;
  uvm_analysis_port #(fifo_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);  // create analysis port
        if(!uvm_config_db #(virtual fifo_if)::get(
            this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
    fifo_seq_item tr;
    forever begin
        @(posedge vif.clk);
        #1;
        if(vif.rd_en && !vif.empty) begin
            // rd_en is high NOW — wait one cycle for dout to settle
            @(posedge vif.clk);
            #1;
            tr      = new("mon_tr");
            tr.data = vif.dout;
            tr.wr_en = 0;
            tr.rd_en = 1;
            `uvm_info("MONITOR",
                $sformatf("saw dout=%0h", tr.data), UVM_MEDIUM)
            ap.write(tr);
        end
    end
endtask

endclass

//SCOREBOARD//
class fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fifo_scoreboard)

    // analysis imp — receives transactions from monitor
    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) mon_imp;

    // expected queue — same as your Week 2 scoreboard
    fifo_seq_item exp_queue[$];

    int pass_count = 0;
    int fail_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_imp = new("mon_imp", this);
    endfunction

    // write() — called automatically when monitor does ap.write()
    function void write(fifo_seq_item tr);
        fifo_seq_item exp_tr;

        if(exp_queue.size() == 0) begin
            `uvm_error("SCOREBOARD", "No expected transaction")
            return;
        end

        exp_tr = exp_queue.pop_front();

        if(tr.data !== exp_tr.data) begin
            fail_count++;
            `uvm_error("SCOREBOARD",
                $sformatf("FAIL: got=%0h expected=%0h",
                tr.data, exp_tr.data))
        end else begin
            pass_count++;
            `uvm_info("SCOREBOARD",
                $sformatf("PASS: data=%0h correct", tr.data),
                UVM_MEDIUM)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("RESULTS: PASS=%0d FAIL=%0d",
            pass_count, fail_count), UVM_NONE)
    endfunction

endclass
//SEQUENCER//
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    // handle to scoreboard — set by test before starting
    fifo_scoreboard scb;

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    task body();
        fifo_seq_item tr;

        // write 5 items
        repeat(5) begin
            tr = fifo_seq_item::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize() with {
                wr_en == 1; rd_en == 0;});
            finish_item(tr);
            // push expected data to scoreboard
            scb.exp_queue.push_back(tr);
            `uvm_info("SEQ",
                $sformatf("WROTE: data=%0h", tr.data),
                UVM_MEDIUM)
        end

        // read 5 items
        repeat(5) begin
            tr = fifo_seq_item::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize() with {
                wr_en == 0; rd_en == 1;});
            finish_item(tr);
        end
    endtask
endclass
//AGENT//
class fifo_agent extends uvm_agent;

    `uvm_component_utils(fifo_agent)

    fifo_driver                    drv;
    fifo_monitor                   mon;
    uvm_sequencer #(fifo_seq_item) seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv  = fifo_driver::type_id::create("drv", this);
        mon  = fifo_monitor::type_id::create("mon", this);
        seqr = uvm_sequencer#(fifo_seq_item)::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass
//ENVIRONMENT//
class fifo_env extends uvm_env;

    `uvm_component_utils(fifo_env)

    fifo_agent      agent;
    fifo_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = fifo_agent::type_id::create("agent", this);
        scb   = fifo_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.mon.ap.connect(scb.mon_imp);
    endfunction

endclass


//TESTBENCH//
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    fifo_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

   task run_phase(uvm_phase phase);
    fifo_sequence seq;
    phase.raise_objection(this);

    // reset DUT at start of run_phase
    env.agent.drv.vif.rst = 1;
    repeat(4) @(posedge env.agent.drv.vif.clk);
    env.agent.drv.vif.rst = 0;
    repeat(2) @(posedge env.agent.drv.vif.clk);

    // now start sequence
    seq     = fifo_sequence::type_id::create("seq");
    seq.scb = env.scb;
    seq.start(env.agent.seqr);

    phase.drop_objection(this);
endtask
endclass

module tb_top;
    logic clk;
    fifo_if dut_if(.clk(clk));

    sync_fifo dut (
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
    clk = 0;
    dut_if.rst  = 1;
    dut_if.wr_en = 0;
    dut_if.rd_en = 0;
    dut_if.din   = 0;

    uvm_config_db #(virtual fifo_if)::set(
        null, "uvm_test_top.*", "vif", dut_if);

    run_test("fifo_test");  // called at time 0 — no delays before this
end
endmodule

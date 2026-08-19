`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
//sequencer
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    // handle to scoreboard — set by test before starting
    fifo_scoreboard scb;

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    task body();
    fifo_seq_item tr;

    // write 2 items — low range
    repeat(2) begin
        tr = fifo_seq_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
            wr_en == 1; rd_en == 0;
            data inside {[8'h00:8'h3F]};});
        finish_item(tr);
        scb.exp_queue.push_back(tr);
        `uvm_info("SEQ",$sformatf("WROTE: data=%0h",tr.data),UVM_MEDIUM)
    end

    // write 3 items — mid range
    repeat(3) begin
        tr = fifo_seq_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
            wr_en == 1; rd_en == 0;
            data inside {[8'h40:8'hBF]};});
        finish_item(tr);
        scb.exp_queue.push_back(tr);
        `uvm_info("SEQ",$sformatf("WROTE: data=%0h",tr.data),UVM_MEDIUM)
    end

    // write 2 items — high range
    repeat(2) begin
        tr = fifo_seq_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
            wr_en == 1; rd_en == 0;
            data inside {[8'hC0:8'hFF]};});
        finish_item(tr);
        scb.exp_queue.push_back(tr);
        `uvm_info("SEQ",$sformatf("WROTE: data=%0h",tr.data),UVM_MEDIUM)
    end

    // read all 7 items back
    repeat(7) begin
        tr = fifo_seq_item::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize() with {
            wr_en == 0; rd_en == 1;});
        finish_item(tr);
    end
endtask
endclass

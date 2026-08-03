`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
//sequencer
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)
    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction
    task body();
        fifo_seq_item tr;
        repeat(10) begin
            tr = fifo_seq_item::type_id::create("tr");
            start_item(tr);
            tr.randomize();
            finish_item(tr);
        end
    endtask
endclass

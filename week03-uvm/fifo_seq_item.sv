// UVM sequence item for FIFO
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


**TESTBENCH**
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

module tb;

    initial begin
        fifo_seq_item item;
        item = new("my_item");

        repeat(5) begin
            item.randomize();
            $display("data=%0h wr_en=%0b rd_en=%0b",
                      item.data, item.wr_en, item.rd_en);
        end
    end

endmodule

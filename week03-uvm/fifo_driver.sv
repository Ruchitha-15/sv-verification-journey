`timescale 1ns/1ps

interface fifo_if(input logic clk);
    logic        rst, wr_en, rd_en;
    logic [7:0]  din, dout;
    logic        full, empty;
endinterface

import uvm_pkg::*;
`include "uvm_macros.svh"

// sequence item
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

// driver
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

`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
//monitor
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
                tr       = new("mon_tr");
                tr.data  = vif.dout;
                tr.wr_en = 0;
                tr.rd_en = 1;
                `uvm_info("MONITOR",
                    $sformatf("saw dout=%0h", tr.data), UVM_MEDIUM)
              ap.write(tr);  // broadcast to scoreboard
            end
        end
    endtask

endclass

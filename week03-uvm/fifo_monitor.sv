`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
//MONITOR//
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if vif;
    uvm_analysis_port #(fifo_seq_item) ap;
    fifo_seq_item tr;

    // covergroup
    covergroup fifo_cg;
        cp_data: coverpoint tr.data {
            bins low  = {[8'h00 : 8'h3F]};
            bins mid  = {[8'h40 : 8'hBF]};
            bins high = {[8'hC0 : 8'hFF]};
        }
        cp_wr_en: coverpoint tr.wr_en {
            bins write = {1};
            bins idle  = {0};
        }
        cp_rd_en: coverpoint tr.rd_en {
            bins read  = {1};
            bins idle  = {0};
        }
        cx_rw: cross cp_wr_en, cp_rd_en;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db #(virtual fifo_if)::get(
            this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
    forever begin
        @(posedge vif.clk);
        #1;
        // sample writes
        if(vif.wr_en && !vif.full) begin
            tr       = new("wr_tr");
            tr.data  = vif.din;
            tr.wr_en = vif.wr_en;
            tr.rd_en = vif.rd_en;
            fifo_cg.sample();
        end
        // sample reads
        if(vif.rd_en && !vif.empty) begin
            tr       = new("mon_tr");
            tr.data  = vif.dout;
            tr.wr_en = vif.wr_en;
            tr.rd_en = vif.rd_en;
            fifo_cg.sample();
            `uvm_info("MONITOR",
                $sformatf("saw dout=%0h", tr.data),
                UVM_MEDIUM)
            ap.write(tr);
        end
    end
endtask
function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("FUNCTIONAL COVERAGE = %0.2f%%", 
              fifo_cg.get_coverage());
    `uvm_info("COVERAGE",
        $sformatf("Functional coverage = %0.2f%%",
                  fifo_cg.get_coverage()), UVM_LOW)
endfunction
endclass

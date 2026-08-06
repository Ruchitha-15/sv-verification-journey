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

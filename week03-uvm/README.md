# Week 3 — UVM Verification Environment

Complete UVM testbench for synchronous FIFO.

## Files

| File | Description |
|------|-------------|
| `fifo_seq_item.sv` | UVM transaction — extends uvm_sequence_item |
| `fifo_uvm_driver.sv` | UVM driver — build_phase, run_phase |
| `fifo_uvm_monitor.sv` | UVM monitor — analysis port + covergroup |
| `fifo_sequence.sv` | UVM sequence — targeted data range constraints |
| `fifo_agent.sv` | UVM agent — driver, monitor, sequencer |
| `fifo_scoreboard.sv` | UVM scoreboard — analysis imp, report_phase |
| `fifo_env.sv` | UVM environment — agent + scoreboard |
| `fifo_test.sv` | UVM test — objection mechanism |
| `fifo_tb_top.sv` | Top level — DUT + assertions instance |
| `fifo_assertions.sv` | SVA assertions — protocol checking |

## Results
- Functional coverage: 87.50%
- Scoreboard: PASS=6 FAIL=0
- UVM errors: 0
- UVM fatals: 0
- Assertion failures: 0

## How to simulate
1. Go to edaplayground.com
2. Select Synopsys VCS + UVM 1.2
3. Paste design files in left pane
4. Paste tb_top in right pane
5. Add +UVM_TESTNAME=fifo_test to Run Options
6. Click Run

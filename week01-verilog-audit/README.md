# Week 1 — Verilog Audit & HDL Foundations

## What I built
Four complete Verilog designs with self-checking testbenches.

## Files

| File | Description | Concepts covered |
|------|-------------|-----------------|
| `ripple_adder.v` | 4-bit ripple carry adder using full adder instances | Module instantiation, generate |
| `tb_ripple_adder.v` | Exhaustive self-checking testbench — 512 combinations | Self-checking, pass/fail counting |
| `seq_detector_1011.v` | Moore FSM detecting sequence 1011 | 3-always style, state encoding |
| `tb_seq_detector.v` | Testbench with basic, overlap and wrong-sequence tests | Task-based checking, edge cases |
| `sync_fifo.v` | Synchronous FIFO depth-8 width-8 | Pointer arithmetic, full/empty flags |
| `fifo_tb.v` | Testbench covering normal, overflow, underflow | 4 test scenarios, task reuse |

## Key concepts learned
- Blocking vs non-blocking assignments
- 3-always FSM coding style
- Self-checking testbenches with pass/fail counters
- FIFO full/empty flag logic using pointer comparison
- Why `!==` catches X/Z but `!=` does not

## How to simulate
All files can be simulated on EDA Playground:
1. Go to edaplayground.com
2. Paste the design file in the left pane
3. Paste the testbench in the right pane
4. Select Icarus Verilog, check EPWave, click Run

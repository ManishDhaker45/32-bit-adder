# 32-bit Adder (Verilog)

A simple 32-bit adder implemented in RTL Verilog. This repository contains a synthesizable 32-bit adder module and a minimal testbench to exercise it.

## Repository structure

- `adder32.v` - 32-bit adder module (module name: `Adder32`).
- `adder32_tb.v` - Simple testbench for `Adder32` (module name: `adder32_tb`).
- `32 bit adder.jpg` - Image included in the workspace (can be used for documentation/diagram).

## Module: Adder32

Interface (from `adder32.v`):

- Ports:
  - `input [31:0] A`  — 32-bit input A
  - `input [31:0] B`  — 32-bit input B
  - `input Ci`        — carry-in (1-bit)
  - `output [31:0] S` — 32-bit sum (lower 32 bits of the full sum)
  - `output Co`       — carry-out (the 33rd bit of the sum)

Behavior summary:

- The module computes the sum of `A`, `B`, and `Ci` using a single Verilog addition expression and stores the result in a 33-bit wire `Sum33`.
- `S` is assigned from `Sum33[31:0]` (the lower 32 bits).
- `Co` is assigned from `Sum33[32]` (the high carry-out bit).

Design notes and implications:

- The implementation uses simple arithmetic addition (A + B + Ci) rather than an explicitly instantiated ripple-carry or carry-lookahead tree. This is concise and synthesizable by modern synthesis tools.
- Using a 33-bit intermediate wire (`Sum33`) ensures that carry-out is captured explicitly, avoiding overflow truncation.
- This module is combinational (no clocks inside the adder itself).

## Testbench: adder32_tb

- Provides a minimal harness that instantiates `Adder32` as `DUT` and drives `a`, `b`, and `cin` signals.
- Generates a clock `clk` (toggling every 10 time units) but the adder is combinational — the clock is used only by the testbench stimulus sequencing.
- The testbench displays changes and finishes at simulation time 100.

Observations from the provided testbench:

- The testbench uses initial values and then changes `a` and `b` at an `always @(posedge clk)` block with delays.
- The testbench prints changes with `$display`, however it does not dump waveforms using `$dumpfile` / `$dumpvars`. If you want waveforms (GTKWave), add `$dumpfile("wave.vcd"); $dumpvars(0, adder32_tb);` into the initial block.

## How to simulate (recommended)

These example commands assume you have Icarus Verilog (`iverilog` and `vvp`) installed on your Windows environment (PowerShell). If you use ModelSim / Questa / Vivado simulator, adapt commands accordingly.

PowerShell example (Icarus Verilog):

```powershell
# Compile
iverilog -o adder32_tb.vvp adder32.v adder32_tb.v

# Run
vvp adder32_tb.vvp
```

If you add waveform dumping to the testbench (recommended), generate and open a VCD:

```powershell
# Run (produces wave.vcd if $dumpfile/$dumpvars added)
vvp adder32_tb.vvp

# Open with GTKWave (if installed)
gtkwave wave.vcd
```

ModelSim/Questa basic steps (example):

- Create project or run directly:
  vsim + access permissions may vary; a typical flow is:

1. Compile:
```text
vlog adder32.v adder32_tb.v
```
2. Simulate:
```text
vsim work.adder32_tb
run 100ns
```

## Example expected console output

The testbench prints time, clock, a, b, cin when `a` or `b` changes. You should see printed binary vectors and time values similar to the `$display` format in the testbench.

## Suggestions / Improvements

- Add `$dumpfile("wave.vcd"); $dumpvars(0, adder32_tb);` to the testbench initial block to enable waveform viewing.
- Add more test vectors and assertions (for example using SystemVerilog `assert` or manual checking) to cover corner cases such as overflow, carry-in set, and boundary values (0x00000000, 0xFFFFFFFF).
- Add a small script (Makefile, PowerShell script, or CI job) to run simulation and report results automatically.
- Add a brief synthesis constraints / target FPGA notes if you intend to synthesize this RTL.

## Edge cases to test

- A = 0xFFFFFFFF, B = 0x00000001, Ci = 0 -> expect S = 0x00000000, Co = 1
- A = 0xFFFFFFFF, B = 0xFFFFFFFF, Ci = 1 -> expect S = 0xFFFFFFFE, Co = 1 (double-check with vector addition)
- Randomized vectors across clock cycles to validate against a reference software model.

## Author

- Repository owner: ManishDhaker45 (as recorded in the workspace)

## License

- No license file included. If you intend to open-source the project, add a `LICENSE` file (MIT/Apache-2.0/etc.) and mention it here.

## Contact / Contributing

- If you want me to add waveform dumping to the testbench, a richer set of tests, or a PowerShell script to run and parse results, tell me which you'd like and I will add it.

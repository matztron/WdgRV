<p align="center">
  <img width="460" height="300" src="imgs/wdg_ip1.jpeg">
</p>

# Verilog RISC-V Watchdop IP
Modules are developed following RISC-V spec:
https://github.com/riscvarchive/riscv-watchdog/blob/main/riscv-watchdog.adoc

# Integration to RISC-V cores
## Reset-based
The proposed integration scheme connects the second timeout value of the watchdog to reset logic of the SoC.
The SoC shown here is the FazyRV bit-serial RISC-V core by Meinhard Kissich

<p align="center">
  <img width="460" height="300" src="imgs/wdg_integration_reset.png">
</p>

## Interrupt Based
Alternativly the Wdg can be connected to the IRQ inputs of the given RV core.

<p align="center">
  <img width="460" height="300" src="imgs/wdg_integration_irq.png">
</p>

# Tooling
This project is Verilog only as to keep compatibility with open-source tools high.

Sim:
Icarus Verolog,
Verilator (also to get a SystemC model)

Synthesis:
Yosys
(Vivado)

## Rggen tool
To generate the register file for this project with a Wishbone interface
(can be easily ported to AXI)
the Rggen tool is used.
Refer to the Wiki for more information:
https://github.com/rggen/rggen/wiki

The s1wto and s2wto are set by HW and cleared by SW.
The HW (set) should take priority over clearing.

# Simulation
Implement a wb master to talk to the watchdog:
https://zipcpu.com/blog/2017/06/08/simple-wb-master.html
The watchdog will reset the wb master if it misses to write to the register

# Wishbone
Set a custom base address

Memory map:
- Offset 0: WDCSR-like register
- Offset 4: Register stating remaining timeout time
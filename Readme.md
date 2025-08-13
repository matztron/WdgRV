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

# Notes for HW
It is recommended to have a separate gp(i)o output from the CORE to ignore watchdog interrupts in the case of malfuctioning of this IP.

# Notes for SW
Program wdg time when the watchdog is not enabled



# Wishbone
Set a custom base address

Memory map:
- Offset 0: WDCSR-like register
- Offset 4: Register stating remaining timeout time
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

*Resets for Core and Watchdog are low-active!*
```c
// wdg_res_en_n is gated by ~gpo[1] (inverted as init by 0)
assign core_res_n = rst_in & (core_res_en_n | ~gpo[2]);
```
See here:
GPO is initialized to 0 - thus in this case no Watchdog reset requests are given to the core. 

If Core SW changes the GPO value to 1 the resets caused by Watchdog timeout are forwarded to the core.

<p align="center">
  <img width="460" height="300" src="imgs/waveform_gpo_masking.png">
</p>
The waveform shows

> GPO = 0 (init value): Watchdog interrupts do not take effect on the core.

> GPO = 1: Watchdog interrupts reset the core via the reset logic.

# Notes for SW
Program wdg time when the watchdog is not enabled.

# Watchdog register map

# Watchdog Timeout Time Calculation

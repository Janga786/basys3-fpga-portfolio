# XADC to Arduino Serial Link

A CE 433 lab: the Basys 3 samples an analog input with the Artix-7 XADC and
sends the upper byte of each reading to an Arduino on three wires (SCK, SS,
MOSI). The timing was checked on a Tektronix oscilloscope, and the demo clip shows
the board, a finger pulse sensor as the analog source, and the received
values plotted on a PC.

<p align="center">
<img src="docs/scope_sck_vs_mosi.png" alt="Scope capture: SCK (yellow) and MOSI (blue)" width="44%"/>
&nbsp;
<img src="docs/scope_sck_vs_ss.png" alt="Scope capture: SCK (yellow) and SS (blue)" width="44%"/>
</p>

The captures show SCK at 500 Hz (yellow) with MOSI or SS (blue).
Demo clip: [`docs/demo.mp4`](docs/demo.mp4).

## How it works

- `xadc_spi_top.v` / `xadc_spi_top_task2.v` (module `XADCdemo`) read
  auxiliary channel 6 (DRP address `0x16`, JXADC J3/K3) through the Vivado
  `xadc_wiz_0` IP and put the upper byte on the LEDs. The first version
  sends a constant `0x0F` for debugging; the task-2 version sends the ADC
  byte.
- `spi_leader_transmitter.v` (56 lines) divides the 100 MHz clock to a
  500 Hz SCK, lowers SS, shifts 8 bits out MSB first on falling SCK edges,
  then raises SS. It is a hand-written state machine, not an IP core.
- `arduino/spi_receiver.ino` reads the lines in software: it waits for SS
  to go low, samples MOSI on each rising SCK edge with `digitalRead()`, and
  prints the byte at 9600 baud.

## Wiring

| Signal | Basys 3 | Arduino pin |
| --- | --- | --- |
| SCK | JB1 (A14) | 2 |
| SS | JB2 (A16) | 12 |
| MOSI | JB3 (B15) | 13 |
| GND | GND | GND |
| Analog in | JXADC J3 (+), K3 (−) | |

The FPGA drives 3.3 V into the Arduino's inputs, which read it as high.

## Not included

The `xadc_wiz_0` IP core is generated in Vivado (XADC Wizard) and is not in
this repo.

<div align="center">

# Basys 3 FPGA Portfolio · Verilog & Embedded Systems

**Six self-contained Verilog projects on the Digilent Basys 3 (Xilinx Artix-7 XC7A35T): a soft-core CPU driving a PmodOLED display, a Basys-3-to-Arduino SPI bridge with logic-analyser captures, a PS/2-keyboard-to-UART protocol stack, a multi-mode traffic-light FSM, a 16×2 LCD driver, and a hand-rolled PicoBlaze instantiation.**

[![Verilog](https://img.shields.io/badge/Verilog-2001-3a86ff.svg)](#)
[![Vivado](https://img.shields.io/badge/toolchain-Vivado%202023.x-9b59b6.svg)](#)
[![Board: Basys 3](https://img.shields.io/badge/board-Basys%203-00b894.svg)](https://digilent.com/reference/programmable-logic/basys-3/start)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## Contents

- [Overview](#overview)
- [The projects](#the-projects)
- [Repository layout](#repository-layout)
- [Building (any project)](#building-any-project)
- [Reference: the Basys 3](#reference-the-basys-3)
- [License](#license)

---

## Overview

This repository is a curated showcase of six standalone digital-design
projects targeting the **Digilent Basys 3** (Xilinx Artix-7 35T,
XC7A35TCPG236-1).  They cover most of the classic embedded-systems
design surface — finite-state machines, peripheral interfacing,
protocol stacks, soft-core CPU instantiation, mixed-signal acquisition,
and cross-board communication — without any vendor-IP black boxes.

Every controller, FSM, debouncer, UART, SPI master, OLED driver, and
LCD driver here is **plain hand-written Verilog**.  The single soft-CPU
in this collection is Xilinx's PicoBlaze, used as a worked example of
how a memory-mapped microcontroller fits inside the FPGA fabric — but
its peripherals are still entirely my code.

> **What you can read off this repository.**
> If you're an employer or a graduate-program reviewer assessing
> hands-on FPGA fluency, every project here is small enough to read in
> ten minutes and demonstrates a different concept: **structural vs
> behavioural Verilog** (LCD driver), **Mealy/Moore FSM design**
> (traffic light), **asynchronous serial** (PS/2 receive), **bit-banged
> synchronous serial** (SPI master), **soft-CPU + memory-mapped I/O**
> (PicoBlaze), and **mixed-signal acquisition** (XADC).  The projects
> are presented in increasing order of integration complexity below.

---

## The projects

### 1. `pmod-oled-system/` — soft-CPU + display + button menu

A complete embedded system: the PicoBlaze soft-core drives a 128×32
PmodOLED, button presses navigate a ROM-stored menu, and a live ADC
sample is shown on the LED bar — all from one assembly firmware.

Highlights: assembly programming, SSD1306 command stream, ROM-table
menu navigation.

[Project README →](pmod-oled-system/README.md)

### 2. `xadc-spi-bridge/` — Basys 3 → Arduino over SPI

The Basys 3 reads its on-chip 12-bit XADC and transmits the result to
an Arduino over a hand-rolled SPI master.  Logic-analyser captures
verify the SCK / SS / MOSI timing meets the AVR's setup/hold spec.

Highlights: cross-board protocol design, ~80-line SPI master state
machine, Saleae captures, Arduino slave-mode receiver.

[Project README →](xadc-spi-bridge/README.md)

### 3. `picoblaze-softcore/` — 8-bit soft-CPU on the Basys 3

A clean instantiation of the PicoBlaze inside the Artix-7 fabric, with
debounced button I/O, a 4-digit seven-segment driver, and a
ROM-based menu lookup.

Highlights: memory-mapped peripheral bus, 16-tap shift-register
debouncer, hand-written PicoBlaze assembly.

[Project README →](picoblaze-softcore/README.md)

### 4. `usb-keyboard-uart/` — PS/2 → UART protocol stack

A three-stage protocol stack on the FPGA: PS/2 frame deserialiser →
scan-code-to-ASCII LUT → 9600-baud UART transmitter.  Type on the
keyboard, characters print on the host serial console.

Highlights: PS/2 receive timing, 50-line ASCII LUT, UART transmitter
with baud-rate divider.

[Project README →](usb-keyboard-uart/README.md)

### 5. `traffic-light-fsm/` — five iterations of one FSM

A study in evolving the same intersection controller through five
versions: combinational mapping → combinational + rush hour → proper
FSM → FSM + rush → FSM + switched enable.  Includes a self-checking
testbench.

Highlights: state-register pattern, parameterised counter periods,
exogenous control inputs.

[Project README →](traffic-light-fsm/README.md)

### 6. `lcd-driver/` — 16×2 character LCD driver

A datasheet-driven Verilog driver for the HD44780-compatible
HJ1602A.  Implements 4-bit-mode framing, the full HD44780 power-on
init sequence, and four progressively richer top-level demos
(static, switch-display, button-rotated messages, live adder
visualiser).

Highlights: long-duration timing parameters (15 ms power-on),
per-byte multi-cycle command framing, the LCD as a memory-mapped
output device.

[Project README →](lcd-driver/README.md)

---

## Repository layout

```
basys3-fpga-portfolio/
├── README.md                  # this file
├── LICENSE
├── docs/
│   └── basys3_pinout.md       # consolidated Basys 3 pin reference
│
├── pmod-oled-system/          # 1. soft-CPU + display + buttons
├── xadc-spi-bridge/           # 2. Basys 3 → Arduino over SPI
├── picoblaze-softcore/        # 3. PicoBlaze instantiation
├── usb-keyboard-uart/         # 4. PS/2 → UART stack
├── traffic-light-fsm/         # 5. five FSM iterations
└── lcd-driver/                # 6. 16×2 LCD driver
```

Every project folder follows the same skeleton:

```
<project>/
├── README.md                # what it does, how it's wired, why it matters
├── src/                     # Verilog (.v) and (where applicable) PicoBlaze (.psm)
├── constraints/             # Vivado XDC pin map(s)
└── docs/                    # demo videos / scope captures / photos
```

---

## Building (any project)

1. Install **Vivado 2023.x** (the WebPACK edition is free and supports
   the XC7A35T).
2. Launch Vivado, choose *Create Project*, set the device to
   `xc7a35tcpg236-1`.
3. Add the project's `src/*.v` as design sources and the
   `constraints/*.xdc` as a constraint file.
4. *Run synthesis*, *Run Implementation*, *Generate Bitstream*.
5. With the Basys 3 plugged in over USB, *Open Hardware Manager → Auto
   Connect → Program Device*.

For projects that include PicoBlaze assembly (`*.psm` files),
re-assemble with Xilinx's `kcpsm6.exe` if you've edited the source —
the produced ROM image replaces `ROM_form.v` in synthesis.

---

## Reference: the Basys 3

The pin map for every on-board peripheral the projects use is
consolidated in [`docs/basys3_pinout.md`](docs/basys3_pinout.md).
Quick summary:

| Resource | Count | Notes |
| --- | ---: | --- |
| Slide switches      |  16 | `V17 V16 W16 W17 W15 V15 W14 W13 V2 T3 T2 R3 W2 U1 T1 R2` |
| Push-buttons        |   5 | `BTNU BTND BTNL BTNR BTNC` (centre + 4 directional) |
| LEDs                |  16 | mirrored on the slide switches |
| 7-segment           | 4×8 | scanned at ~1 kHz |
| PMOD ports          |   4 | JA / JB / JC (2×6 PMOD) + JXADC (analog-capable) |
| USB-UART bridge     |   1 | FT2232 UART → host |
| USB host            |   1 | PIC24 → PS/2 → FPGA (used by the keyboard project) |
| XADC                |   1 | 12-bit, single-channel @ 1 MS/s typ. |
| Clock               |   1 | 100 MHz on `W5` (`CLK100MHZ`) |

Datasheet: <https://digilent.com/reference/programmable-logic/basys-3/reference-manual>

---

## License

Software in this repository is released under the [MIT License](LICENSE).

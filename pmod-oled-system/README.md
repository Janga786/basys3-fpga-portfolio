# PicoBlaze + PmodOLED System

A complete embedded system on a Basys 3 FPGA: a soft-core CPU driving a
128×32 monochrome OLED display, with button-driven menu navigation and a
live ADC display mode.  The system combines hardware Verilog (button
debouncing, seven-segment multiplexing, ROM/RAM glue) with firmware
written in PicoBlaze assembly that runs entirely inside the FPGA fabric.

<p align="center">
<img src="docs/oled_text.jpg" alt="PmodOLED showing a static text message" width="70%"/>
</p>

## What it does

Three concurrent capabilities, all driven by a single PicoBlaze softcore:

1. **Static text on the OLED** — the CPU writes a hello-world style
   message via the SSD1306-style PmodOLED command stream.
2. **Live ADC histogram on the LEDs** — XADC samples are mapped to the
   16-bit LED bar in real time, with a 10 ms delay loop in firmware.
3. **Button-driven menu** — pressing the four directional buttons walks
   through ROM-stored messages (each row in the assembly's `btn_rom`
   selects which page is displayed), with proper edge-debounced
   detection so a single physical press registers as exactly one event.

A runnable demonstration of all three modes:

| Mode | Demo |
| --- | --- |
| OLED + XADC live read | [`docs/demo_oled_xadc.mp4`](docs/demo_oled_xadc.mp4) |
| Button-driven menu navigation | [`docs/demo_button_menu.mp4`](docs/demo_button_menu.mp4) |

## How it's built

```
                       ┌───────────────────┐
                       │   PicoBlaze CPU   │ ← assembly firmware (.psm)
                       │   (kcpsm6)         │
                       └─┬───────────────┬─┘
                         │ port_id, in/out
                         │
   ┌─────────────────────┼─────────────────────┬───────────────┐
   │                     │                     │               │
┌──┴──┐               ┌──┴──┐                ┌─┴───┐       ┌───┴────┐
│ XADC │              │ LEDs │                │ btns │       │ btn_rom │
│ A0   │              │ 16   │                │  5   │       │  ROM   │
└──────┘              └──────┘                └──────┘       └────────┘
                                                                 │
                                                            ┌────┴────┐
                                                            │ PmodOLED │
                                                            │ SSD1306  │
                                                            └─────────┘
```

The PicoBlaze instantiation in `kcpsm6.v` is a generic 8-bit RISC core
with a 256-entry register file and a 1024-instruction program ROM.  The
ROM is loaded at synthesis time from `firmware.psm` (assembled with the
`kcpsm6.exe` tool — output is the Verilog ROM image that initialises the
program memory).

`pico_btn.v` is the I/O bridge: it routes the PicoBlaze's `port_id`
output to either the LED bar, the XADC sample registers, the
seven-segment multiplexer, or the OLED command/data ports — all over
the same memory-mapped 8-bit bus.

`debounce.v` is a textbook synchroniser-debouncer: a 2-flop synchroniser
for metastability, followed by a 16-bit shift register that asserts the
debounced output only after 16 consecutive identical samples
(≈ 160 µs at 100 MHz).

## Repository layout

```
pmod-oled-system/
├── src/
│   ├── top.v                         # top-level wiring of all modules
│   ├── kcpsm6.v                      # PicoBlaze 8-bit soft-core CPU
│   ├── kcpsm6_design_template.v      # standard wrapper
│   ├── ROM_form.v                    # synthesisable program-ROM template
│   ├── pico_btn.v                    # memory-mapped I/O bridge
│   ├── seven_segment_mux.v           # 4-digit scanned 7-seg driver
│   ├── debounce.v                    # button debouncer + edge detector
│   ├── btn_rom.v                     # ROM table for menu strings
│   ├── btn_rom.psm                   # source of btn_rom
│   ├── prog.psm                      # main firmware (current build)
│   ├── task2_xadc_to_leds.psm        # XADC → LED bar firmware variant
│   └── task3_button_menu.psm         # button-menu firmware variant
└── docs/
    ├── oled_text.jpg                 # PmodOLED hardware photo
    ├── demo_oled_xadc.mp4            # live ADC display
    └── demo_button_menu.mp4          # button-menu navigation
```

## Building it

1. Open the `src/` directory as a Vivado project targeting the Basys 3
   (`xc7a35tcpg236-1`).
2. Use the parent repo's [`docs/basys3_pinout.md`](../docs/basys3_pinout.md)
   for the constraint file (XADC pin, OLED on JC PMOD, buttons on
   `BTNU/BTND/BTNL/BTNR/BTNC`).
3. Re-assemble any modified `.psm` file via `kcpsm6.exe firmware.psm`
   (Windows host or via Wine) — the produced `firmware.v` replaces
   `ROM_form.v` in the synthesis.
4. Synthesise + implement + generate bitstream + program the board.

## Notes on the PicoBlaze choice

The PicoBlaze is an 8-bit soft-core CPU originally distributed by
Xilinx.  At ~26 LUTs it occupies <0.2 % of the Artix-7 fabric, leaving
the rest of the FPGA free for custom peripherals.  Two upsides for an
embedded-systems portfolio:

- **Pedagogical**: lets you write *both* the hardware (peripheral
  modules in Verilog) *and* the firmware (assembly) for the same
  system, exposing the abstraction boundary.
- **Practical**: a ROM-mapped CPU is the cleanest way to drive
  display peripherals like the SSD1306 — long, sequential command
  streams that would be ugly as pure FSMs become straightforward
  assembly subroutines.

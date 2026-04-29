# PicoBlaze Soft-Core CPU on a Basys 3

A minimal but complete embedded system built around the **PicoBlaze**
8-bit soft-core CPU instantiated inside the Artix-7 fabric: assembly
firmware, debounced button I/O, ROM-table lookup, and a 4-digit
seven-segment display driven from the CPU's memory-mapped output port.

This project is the cleanest demonstration in this portfolio of the
hardware/firmware split that defines embedded systems work — *every
peripheral the CPU touches is also a Verilog module written by hand*.

## What it does

Pressing one of the four directional buttons (`BTNU/BTND/BTNL/BTNR`)
selects a row in a Verilog ROM table; the corresponding ASCII string
is read into the CPU's register file by an `INPUT` instruction and
written to the seven-segment display via an `OUTPUT` instruction.
Holding `BTNC` (centre) cycles through all rows automatically.

The whole system fits in well under 1 % of the Basys 3 LUT count —
there's room left for a dozen more peripherals.

## How it's built

```
                              ┌──────────────────┐
                              │  PicoBlaze CPU    │  ← 256-byte register file
                              │  (kcpsm6)         │     1024-instruction ROM
                              └─┬─────────────┬──┘
                                │  port_id    │ in_port / out_port
                                ▼             ▼
                          ┌──────────────────────┐
                          │  pico_btn  (I/O bridge)
                          └────┬──────────────┬───┘
                               │              │
                          ┌────┴────┐    ┌────┴──────────┐
                          │ btn_rom │    │ seven_segment │
                          │  ROM    │    │     mux        │
                          └─────────┘    └────────────────┘
                                ▲
                          ┌─────┴──────┐
                          │  debounce  │
                          │  + edge    │
                          └────────────┘
                                ▲
                          5 buttons (Basys 3)
```

| Module | Purpose |
| --- | --- |
| **`kcpsm6.v`**         | The PicoBlaze CPU itself — 8-bit RISC, ~26 LUTs |
| **`top.v`**            | Top-level wiring: clock, buttons, displays |
| **`pico_btn.v`**       | Memory-mapped I/O bridge (port-id decoder) |
| **`debounce.v`**       | 2-flop synchroniser + 16-tap shift-register debouncer |
| **`seven_segment_mux.v`** | 4-digit scanned 7-seg driver at ~1 kHz refresh |
| **`btn_rom.v`**        | Synthesisable ROM table with menu strings |
| **`ROM_form.v`**       | Synthesisable program-ROM template (loaded from `.psm`) |

## Firmware

Three assembly files are included as alternates:

- **`firmware.psm`** — main build (the one currently loaded into ROM).
- **`btn_rom.psm`** — source of the menu-string ROM table.
- **`btn_rom_section3.psm`** — variant with extra ROM rows for testing.

A representative subroutine (the 10 ms delay loop):

```asm
delay:
    LOAD s2, FF
delay_outer:
    LOAD s3, FF
delay_inner:
    SUB s3, 01
    JUMP NZ, delay_inner
    SUB s2, 01
    JUMP NZ, delay_outer
    RETURN
```

Two nested 8-bit counters → 65 536 inner iterations × ~3 cycles each
≈ 2 ms at 100 MHz.  Adjust the inner constants for finer timing.

## Building

1. Open the `src/` directory as a Vivado project targeting the Basys 3
   (`xc7a35tcpg236-1`).
2. Add `constraints/basys3.xdc` to the project.
3. Re-assemble the firmware via Xilinx's `kcpsm6.exe` if you've edited
   the `.psm`:

   ```
   kcpsm6.exe firmware.psm
   ```

   The output file replaces `ROM_form.v` in synthesis.
4. Synthesise, implement, generate bitstream, program the board.

## Why a soft-core?

A soft-core CPU is the right answer when:

- The peripherals you need are *unusual* (custom protocols, weird
  timings) but the *control flow* you want for them is mundane (read
  byte, branch, write byte).  You'd rather express the control flow as
  C-like assembly than as a hand-rolled FSM.
- You need **multiple peripherals to share a control sequence** —
  e.g. an OLED command stream that must coordinate with button input
  and an ADC reading.  An FSM that does all three becomes hairy; a
  CPU with three OUT ports stays linear.
- You want to **iterate on firmware** without re-synthesising the
  whole bitstream.  Tools like Xilinx's JTAG-Loader can re-load just
  the program ROM in seconds.

The PicoBlaze is the smallest soft-core in common use — 8 bits, 18
register file, no caches, no MMU.  At 26 LUTs it occupies less than
0.2 % of an Artix-7 35T.  When you need more, the natural next step
is the MicroBlaze (32-bit, full Linux-capable) — same memory-mapped
I/O bridge, just more silicon.

# PicoBlaze a² + b² System

A CE 433 lab built on Xilinx's PicoBlaze (KCPSM6) 8-bit soft processor. It
adapts the "square circuit" textbook example (Listing 17.2 in the
`pico_btn.v` header) from KCPSM3 to KCPSM6 on the Basys 3: the program reads
`a` and `b` from the switches, computes a² + b² in PicoBlaze assembly and
shows the result on the seven-segment display, with the 16-bit result also
on the LEDs.

## Files

| File | Source | Role |
| --- | --- | --- |
| `pico_btn.v` | textbook listing, modified | Top module: KCPSM6, program ROM, two debounced buttons, output-port decoder for the four digits and two LED bytes. Its header lists the changes from the book version. |
| `debounce.v`, `seven_segment_mux.v` | textbook listings 6.2 and 4.13 | Button debouncer FSM and 4-digit display multiplexer. |
| `btn_rom.psm` | textbook program, modified | a² + b² program with the LED output added. |
| `btn_rom_section3.psm` | textbook program, modified | Variant that always shows the result in hex; up button loads `a`/`b`, centre button clears. |
| `firmware.psm` | lab code | Separate exercise: reads the XADC and shows it on the LEDs. |
| `kcpsm6.v`, `kcpsm6_design_template.v`, `ROM_form.v` | Xilinx | PicoBlaze core, instantiation template, ROM template. |
| `top.v` | Xilinx-generated | Assembled program ROM (module `task2`), not a top-level. |
| `constraints/basys3.xdc` | | Clock, 8 switches, 2 buttons, seven-segment display. |

## Notes

`pico_btn.v` instantiates a ROM module named `btn_rom`, which the KCPSM6
assembler generates from `btn_rom.psm` and `ROM_form.v`. That generated
file is not in this folder (`top.v` is the ROM for a different program),
so re-assemble `btn_rom.psm` before building.

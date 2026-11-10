# 16x2 Character LCD Driver

A Verilog driver for a 16x2 HD44780-type character LCD, written for CE 433
labs, with four lab top-level modules that use it.

## The driver (`src/lcd_driver.v`)

- 8-bit data bus (`data_out[7:0]`), plus `en` and `rs`. R/W is tied to
  ground on the breadboard.
- On reset it sends four instructions: `0x30` (function set), `0x01`
  (clear), `0x06` (entry mode), `0x0F` (display on, blinking cursor).
- One counter spaces every command and character: `clk_param` clock cycles
  (default 100 000, 1 ms at 100 MHz). The top-levels use 16 000 000
  (160 ms per character).
- After 16 characters it runs the init sequence again, which clears the
  display and redraws.

## Top-levels

| File | Module | What it shows |
| --- | --- | --- |
| `top_static_message.v` | `task1_top` | A word picked by `sw[7:0]` (for example `ACCION`, `MOVIMIENTO`). |
| `top_switch_display.v` | `task2_top` | A fixed message, `CE433 Basys 3`, with the cursor off (its own copy of the driver uses `0x0C`). |
| `top_button_message.v` | `task3_top` | `Hello !!`, written as ASCII hex codes. |
| `top_adder_visualiser.v` | `task4_top` | Two signed 3-bit numbers from the switches, add or subtract, with the result, using `adder.v`. |

The file names do not match the contents in every case; the table follows
the code.

## Wiring

From `constraints/basys3.xdc`: D0 to D7 on JA (J1, L2, J2, G2, H1, K2, H2,
G3), EN on JB1 (A14), RS on JB3 (B15), reset on the centre button (U18).
The XDC has no switch pins, so `task1_top` and `task4_top` need `sw[7:0]`
added (see [`../docs/basys3_pinout.md`](../docs/basys3_pinout.md)).

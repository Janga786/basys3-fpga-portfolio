# PS/2 Keyboard to UART

A CE 433 lab: a keyboard plugged into the Basys 3 USB host port (the
on-board PIC24 presents it to the FPGA as PS/2) is read in Verilog, and
each key is sent as an ASCII character over the board's USB-UART at
9600 baud.

## Modules

| File | Module | What it does |
| --- | --- | --- |
| `ps2_keyboard_rx.v` | `USB_keyboard` | Receives one 11-bit PS/2 frame on the falling edge of the PS/2 clock; outputs the byte, or `0x00` if odd parity fails. |
| `scancode_to_ascii.v` | `scancode_to_ascii` | `case` table from set-2 make codes to lower-case letters, digits, space, Enter, Backspace, Tab and common punctuation. |
| `uart_tx_ctrl.v` | `UART_tx_ctrl` | 8N1 transmitter, 9600 baud from the 100 MHz clock. |
| `top_keyboard_to_uart.v` | (header missing, see below) | Skips `0xF0` break codes, converts the make code, sends it over UART; LEDs show the last scan code and its ASCII value. |
| `keyboard_to_seven_segment.v` | `USB_keyboard_app` | Earlier lab step: tracks make/break bytes and shows the key code on the LEDs (no seven-segment output despite the name). |
| `tb_*.v` | | Simulation testbenches for the two top-levels. |

Constraints for both top-levels are in `constraints/` (PS/2 on C17/B17,
UART TX on A18).

## Known issue

`top_keyboard_to_uart.v` is missing its `module ... (...);` header line,
so it does not compile as committed. Its testbench instantiates it as
`USB_keyboard_uart_top(clk, PS2Clk, PS2Data, RsTx, led)`.

# PS/2 Keyboard → UART Bridge

A complete protocol stack on a Basys 3 FPGA:

1. **PS/2 receive** — a PS/2 keyboard plugged into the on-board USB-PS/2
   port emits 11-bit serial frames (start bit, 8 data bits, parity,
   stop bit) at ~10–16 kHz.  We sample them, deserialise them, and hand
   the raw 8-bit scan code to the next stage.
2. **Scan-code → ASCII** — a combinational lookup table maps PS/2
   make-codes (set 2) to ASCII characters.  Letters, digits, punctuation,
   `space`, `enter`, `backspace`, `tab` all supported.
3. **UART transmit** — a 9600-baud UART core sends each ASCII byte over
   the on-board USB-UART bridge to a host serial console.

The end result: type a key on the keyboard, see the character print on
your laptop's serial monitor, with the FPGA doing 100 % of the protocol
translation in hardware (no soft-core CPU involved).

## How it's built

```
   PS/2 keyboard          ┌──────────────────┐         UART  USB
   data + clk  ──────────►│ ps2_keyboard_rx  │
                          │  - clock-edge    │
                          │    detector       │
                          │  - 11-bit shift   │
                          │  - parity check   │
                          └─────┬─────────────┘
                                │ scan_code[7:0]
                                ▼
                          ┌─────────────────┐
                          │ scancode_to_ascii │   (combinational LUT)
                          └─────┬─────────────┘
                                │ ascii[7:0]
                                ▼
                          ┌─────────────────┐         ┌────────┐
                          │  uart_tx_ctrl   │────────►│ FT2232 │──► host
                          │  9600-8-N-1     │         │ on board│
                          └─────────────────┘         └────────┘
```

Two top-levels are included for different demo scenarios:

| Top-level | Output | When to use |
| --- | --- | --- |
| `top_keyboard_to_uart.v`            | UART | Day-to-day demo; type into a serial monitor |
| `keyboard_to_seven_segment.v`       | seven-segment | Standalone demo without a host PC |

## Repository layout

```
usb-keyboard-uart/
├── src/
│   ├── ps2_keyboard_rx.v               # PS/2 receiver (11-bit deserialiser)
│   ├── scancode_to_ascii.v             # set-2 make-code → ASCII LUT
│   ├── uart_tx_ctrl.v                  # 9600-baud UART transmitter
│   ├── top_keyboard_to_uart.v          # PS/2 → ASCII → UART top
│   ├── keyboard_to_seven_segment.v     # PS/2 → ASCII → 7-seg top
│   ├── tb_keyboard_to_uart.v           # testbench (UART path)
│   └── tb_keyboard_to_seven_segment.v  # testbench (7-seg path)
└── constraints/
    ├── basys3_keyboard_to_uart.xdc           # PS/2 + UART pin map
    └── basys3_keyboard_to_seven_segment.xdc  # PS/2 + 7-seg pin map
```

## Why this is a good portfolio piece

It exercises three quite different pieces of digital design in one
project:

- **Asynchronous serial reception** with proper clock-edge detection
  and parity validation (the PS/2 lane).
- **Combinational lookup-table mapping** as a pure stateless function
  (the scan-code → ASCII module is 50 lines of one-hot `case`).
- **Synchronous bit-banged transmission** with a baud-rate divider and
  a per-bit shift register (the UART transmitter).

…all without any soft CPU.  Every byte that crosses the system has its
timing nailed down at synthesis time.

## Notes on the PS/2 protocol

PS/2 is open-collector: both lines are pulled high by default and
either party can pull low to drive a bit.  For this *receive-only*
project we only ever look at the lines, so the on-board pull-ups are
sufficient and the FPGA's I/O standard is a regular `LVCMOS33`.

The make-codes used here are PS/2 *set 2*, the default for almost all
modern USB-to-PS/2 keyboards.  Set-2 distinguishes make events from
break events with an `0xF0` prefix on releases — this project ignores
breaks (`scan_code` is updated only on make events), so holding a key
prints exactly one character.

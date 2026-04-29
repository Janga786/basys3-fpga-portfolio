# 16×2 Character LCD Driver

A Verilog driver for the ubiquitous **HJ1602A** 16×2 character LCD
(HD44780-compatible), with four progressively richer top-level demos.
Implements the LCD's parallel command / data interface in 4-bit mode,
including the awkward 15 ms "wait after power-on" requirement, the
40 µs minimum command-execution time, and the 1.64 ms `clear-display`
hold time — all timing parameters lifted directly from the datasheet.

## What it does

| Top-level | Demo |
| --- | --- |
| `top_static_message.v`     | writes a fixed string ("Hello, Basys 3!") on power-up and holds it. |
| `top_switch_display.v`     | shows the 16-bit switch register as a hex value, updating live. |
| `top_button_message.v`     | rotates between four canned messages, one per directional button. |
| `top_adder_visualiser.v`   | reads two 8-bit operands from switches, displays `A + B = C` with carry-out. |

The fourth top-level is the most interesting because it exercises the
LCD driver as a **memory-mapped output device**: the adder's result
register is wired straight into the LCD's data input, so any change
of switch state immediately re-renders the display.

## How it's built

The driver is a single state machine in [`src/lcd_driver.v`](src/lcd_driver.v):

```
   POWER_ON ─►  CMD_FUNCTION_SET ─►  CMD_DISPLAY_OFF ─►  CMD_CLEAR
        │                                                │
        │                                                ▼
        │                                          CMD_ENTRY_MODE
        │                                                │
        │                                                ▼
        │                                          CMD_DISPLAY_ON
        │                                                │
        │  ┌────────────────────────────────────────────┘
        │  ▼
        │  WRITE_CHAR ◄─── (CPU writes to data_in + send strobe)
        │  │
        ▼  ▼
        IDLE
```

Each transition is gated by a parameterised wait counter, so the
driver self-throttles to the LCD's response time without needing the
upstream module to insert delays.

The 4-bit-mode framing (each byte sent as two nibbles with the upper
nibble first) is hidden inside the driver: callers see only an 8-bit
data port and a `send` strobe.

## Repository layout

```
lcd-driver/
├── src/
│   ├── lcd_driver.v                # the LCD state machine itself
│   ├── adder.v                     # 8-bit ripple adder (used by top_adder_visualiser)
│   ├── top_static_message.v        # demo 1
│   ├── top_switch_display.v        # demo 2
│   ├── top_button_message.v        # demo 3
│   └── top_adder_visualiser.v      # demo 4 — adder + LCD as output device
└── constraints/
    └── basys3.xdc                  # full Basys 3 pin map (LCD on JC PMOD)
```

## Wiring

The LCD plugs into JC of the Basys 3 (the PMOD nearest to the seven-
segment display).  The XDC pins are:

| LCD pin | Function | JC pin |
| --- | --- | ------ |
| RS  | register select          | JC1 |
| RW  | read/write (tied LOW)    | JC2 |
| E   | enable strobe            | JC3 |
| D4  | data nibble bit 0        | JC4 |
| D5  | data nibble bit 1        | JC7 |
| D6  | data nibble bit 2        | JC8 |
| D7  | data nibble bit 3        | JC9 |

VDD and the contrast pin (V0) come from external 5 V — the Basys 3's
3.3 V PMOD power isn't enough to drive the HD44780's logic, so a
dedicated 5 V supply or one of the on-board +5 V headers must be
used.

## Why this is a good portfolio piece

The LCD driver is a *small* design that nonetheless touches every
classic FPGA pitfall: long-duration timing parameters
(15 ms power-on), short-duration parameters (40 ns enable pulse), a
multi-cycle multi-byte command stream, and a 4-bit-mode encoding that
*requires the host to send two nibbles per byte in the right order*.
Getting all of that right with one timer counter is good practice.

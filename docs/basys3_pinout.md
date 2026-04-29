# Basys 3 Pinout Reference

Consolidated pinout for the on-board peripherals used by the projects
in this repository.  The full master XDC is also reproduced as a
ready-to-paste block at the bottom.

## Clock

| Function | Pin | Bank | I/O standard |
| --- | --- | --- | --- |
| 100 MHz system clock | `W5` | 34 | `LVCMOS33` |

## Slide switches (16)

| Switch | Pin | Switch | Pin |
| ------ | --- | ------ | --- |
| `sw[0]` | `V17` | `sw[8]`  | `V2`  |
| `sw[1]` | `V16` | `sw[9]`  | `T3`  |
| `sw[2]` | `W16` | `sw[10]` | `T2`  |
| `sw[3]` | `W17` | `sw[11]` | `R3`  |
| `sw[4]` | `W15` | `sw[12]` | `W2`  |
| `sw[5]` | `V15` | `sw[13]` | `U1`  |
| `sw[6]` | `W14` | `sw[14]` | `T1`  |
| `sw[7]` | `W13` | `sw[15]` | `R2`  |

## Push-buttons (5)

| Button | Pin | Position |
| ------ | --- | -------- |
| `btnC` | `U18` | centre |
| `btnU` | `T18` | up |
| `btnD` | `U17` | down |
| `btnL` | `W19` | left |
| `btnR` | `T17` | right |

## LEDs (16)

| LED | Pin | LED | Pin |
| --- | --- | --- | --- |
| `led[0]` | `U16` | `led[8]`  | `V13` |
| `led[1]` | `E19` | `led[9]`  | `V3`  |
| `led[2]` | `U19` | `led[10]` | `W3`  |
| `led[3]` | `V19` | `led[11]` | `U3`  |
| `led[4]` | `W18` | `led[12]` | `P3`  |
| `led[5]` | `U15` | `led[13]` | `N3`  |
| `led[6]` | `U14` | `led[14]` | `P1`  |
| `led[7]` | `V14` | `led[15]` | `L1`  |

## Seven-segment display

| Function | Pin | Function | Pin |
| --- | --- | --- | --- |
| `seg[0]` (a) | `W7` | `an[0]` | `U2` |
| `seg[1]` (b) | `W6` | `an[1]` | `U4` |
| `seg[2]` (c) | `U8` | `an[2]` | `V4` |
| `seg[3]` (d) | `V8` | `an[3]` | `W4` |
| `seg[4]` (e) | `U5` | `dp`    | `V7` |
| `seg[5]` (f) | `V5` | | |
| `seg[6]` (g) | `U7` | | |

## PMOD JA / JB / JC

Each PMOD is a 2×6 0.1″ header.  Top row is `JA[1..4]`, bottom row is
`JA[7..10]`; `JA[5]/JA[11]` are GND, `JA[6]/JA[12]` are 3.3 V.

| Function | JA | JB | JC |
| -------- | -- | -- | -- |
| pin 1  | J1  | A14 | K17 |
| pin 2  | L2  | A16 | M18 |
| pin 3  | J2  | B15 | N17 |
| pin 4  | G2  | B16 | P18 |
| pin 7  | H1  | A15 | L17 |
| pin 8  | K2  | A17 | M19 |
| pin 9  | H2  | C15 | P17 |
| pin 10 | G3  | C16 | R18 |

## JXADC (analog-capable PMOD)

| Function | Pos pin | Neg pin |
| -------- | ------- | ------- |
| Channel 6  | `J3`  | `K3`  |
| Channel 7  | `M2`  | `M1`  |
| Channel 14 | `N2`  | `N1`  |
| Channel 15 | `L3`  | `M3`  |

## USB-UART (FT2232)

| Function | Pin |
| -------- | --- |
| FPGA TX (→ host) | `A18` |
| FPGA RX (← host) | `B18` |

## USB host (PS/2 keyboard via on-board PIC24)

| Function | Pin |
| -------- | --- |
| PS/2 clock  | `C17` |
| PS/2 data   | `B17` |

## VGA (not used by these projects but included for reference)

| Function | Pin |
| --- | --- |
| `R[0]/R[1]/R[2]/R[3]` | `G19 H19 J19 N19` |
| `G[0]/G[1]/G[2]/G[3]` | `J17 H17 G17 D17` |
| `B[0]/B[1]/B[2]/B[3]` | `N18 L18 K18 J18` |
| `hsync / vsync`       | `P19 R19` |

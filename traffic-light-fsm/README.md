# Traffic-Light Controller, Five Versions

A CE 433 lab: the same two-road traffic light written five ways in Verilog.
Each state lasts `cntmax` clock cycles (100 000 000, 1 s at 100 MHz).

| State | Road 1 | Road 2 |
| --- | --- | --- |
| 0 | red | green |
| 1 | red | yellow |
| 2 | red | red |
| 3 | green | red |
| 4 | yellow | red |
| 5 | red | red |

| File | Module | Approach |
| --- | --- | --- |
| `traffic_light_combinational.v` | `trafficlight` | 3-bit counter with gate equations for each light. |
| `traffic_light_combinational_rush.v` | `trafficlight_rush` | Adds a `rush` input that switches to a 7-state sequence with road-1 green held twice as long. |
| `traffic_light_fsm.v` | `trafficlight_fsm` | State register with a `case` table for the outputs. |
| `traffic_light_fsm_rush.v` | `trafficlight_fsm_rush` | FSM with road-1 green always held for two periods (second counter). |
| `traffic_light_fsm_switched.v` | `trafficlight_fsm_switch` | Same, but the double-length green only when the `rush` input is high. |

`src/testbench.v` holds Basys 3 wrapper modules (`task1_top` to
`task5_top`; LEDs 5 to 0 are G1, Y1, R1, G2, Y2, R2; `sw[0]` is rush) and a
simulation testbench, `trafficlight_tb`. The testbench sets `cntmax = 4`,
toggles `sw[0]` and prints the lights with `$monitor`; it does not check
the outputs automatically. Uncomment one DUT line to pick the version.

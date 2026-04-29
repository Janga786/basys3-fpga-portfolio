# Traffic-Light Controller — Five Iterations

A study in how the same intersection-controller behaviour can be
expressed five different ways in Verilog, from the most direct
combinational mapping to a parameterised finite-state machine with a
runtime "rush hour" mode and a switch-driven enable.

The exercise mirrors the way real digital-design projects evolve:
start with the simplest thing that works, then refactor toward a
clean state machine, then expose configuration knobs.

## What it does

A two-direction intersection (call them road 1 and road 2) cycling
through six states:

| State | road 1 | road 2 |
| --- | --- | --- |
| 0 | RED        | GREEN  |
| 1 | RED        | YELLOW |
| 2 | RED        | RED    |
| 3 | GREEN      | RED    |
| 4 | YELLOW     | RED    |
| 5 | RED        | RED    |

State period is 1 second at the Basys 3's 100 MHz clock (counter wraps
at 100 000 000).  The five top-modules are:

| Module | Style | Notes |
| --- | --- | --- |
| `traffic_light_combinational.v`        | direct mapping | uses a 1-of-6 mux on a counter |
| `traffic_light_combinational_rush.v`   | + rush hour    | green segments doubled when sw[0] high |
| `traffic_light_fsm.v`                  | proper FSM     | explicit state register + transition logic |
| `traffic_light_fsm_rush.v`             | FSM + rush     | rush mode handled in next-state logic |
| `traffic_light_fsm_switched.v`         | FSM + enable   | sw[1] enable, sw[0] rush — two runtime knobs |

A self-checking testbench in `src/testbench.v` exercises every
top-level over a full cycle and asserts the LED outputs against the
truth table above.

## Why five copies?

Each version teaches a slightly different Verilog concept, so the
progression is itself the project:

1. **Combinational mapping** — Verilog as a structural language;
   you can write the truth table and the synthesiser does the rest.
2. **+ Rush hour** — branching combinational logic; introduces a
   conditional in the case statement.
3. **Proper FSM** — separation of *next-state logic* (combinational)
   from the *state register* (sequential).  This is the textbook
   pattern that scales to systems with dozens of states.
4. **FSM + rush** — adds a second exogenous input (the switch) and
   shows how to thread it cleanly through the next-state logic without
   collapsing back into a combinational mess.
5. **FSM + switched enable** — two configuration switches and one
   master enable, so the design demonstrates the full "control-and-
   data-path" structure of a real controller.

## Repository layout

```
traffic-light-fsm/
└── src/
    ├── traffic_light_combinational.v       # 1: direct mux
    ├── traffic_light_combinational_rush.v  # 2: + rush
    ├── traffic_light_fsm.v                  # 3: proper FSM
    ├── traffic_light_fsm_rush.v             # 4: FSM + rush
    ├── traffic_light_fsm_switched.v         # 5: FSM + enable
    └── testbench.v                          # self-checking TB
```

The constraint file in [`../docs/basys3_pinout.md`](../docs/basys3_pinout.md)
covers the LED and switch mapping you need at synthesis time.

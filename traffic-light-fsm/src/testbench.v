// ============================================================
// Top-Level Wrappers for Basys3
// ============================================================
// Port names match the Basys3_Master.xdc: clk, sw[15:0], led[15:0]
// LED mapping: led[5]=G1, led[4]=Y1, led[3]=R1,
//              led[2]=G2, led[1]=Y2, led[0]=R2

// --- combinational variant Top (no switch needed) ---
module task1_top(clk, led);
    input clk;
    output [5:0] led;
    trafficlight dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));
endmodule

// --- combinational + rush variant Top (sw[0] = rush hour) ---
module task2_top(clk, sw, led);
    input clk;
    input [0:0] sw;
    output [5:0] led;
    trafficlight_rush dut(.clk(clk), .rush(sw[0]), .light1(led[5:3]), .light2(led[2:0]));
endmodule

// --- FSM variant Top (no switch needed) ---
module task3_top(clk, led);
    input clk;
    output [5:0] led;
    trafficlight_fsm dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));
endmodule

// --- FSM + rush variant Top (no switch needed) ---
module task4_top(clk, led);
    input clk;
    output [5:0] led;
    trafficlight_fsm_rush dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));
endmodule

// --- FSM + switched variant Top (sw[0] = rush hour) ---
module task5_top(clk, sw, led);
    input clk;
    input [0:0] sw;
    output [5:0] led;
    trafficlight_fsm_switch dut(.clk(clk), .rush(sw[0]), .light1(led[5:3]), .light2(led[2:0]));
endmodule


// ============================================================
// Simulation Testbench
// ============================================================
`timescale 1ns / 1ps

module trafficlight_tb;
    reg clk;
    reg [0:0] sw;
    wire [5:0] led;

    // Uncomment ONE at a time:
    // trafficlight #(.cntmax(4)) dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));                              // combinational variant
    // trafficlight_rush #(.cntmax(4)) dut(.clk(clk), .rush(sw[0]), .light1(led[5:3]), .light2(led[2:0]));            // combinational + rush variant
    // trafficlight_fsm #(.cntmax(4)) dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));                           // FSM variant
    // trafficlight_fsm_rush #(.cntmax(4)) dut(.clk(clk), .light1(led[5:3]), .light2(led[2:0]));                      // FSM + rush variant
    trafficlight_fsm_switch #(.cntmax(4)) dut(.clk(clk), .rush(sw[0]), .light1(led[5:3]), .light2(led[2:0]));         // FSM + switched variant

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        sw = 0;
        #600;
        sw = 1;
        #800;
        $finish;
    end

    initial begin
        $monitor("Time=%0t | sw=%b | led=%b (G1=%b Y1=%b R1=%b | G2=%b Y2=%b R2=%b)",
                 $time, sw, led, led[5], led[4], led[3], led[2], led[1], led[0]);
    end
endmodule

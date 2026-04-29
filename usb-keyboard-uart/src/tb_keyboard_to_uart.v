`timescale 1ns / 1ps

module tb_USB_keyboard_uart;

    reg clk; reg ps2clk; reg ps2data;
    wire RsTx; wire [15:0] led;

    USB_keyboard_uart_top DUT(.clk(clk), .PS2Clk(ps2clk), .PS2Data(ps2data), .RsTx(RsTx), .led(led));

    initial clk = 0;
    always #5 clk = ~clk;

    localparam PS2_CLK_PERIOD = 60000;
    localparam BIT_PERIOD = 104170; // 10417 clocks * 10ns for 9600 baud

    task send_ps2_byte;
        input [7:0] byte_val;
        reg parity; integer i;
        begin
            parity = ~(^byte_val);
            ps2data = 1'b0;
            #(PS2_CLK_PERIOD/2); ps2clk = 1'b0; #(PS2_CLK_PERIOD/2); ps2clk = 1'b1;
            for (i = 0; i < 8; i = i + 1) begin
                ps2data = byte_val[i];
                #(PS2_CLK_PERIOD/2); ps2clk = 1'b0; #(PS2_CLK_PERIOD/2); ps2clk = 1'b1;
            end
            ps2data = parity;
            #(PS2_CLK_PERIOD/2); ps2clk = 1'b0; #(PS2_CLK_PERIOD/2); ps2clk = 1'b1;
            ps2data = 1'b1;
            #(PS2_CLK_PERIOD/2); ps2clk = 1'b0; #(PS2_CLK_PERIOD/2); ps2clk = 1'b1;
            ps2data = 1'b1; #(PS2_CLK_PERIOD * 2);
        end
    endtask

    task send_key;
        input [7:0] sc;
        begin
            send_ps2_byte(sc); #(PS2_CLK_PERIOD*3);
            send_ps2_byte(8'hF0); #(PS2_CLK_PERIOD*3);
            send_ps2_byte(sc); #(PS2_CLK_PERIOD*5);
        end
    endtask

    // uart monitor
    reg [7:0] cap; reg active; integer bc;
    initial begin active = 0; bc = 0; cap = 0; end
    always @(negedge RsTx) begin
        if (!active) begin
            active = 1; bc = 0; cap = 0;
            #(BIT_PERIOD/2); #(BIT_PERIOD);
            repeat(8) begin cap[bc] = RsTx; bc = bc+1; #(BIT_PERIOD); end
            $display("UART: 0x%h = '%c'", cap, cap);
            active = 0;
        end
    end

    initial begin
        ps2clk = 1'b1; ps2data = 1'b1; #1000;
        send_key(8'h1C); #2000000; // a
        send_key(8'h32); #2000000; // b
        send_key(8'h16); #2000000; // 1
        send_key(8'h29); #2000000; // space
        send_key(8'h5A); #2000000; // enter
        send_key(8'h33); send_key(8'h43); #4000000; // h i
        $finish;
    end

    initial begin $dumpfile("task2.vcd"); $dumpvars(0, tb_USB_keyboard_uart); end
endmodule

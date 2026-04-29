`timescale 1ns / 1ps

module tb_USB_keyboard_app;

    reg clk; reg ps2clk; reg ps2data;
    wire [15:0] led;

    USB_keyboard_app DUT(.clk(clk), .PS2Clk(ps2clk), .PS2Data(ps2data), .led(led));

    initial clk = 0;
    always #5 clk = ~clk;

    localparam PS2_CLK_PERIOD = 60000;

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

    initial begin
        ps2clk = 1'b1; ps2data = 1'b1; #1000;
        send_key(8'h16); #100000; $display("LED: %b", led);
        send_key(8'h1E); #100000; $display("LED: %b", led);
        send_key(8'h16); #100000; $display("LED: %b", led);
        send_key(8'h2E); #100000; $display("LED: %b", led);
        $finish;
    end

    initial begin $dumpfile("task1.vcd"); $dumpvars(0, tb_USB_keyboard_app); end
endmodule

// Demo 2: Modify the code to show steady texts on the display (20 points)
// Changes from Demo 1:
//   1. LCD_driver_static uses init[3]=8'h0C (display ON, cursor OFF, blink OFF)
//      instead of 8'h0F (cursor ON, blink ON) for steady display
//   2. Displays a fixed message "CE433 Basys 3    " (no cursor blinking)

module task2_top(clk, reset, rs, en, data_out);

input clk;
input reset;
output rs;
output en;
output [7:0] data_out;

parameter clk_param = 16000000; // ~160ms at 100MHz between characters

reg [7:0] data [15:0];  // 16-character display buffer
reg [7:0] character;     // current character to send
wire [7:0] data_in;      // wire to LCD driver
integer counter = 0;
reg [3:0] index = 0;
reg wr_en = 0;

// Instantiate the LCD driver with static display settings
LCD_driver_static lcd1(
    .clk(clk),
    .reset(reset),
    .wr_en(wr_en),
    .data_in(data_in),
    .data_out(data_out),
    .en(en),
    .rs(rs)
);

assign data_in = character;

// Set the fixed display text
// Display: "CE433 Basys 3     "
initial begin
    data[0]  = "C";
    data[1]  = "E";
    data[2]  = "4";
    data[3]  = "3";
    data[4]  = "3";
    data[5]  = " ";
    data[6]  = "L";
    data[7]  = "a";
    data[8]  = "b";
    data[9]  = " ";
    data[10] = "6";
    data[11] = " ";
    data[12] = " ";
    data[13] = " ";
    data[14] = " ";
    data[15] = " ";
end

// Counter: counts up to clk_param then resets
always @ (posedge clk)
begin
    if (reset)
        counter <= 0;
    else
    begin
        if (counter == clk_param)
            counter <= 0;
        else
            counter <= counter + 1;
    end
end

// Write enable and character index control
always @ (posedge clk)
begin
    if (reset)
    begin
        wr_en <= 0;
        index <= 0;
    end
    else
    begin
        if (counter == clk_param)
        begin
            wr_en <= 1'b1;
            character <= data[index];
            index <= index + 1'b1;
        end
        else
            wr_en <= 0;
    end
end

endmodule


// Modified LCD driver with static display (no cursor, no blink)
module LCD_driver_static(clk, reset, wr_en, data_in, data_out, en, rs);
input clk;
input reset;
input wr_en; 
input [7:0] data_in;
output reg [7:0] data_out;
output reg en;
output reg rs;

parameter clk_param = 100000;
localparam INIT=2'b00, WAIT=2'b01, WRITE=2'b10;
reg [2:0] state = INIT; 

localparam init_index = 3;
localparam char_index = 15;
reg [3:0] init_count = 0;
integer limit_count = 0;
reg [7:0] init [3:0];
reg [3:0] clear = 0;

initial begin
    init[0] = 8'h30; // 1 Line, 5x7 Dots
    init[1] = 8'h01; // Clear display
    init[2] = 8'h06; // Increment cursor (Shift cursor to right)
    init[3] = 8'h0C; // Display ON, Cursor OFF, Blink OFF (STEADY)
    rs = 1'b1;
end

always@(negedge clk) 
begin
    rs <= 1'b1;
    en <= 1'b1;
    if (reset)
    begin
        state <= INIT;
        init_count <= 0;
        limit_count <= 0;
        clear <= 0; 
    end
    else 
    begin
        case (state)
        INIT: 
        begin
            rs <= 0;
            data_out <= init[init_count];
            if (limit_count == clk_param) 
            begin
                en <= 0;
                limit_count <= 0;
                init_count <= init_count + 1'b1;
                if (init_count == init_index)
                begin
                    init_count <= 0;
                    state <= WAIT;
                end
            end
            else 
                limit_count <= limit_count + 1;
        end 

        WAIT:
            if (wr_en) 
                state <= WRITE; 

        WRITE :
        begin
            data_out <= data_in;
            if (limit_count == clk_param) 
            begin
                en <= 0;
                limit_count <= 0;
                clear <= clear + 1'b1;
                if (clear == char_index)
                begin
                    state <= INIT;
                    clear <= 0;
                end
                else
                    state <= WAIT;
            end
            else 
                limit_count <= limit_count + 1; 
        end 
        endcase
    end 
end

endmodule

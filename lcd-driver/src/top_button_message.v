// Demo 3: Use ASCII code instead of letters to display 'Hello !!' (20 points)
// Instead of using character literals like "H", "e", "l", etc.,
// we use their hexadecimal ASCII codes directly.
//
// ASCII codes used:
//   'H' = 8'h48    'e' = 8'h65    'l' = 8'h6C    'l' = 8'h6C
//   'o' = 8'h6F    ' ' = 8'h20    '!' = 8'h21    '!' = 8'h21

module task3_top(clk, reset, rs, en, data_out);

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

// Instantiate the LCD driver with static display (no cursor blink)
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

// Set display text using ASCII hex codes ONLY
// "Hello !!" followed by spaces
initial begin
    data[0]  = 8'h48; // 'H'
    data[1]  = 8'h65; // 'e'
    data[2]  = 8'h6C; // 'l'
    data[3]  = 8'h6C; // 'l'
    data[4]  = 8'h6F; // 'o'
    data[5]  = 8'h20; // ' ' (space)
    data[6]  = 8'h21; // '!'
    data[7]  = 8'h21; // '!'
    data[8]  = 8'h20; // ' ' (space)
    data[9]  = 8'h20; // ' ' (space)
    data[10] = 8'h20; // ' ' (space)
    data[11] = 8'h20; // ' ' (space)
    data[12] = 8'h20; // ' ' (space)
    data[13] = 8'h20; // ' ' (space)
    data[14] = 8'h20; // ' ' (space)
    data[15] = 8'h20; // ' ' (space)
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

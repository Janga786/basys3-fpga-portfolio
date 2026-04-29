module LCD_driver(clk,reset,wr_en,data_in,data_out,en,rs);
input clk;
input reset;
input wr_en; 
input [7:0] data_in;
output reg [7:0] data_out;
output reg en;
output reg rs;
 
parameter clk_param = 100000; // ~1ms at 100MHz (100000 * 10ns = 1ms)
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
    init[3] = 8'h0F; // Display on cursor blinking 
    rs = 1'b1;       // 1 to choose DR, 0 to choose IR
end

always@(negedge clk) 
begin
    rs <= 1'b1;
    en <= 1'b1; // Give a logic 1 to E
    // so you can pull it down later to form a falling edge
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
            rs <= 0; // select IR
            data_out <= init[init_count]; // send out instructions
            if (limit_count == clk_param) 
            begin
                en <= 0; // form a falling edge to write
                limit_count <= 0;
                init_count <= init_count + 1'b1;
                if (init_count == init_index) // when instructions are all written
                begin                         // move on to data
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

        WRITE : // rs is not given a 0 which will remain at 1 so it's writing to DR
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

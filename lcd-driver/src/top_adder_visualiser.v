// LCD adder visualiser: shows live `A + B = C` on the 16x2 LCD.
// subtraction operations with numbers and results on the LCD monitor. (40 points)
//
// Switch mapping:
//   sw[2:0] = First number displayed (connected to adder B port)
//   sw[5:3] = Second number displayed (connected to adder A port)
//   sw[6]   = cm1 (0: addition, 1: subtraction)
//   sw[7]   = show_result (0: show operation only, 1: show with result)
//
// NOTE: The adder XORs A with cm1, so it computes:
//   cm1=0: A + B (addition)
//   cm1=1: B - A (subtraction, since ~A + B + 1 = B - A)
//   Therefore sw[2:0]->B is the FIRST number and sw[5:3]->A is the SECOND number
//
// Examples from lab:
//   sw = 001_010_0_0 -> "1 + 2"         sw = 001_010_0_1 -> "1 + 2 = 3"
//   sw = 100_110_0_0 -> "-4 + -2"       sw = 100_110_0_1 -> "-4 + -2 = -6"
//   sw = 011_001_1_0 -> "3 - 1"         sw = 011_001_1_1 -> "3 - 1 = 2"
//   sw = 011_101_1_0 -> "3 - -3"        sw = 011_101_1_1 -> "3 - -3 = 6"

module task4_top(clk, reset, sw, rs, en, data_out);

input clk;
input reset;
input [7:0] sw;
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

// ---- Adder Connections ----
// sw[2:0] -> adder B port (first number on LCD)
// sw[5:3] -> adder A port (second number on LCD)
// sw[6]   -> cm1
wire [2:0] A_port = sw[5:3]; // second number -> adder A input
wire [2:0] B_port = sw[2:0]; // first number  -> adder B input
wire cm1 = sw[6];
wire show_result = sw[7];
wire [3:0] adder_data;       // 4-bit two's complement result
wire adder_OV;               // overflow flag (not used for LCD)

// Instantiate the Lab4 adder
adder adder_inst(
    .clk(clk),
    .A(A_port),
    .B(B_port),
    .cm1(cm1),
    .data(adder_data),
    .OV(adder_OV)
);

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

// ---- Determine display values for first number (B_port = sw[2:0]) ----
wire first_neg = B_port[2]; // MSB=1 means negative in 3-bit two's complement
wire [2:0] first_abs = first_neg ? (~B_port + 3'b001) : B_port;

// ---- Determine display values for second number (A_port = sw[5:3]) ----
wire second_neg = A_port[2];
wire [2:0] second_abs = second_neg ? (~A_port + 3'b001) : A_port;

// ---- Determine result sign and magnitude from adder output ----
// adder_data[3:0] is 4-bit two's complement (range: -8 to +7)
wire result_neg = adder_data[3];
wire [3:0] result_abs = result_neg ? (~adder_data + 4'b0001) : adder_data;

// ---- Operator character: '+' (8'h2B) or '-' (8'h2D) ----
wire [7:0] op_char = cm1 ? 8'h2D : 8'h2B;

// ---- Counter Logic (same pattern as textbook) ----
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

// ---- Write Enable and Character Index (same pattern as textbook) ----
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

// ---- Build Display String ----
// Layout depends on whether first and second numbers are negative
// Positive number: 1 char (e.g., "3")
// Negative number: 2 chars (e.g., "-4")
//
// Case 00 (both positive):  "A + B = R"       or "A - B = R"
// Case 10 (first neg):      "-A + B = R"      or "-A - B = R"
// Case 01 (second neg):     "A + -B = R"      or "A - -B = R"
// Case 11 (both neg):       "-A + -B = R"     or "-A - -B = R"

always @ (posedge clk)
begin
    // Initialize all 16 positions to space (8'h20)
    data[0]  <= 8'h20; data[1]  <= 8'h20; data[2]  <= 8'h20; data[3]  <= 8'h20;
    data[4]  <= 8'h20; data[5]  <= 8'h20; data[6]  <= 8'h20; data[7]  <= 8'h20;
    data[8]  <= 8'h20; data[9]  <= 8'h20; data[10] <= 8'h20; data[11] <= 8'h20;
    data[12] <= 8'h20; data[13] <= 8'h20; data[14] <= 8'h20; data[15] <= 8'h20;

    case ({first_neg, second_neg})
        2'b00: begin
            // Format: "A op B" e.g., "1 + 2"
            data[0] <= 8'h30 + {5'b0, first_abs};  // first digit
            data[1] <= 8'h20;                       // space
            data[2] <= op_char;                     // + or -
            data[3] <= 8'h20;                       // space
            data[4] <= 8'h30 + {5'b0, second_abs}; // second digit
            if (show_result) begin
                data[5] <= 8'h20;                   // space
                data[6] <= 8'h3D;                   // '='
                data[7] <= 8'h20;                   // space
                if (result_neg) begin
                    data[8] <= 8'h2D;               // '-'
                    data[9] <= 8'h30 + {4'b0, result_abs};
                end else begin
                    data[8] <= 8'h30 + {4'b0, result_abs};
                end
            end
        end

        2'b10: begin
            // Format: "-A op B" e.g., "-4 + -2" (first neg, second pos... wait)
            // Actually 2'b10 means first_neg=1, second_neg=0
            // e.g., "-4 + 2"
            data[0] <= 8'h2D;                       // '-'
            data[1] <= 8'h30 + {5'b0, first_abs};  // first digit
            data[2] <= 8'h20;                       // space
            data[3] <= op_char;                     // + or -
            data[4] <= 8'h20;                       // space
            data[5] <= 8'h30 + {5'b0, second_abs}; // second digit
            if (show_result) begin
                data[6] <= 8'h20;                   // space
                data[7] <= 8'h3D;                   // '='
                data[8] <= 8'h20;                   // space
                if (result_neg) begin
                    data[9]  <= 8'h2D;              // '-'
                    data[10] <= 8'h30 + {4'b0, result_abs};
                end else begin
                    data[9]  <= 8'h30 + {4'b0, result_abs};
                end
            end
        end

        2'b01: begin
            // Format: "A op -B" e.g., "3 - -3"
            // first_neg=0, second_neg=1
            data[0] <= 8'h30 + {5'b0, first_abs};  // first digit
            data[1] <= 8'h20;                       // space
            data[2] <= op_char;                     // + or -
            data[3] <= 8'h20;                       // space
            data[4] <= 8'h2D;                       // '-'
            data[5] <= 8'h30 + {5'b0, second_abs}; // second digit
            if (show_result) begin
                data[6] <= 8'h20;                   // space
                data[7] <= 8'h3D;                   // '='
                data[8] <= 8'h20;                   // space
                if (result_neg) begin
                    data[9]  <= 8'h2D;              // '-'
                    data[10] <= 8'h30 + {4'b0, result_abs};
                end else begin
                    data[9]  <= 8'h30 + {4'b0, result_abs};
                end
            end
        end

        2'b11: begin
            // Format: "-A op -B" e.g., "-4 + -2"
            // first_neg=1, second_neg=1
            data[0] <= 8'h2D;                       // '-'
            data[1] <= 8'h30 + {5'b0, first_abs};  // first digit
            data[2] <= 8'h20;                       // space
            data[3] <= op_char;                     // + or -
            data[4] <= 8'h20;                       // space
            data[5] <= 8'h2D;                       // '-'
            data[6] <= 8'h30 + {5'b0, second_abs}; // second digit
            if (show_result) begin
                data[7] <= 8'h20;                   // space
                data[8] <= 8'h3D;                   // '='
                data[9] <= 8'h20;                   // space
                if (result_neg) begin
                    data[10] <= 8'h2D;              // '-'
                    data[11] <= 8'h30 + {4'b0, result_abs};
                end else begin
                    data[10] <= 8'h30 + {4'b0, result_abs};
                end
            end
        end
    endcase
end

endmodule

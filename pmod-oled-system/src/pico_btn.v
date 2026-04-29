// Listing 17.2 - Modified for KCPSM6 on Basys 3
// Section 3: Added 16x2 LCD display showing a^2+b^2 in HEX
//
// LCD wiring (same as the lcd-driver project):
//   JA[0:7] -> LCD D0-D7
//   JB[0]   -> LCD EN
//   JB[2]   -> LCD RS
//   R/W     -> GND (hardwired on breadboard)
//
module pico_btn
   (
    input wire clk,
    input wire [7:0] sw,
    input wire [1:0] btn,
    output wire [3:0] an,
    output wire [7:0] sseg,
    output wire [15:0] led,
    // LCD outputs (Section 3)
    output wire [7:0] lcd_data,   // JA[0:7] -> LCD D0-D7
    output wire lcd_en,           // JB[0]   -> LCD EN
    output wire lcd_rs            // JB[2]   -> LCD RS
   );

   // signal declaration
   // KCPSM6/ROM signals
   wire [11:0] address;
   wire [17:0] instruction;
   wire        bram_enable;
   wire [7:0] port_id, out_port;
   reg [7:0] in_port;
   wire  write_strobe, k_write_strobe, read_strobe;
   wire        interrupt_ack;
   wire        rdl;
   // I/O port signals
   // output enable
   reg [6:0] en_d;
   // four-digit seven-segment led display
   reg [7:0] ds3_reg, ds2_reg, ds1_reg, ds0_reg;
   // LED registers (Section 2)
   reg [7:0] led_lo_reg, led_hi_reg;
   // Carry register (Section 3)
   reg [7:0] carry_reg;
   // two pushbuttons
   reg btnc_flag_reg, btns_flag_reg;
   wire btnc_flag_next, btns_flag_next;
   wire set_btnc_flag, set_btns_flag, clr_btn_flag;

   // =====================================================
   //  LCD signals (Section 3)
   //  Uses exact same pattern as working the lcd-driver project
   // =====================================================
   parameter lcd_clk_param = 16000000;  // same as the lcd-driver project

   reg [7:0] lcd_buf [15:0];   // 16-char display buffer
   reg [7:0] lcd_character;
   wire [7:0] lcd_data_in;
   integer lcd_counter = 0;
   reg [3:0] lcd_index = 0;
   reg lcd_wr_en = 0;

   //body
   // =====================================================
   //  I/O modules
   // =====================================================
   disp_mux disp_unit
      (.clk(clk), .reset(1'b0),
       .in3(ds3_reg), .in2(ds2_reg), .in1(ds1_reg),
       .in0(ds0_reg), .an(an), .sseg(sseg));
   debounce btnc_unit
      (.clk(clk), .reset(1'b0), .sw(btn[0]),
       .db_level(), .db_tick(set_btnc_flag));
   debounce btns_unit
      (.clk(clk), .reset(1'b0), .sw(btn[1]),
       .db_level(), .db_tick(set_btns_flag));
   // =====================================================
   //  KCPSM6 and ROM instantiation
   // =====================================================
   kcpsm6 #(
      .interrupt_vector   (12'h3FF),
      .scratch_pad_memory_size(64),
      .hwbuild            (8'h00))
   processor (
      .address            (address),
      .instruction        (instruction),
      .bram_enable        (bram_enable),
      .port_id            (port_id),
      .write_strobe       (write_strobe),
      .k_write_strobe     (k_write_strobe),
      .out_port           (out_port),
      .read_strobe        (read_strobe),
      .in_port            (in_port),
      .interrupt          (1'b0),
      .interrupt_ack      (interrupt_ack),
      .reset              (rdl),
      .sleep              (1'b0),
      .clk                (clk));

   btn_rom #(
      .C_FAMILY           ("7S"),
      .C_RAM_SIZE_KWORDS  (2),
      .C_JTAG_LOADER_ENABLE(1))
   program_rom (
      .rdl                (rdl),
      .enable             (bram_enable),
      .address            (address),
      .instruction        (instruction),
      .clk                (clk));
   // =====================================================
   //  LCD instantiation (Section 3)
   //  Same LCD_driver.v
   // =====================================================
   LCD_driver lcd1(
      .clk(clk),
      .reset(1'b0),
      .wr_en(lcd_wr_en),
      .data_in(lcd_data_in),
      .data_out(lcd_data),
      .en(lcd_en),
      .rs(lcd_rs));

   assign lcd_data_in = lcd_character;

   // =====================================================
   //  LCD feeder - exact same pattern as the lcd-driver project
   // =====================================================

   // Counter (same structure as the lcd-driver project)
   always @(posedge clk)
   begin
      if (lcd_counter == lcd_clk_param)
         lcd_counter <= 0;
      else
         lcd_counter <= lcd_counter + 1;
   end

   // Character feeder (same structure as the lcd-driver project)
   always @(posedge clk)
   begin
      if (lcd_counter == lcd_clk_param)
      begin
         lcd_wr_en <= 1'b1;
         lcd_character <= lcd_buf[lcd_index];
         lcd_index <= lcd_index + 1'b1;
      end
      else
         lcd_wr_en <= 0;
   end

   // nibble to ASCII hex conversion function
   function [7:0] hex_ascii;
      input [3:0] nibble;
      begin
         if (nibble < 10)
            hex_ascii = 8'h30 + nibble;    // '0' to '9'
         else
            hex_ascii = 8'h41 + nibble - 10; // 'A' to 'F'
      end
   endfunction

   // LCD buffer - continuously updated with current result
   // Display: "a2+b2= CXXXX  " (16 chars)
   //   C = carry hex digit, XXXX = 4 hex digits of result
   always @(posedge clk)
   begin
      lcd_buf[0]  <= 8'h61;                         // 'a'
      lcd_buf[1]  <= 8'h32;                         // '2'
      lcd_buf[2]  <= 8'h2B;                         // '+'
      lcd_buf[3]  <= 8'h62;                         // 'b'
      lcd_buf[4]  <= 8'h32;                         // '2'
      lcd_buf[5]  <= 8'h3D;                         // '='
      lcd_buf[6]  <= 8'h20;                         // ' '
      lcd_buf[7]  <= hex_ascii(carry_reg[3:0]);     // carry digit
      lcd_buf[8]  <= hex_ascii(led_hi_reg[7:4]);    // MSB upper nibble
      lcd_buf[9]  <= hex_ascii(led_hi_reg[3:0]);    // MSB lower nibble
      lcd_buf[10] <= hex_ascii(led_lo_reg[7:4]);    // LSB upper nibble
      lcd_buf[11] <= hex_ascii(led_lo_reg[3:0]);    // LSB lower nibble
      lcd_buf[12] <= 8'h20;                         // ' '
      lcd_buf[13] <= 8'h20;                         // ' '
      lcd_buf[14] <= 8'h20;                         // ' '
      lcd_buf[15] <= 8'h20;                         // ' '
   end

   // =====================================================
   //  output interface
   // =====================================================
   //    outport port id:
   //      0x00: ds0
   //      0x01: ds1
   //      0x02: ds2
   //      0x03: ds3
   //      0x04: led lower byte (Section 2)
   //      0x05: led upper byte (Section 2)
   //      0x06: carry byte (Section 3)
   // =====================================================
   // registers
   always @(posedge clk)
      begin
         if (en_d[0])
            ds0_reg <= out_port;
         if (en_d[1])
            ds1_reg <= out_port;
         if (en_d[2])
            ds2_reg <= out_port;
         if (en_d[3])
            ds3_reg <= out_port;
         if (en_d[4])
            led_lo_reg <= out_port;
         if (en_d[5])
            led_hi_reg <= out_port;
         if (en_d[6])
            carry_reg <= out_port;
      end
   // decoding circuit for enable signals
   always @*
      if (write_strobe)
         case (port_id[2:0])
            3'b000: en_d = 7'b0000001;
            3'b001: en_d = 7'b0000010;
            3'b010: en_d = 7'b0000100;
            3'b011: en_d = 7'b0001000;
            3'b100: en_d = 7'b0010000;
            3'b101: en_d = 7'b0100000;
            3'b110: en_d = 7'b1000000;
            default: en_d = 7'b0000000;
         endcase
      else
         en_d = 7'b0000000;

   // LED output (Section 2)
   assign led = {led_hi_reg, led_lo_reg};

   // =====================================================
   //  input interface
   // =====================================================
   //    input port id
   //      0x00: flag
   //      0x01: switch
   // =====================================================
   // input register (for flags)
   always @(posedge clk)
      begin
         btnc_flag_reg <= btnc_flag_next;
         btns_flag_reg <= btns_flag_next;
      end
   assign btnc_flag_next = (set_btnc_flag) ? 1'b1 :
                           (clr_btn_flag)  ? 1'b0 :
                            btnc_flag_reg;
   assign btns_flag_next = (set_btns_flag) ? 1'b1 :
                           (clr_btn_flag)  ? 1'b0 :
                            btns_flag_reg;
   // decoding circuit for clear signals
   assign clr_btn_flag = read_strobe && (port_id[0]==1'b0);
   // input multiplexing
   always @*
      case(port_id[0])
         1'b0: in_port = {6'b0, btns_flag_reg, btnc_flag_reg};
         1'b1: in_port = sw;
      endcase

endmodule

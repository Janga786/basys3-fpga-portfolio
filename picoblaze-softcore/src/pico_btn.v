// Listing 17.2 - Modified for KCPSM6 on Basys 3
// Changes from original KCPSM3 version:
//   - address is [11:0] instead of [9:0]
//   - uses kcpsm6 instantiation from design template
//   - added bram_enable, k_write_strobe, rdl, sleep signals
//   - reset connected to rdl instead of 1'b0
//   - added LED[15:0] output for Section 2
module pico_btn
   (
    input wire clk,
    input wire [7:0] sw,
    input wire [1:0] btn,
    output wire [3:0] an,
    output wire [7:0] sseg,
    output wire [15:0] led        // Section 2: 16-bit result on LEDs
   );

   // signal declaration
   // KCPSM6/ROM signals
   wire [11:0] address;           // changed from [9:0] for KCPSM6
   wire [17:0] instruction;
   wire        bram_enable;       // new for KCPSM6
   wire [7:0] port_id, out_port;
   reg [7:0] in_port;
   wire  write_strobe, k_write_strobe, read_strobe;
   wire        interrupt_ack;     // new for KCPSM6
   wire        rdl;               // new for KCPSM6
   // I/O port signals
   // output enable
   reg [5:0] en_d;
   // four-digit seven-segment led display
   reg [7:0] ds3_reg, ds2_reg, ds1_reg, ds0_reg;
   // LED registers (Section 2)
   reg [7:0] led_lo_reg, led_hi_reg;
   // two pushbuttons
   reg btnc_flag_reg, btns_flag_reg;
   wire btnc_flag_next, btns_flag_next;
   wire set_btnc_flag, set_btns_flag, clr_btn_flag;

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
      .C_RAM_SIZE_KWORDS  (1),
      .C_JTAG_LOADER_ENABLE(1))
   program_rom (
      .rdl                (rdl),
      .enable             (bram_enable),
      .address            (address),
      .instruction        (instruction),
      .clk                (clk));
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
      end
   // decoding circuit for enable signals
   always @*
      if (write_strobe)
         case (port_id[2:0])
            3'b000: en_d = 6'b000001;
            3'b001: en_d = 6'b000010;
            3'b010: en_d = 6'b000100;
            3'b011: en_d = 6'b001000;
            3'b100: en_d = 6'b010000;
            3'b101: en_d = 6'b100000;
            default: en_d = 6'b000000;
         endcase
      else
         en_d = 6'b000000;

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

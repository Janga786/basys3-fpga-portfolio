module XADCdemo(
    input CLK100MHZ,
    input vauxp6,
    input vauxn6,
    input vauxp14,
    input vauxn14,
    input vauxp7,
    input vauxn7,
    input vauxp15,
    input vauxn15,
    input vp_in,
    input vn_in,
    output reg [15:0] led,
    output sck,
    output ss,
    output mosi
);

    wire enable;                     
    wire ready;
    wire [15:0] data;
    reg [7:0] data_latch;            // the latch in the middle 
    wire SPI_busy;                   // wire created to report busy
    reg [6:0] Address_in=8'h16;
    reg send=0;

    //xadc instantiation connect the eoc_out .den_in to get continuous conversion
    xadc_wiz_0 XLXI_7 (
        .daddr_in(Address_in),       //addresses can be found in the artix 7 XADC user guide DRP register space
        .dclk_in(CLK100MHZ),  
        .den_in(enable),  
        .di_in(0),  
        .dwe_in(0),  
        .busy_out(),                  
        .vauxp6(vauxp6),
        .vauxn6(vauxn6),
        .vn_in(vn_in),  
        .vp_in(vp_in),  
        .alarm_out(),                 
        .do_out(data),  
        .eoc_out(enable),
        .channel_out(),
        .drdy_out(ready)
    );
    
    SPI_leader_transmitter spi_tx(
        .clk(CLK100MHZ),
        .data(data_latch),
        .sck(sck),
        .send(send),
        .ss(ss),
        .mosi(mosi),
        .busy(SPI_busy)
    );

    always @(posedge (CLK100MHZ)) begin
        if(ready==1)begin
            led<=data[15:8];
            data_latch<=data[15:8];//output ADC data
//          data_latch<=8'b00001111;//output a constant for debugging
        end
        if (SPI_busy==0)begin
            send<=1;
        end
        else send<=0;
    end

endmodule

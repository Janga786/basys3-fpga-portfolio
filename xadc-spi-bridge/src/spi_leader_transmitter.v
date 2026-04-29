module SPI_leader_transmitter(clk,data,send,sck,ss,mosi,busy);
parameter data_length=8;
input clk;
input [7:0] data;
input send;
output reg sck=0;
output reg ss=1;
output reg mosi;
output reg busy=0;

localparam RDY=2'b00,START=2'b01,TRANSMIT=2'b10,STOP=2'b11;
reg[1:0] state=RDY;
reg[16:0] clkdiv=0;
reg[7:0] index=0;

always @(posedge clk)
//sck
if (clkdiv == 17'd100000)// I slowed this down to 500 Hz
begin
clkdiv<=0;
sck<=~sck;
end
else clkdiv<=clkdiv + 1;

always @(negedge sck)
case (state)
RDY:
if(send)
begin
state<= START;
busy<=1;
index <= data_length -1;
end
START:
begin
ss<=0;
mosi<=data[index];
index<=index-1;
state<=TRANSMIT;
end
TRANSMIT:
begin
if(index==0)
state<= STOP;
mosi<=data[index];
index<=index-1;
end
STOP:
begin
busy<=0;
ss<=1;
state<=RDY;
end
endcase

endmodule

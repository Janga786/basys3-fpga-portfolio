const byte mosiPin=13;
const byte ssPin=12;
const byte sckPin=2;

uint8_t ssPin_state,lastssPin_state;
uint8_t data;
uint8_t i;

void setup() {
  pinMode(mosiPin,INPUT);
  pinMode(ssPin,INPUT);
  pinMode(sckPin,INPUT);
  pinMode(11,OUTPUT);
  Serial.begin(9600);
}

void loop() {
  ssPin_state = digitalRead(ssPin);
  if (ssPin_state != lastssPin_state) {
    if (ssPin_state == LOW) {
      data=0;// this fixed a lot of things
      digitalWrite(11,HIGH);
      for(i=0;i<7;i++){
        while (digitalRead(sckPin)==0);
        data|=digitalRead(mosiPin);
        data<<=1;
        while(digitalRead(sckPin)==1);
      }
      while (digitalRead(sckPin)==0);
      data|=digitalRead(mosiPin);
      while(digitalRead(sckPin)==1);
      Serial.println(data);
      digitalWrite(11,LOW);
    }
  }
  lastssPin_state=ssPin_state;
}

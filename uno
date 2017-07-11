#include <SoftwareSerial.h>
//we could have removed value1,value2 and leave only CPM to print, but for different reasons we first tried value1,value2 solution
//it didn't work, so we proceed with printing but left the older values. we didn't want to remove last day to avoid functioning problems

SoftwareSerial mySerial= SoftwareSerial(10, 11); // RX, TX
 
long count = 0;
long count1 = 0;
long CPM = 0;
long value1 = 0;
long value2 = 0;
long CPM2= 0;
 
void setup()  { 
  

setPwmFrequency(5,64); //gives the PWM 1KHZ frequency and 70% duty cycle (parameters for the function written down)
  
  
  analogWrite(5, 180);   //starts PWM on pin 9. (replace 9 with 5 if runing on 16Mhz) 180/255 = 0.7 (70% duty cycle)
  
  //calls 'countPulse' function when interupt pin goes low 
  //interupt 0 is pin 2 on the Arduino
  attachInterrupt(0,countPulse,FALLING); //the function to call when on pin 2 (0 in this case indicate pin 2) goes from 1 to 0
  
  // Open serial communications both on RX, TX and 10,11
  mySerial.begin(9600);
  Serial.begin(9600); 
  
} 
 
void loop()  { 
  
  delay(15000); //the count is incrementing during this delay
 count1 = count - 29297; //calibrating -- removing the noise
  CPM= 4 *count1; 
  if (CPM<256){
    value2=0;
    value1 = CPM % 256;  
  }
  if (CPM>255){
    value2 = CPM/ 256; //fit the value to the 8bit transmission limit of arduino uno
    value1 = CPM % 256;
   }
  if (CPM<0){   //to be sure after the calibration there are not negative values
    CPM=0;
    value1=0;
    value2=0;
  }
  CPM2=CPM; 
  Serial.println(CPM,DEC);  //print on monitor the CPM
  Serial.println("value1 is");
  Serial.println(value1);
  Serial.println("value2 is");
  Serial.println(value2);
  while(!mySerial){
    Serial.println('Problems with connection with wifiboard');
    delay(100);
  }
  if (mySerial) {
    Serial.println("sending data");   //print to inform there is communication with wifiboard
    mySerial.print('\n');       //communication with wifiboard  
    mySerial.print(value1);
    mySerial.print('\0');
    mySerial.print(value2);
    mySerial.print('\n');  

  } 
  count=0; //reset the count      //reset the parameters before end of loop
  count1=0;
  CPM=0;                            
}
 
 
void setPwmFrequency(int pin, int divisor) {
  byte mode;
  if(pin == 5 || pin == 6) {
    switch(divisor) {
      case 1: mode = 0x01; break;       // probably we need only the case 64, if we know it's sure we are using that one. otherwise we leave all cases to adapt to different geiger  
      case 8: mode = 0x02; break;       //which may require different voltage (different frequency and duty cycle from PWM)
      case 64: mode = 0x03; break;
      case 256: mode = 0x04; break;
      case 1024: mode = 0x05; break;
      default: return;
    } 
      TCCR0B = TCCR0B & 0b11111000 | mode;    //if case 1 = for PWM of 62500 HZ, case 8 = for 7812 Hz, if case 64 = for 1 KHZ if 256 = for 244 Hz, if 1024 = 61 Hz   
  } 
}
 
void countPulse(){          //increase che count when there is an ionization
  // detachInterrupt(0);        //I think this part may be useless, i am trying to keep it commented
  count++; 
 //  while(digitalRead(2)==0){
 //  }
 // attachInterrupt(0,countPulse,FALLING);
}

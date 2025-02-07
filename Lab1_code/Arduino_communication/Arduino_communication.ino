#include <Servo.h>
//#include <LiquidCrystal.h> 
//#define PIN_ANALOG_POT    A0
//const int rs = 13, en = 12, d4 = 11, d5 = 10, d6 = 9, d7 = 8;
//LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

Servo coils[4];
int pins[] = {3, 5, 6, 9};
// 3- south, 5 - west, 6 - east, 9 - north

struct  __attribute__ ((packed))signal {
  float lh;
  float lv;
  float rh;
  float rv;
} controls;

int stick_to_pwm(float stick) {
  return (90 * stick) + 90;
}

void setup() {

  Serial.begin(115200);

  for (int i = 0; i < 4; i++) {
    coils[i].attach(pins[i]);
  }
  pinMode(LED_BUILTIN, OUTPUT);
  
//   // set up the LCD's number of columns and rows:
//  lcd.begin(16, 2);
}

void loop() {

  Serial.readBytes((uint8_t*)&controls, sizeof(signal));
//  lcd.setCursor(0,0);
//  lcd.print(controls.lh);
//  lcd.print(" ");
//  lcd.print(controls.lv);
//  lcd.setCursor(0,1);
//  
//  lcd.print(controls.rh);
//  lcd.print(" ");
//  lcd.print(controls.rv);

  

   if(controls.lh<=0.3 && controls.lh>=-0.3 && controls.lv<=0.3 && controls.lv>=-0.3 && controls.rh<=0.3 && controls.rh>=-0.3 && controls.rv<=0.3 && controls.rv>=-0.3)
    {
      coils[0].write(stick_to_pwm(controls.lh));
      coils[1].write(stick_to_pwm(controls.lv));
      coils[2].write(stick_to_pwm(controls.rh));
      coils[3].write(stick_to_pwm(controls.rv));
    }
    else
    {
      coils[0].write(stick_to_pwm(0));
      coils[1].write(stick_to_pwm(0));
      coils[2].write(stick_to_pwm(0));
      coils[3].write(stick_to_pwm(0));
    }
}


void setup() {

  Serial.begin(115200);
  
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
  
}

void loop() {

  Serial.print("0-");
  Serial.println(analogRead(A0));
  delay(10);

  Serial.print("1-");
  Serial.println(analogRead(A1));
  delay(10);
  
  Serial.print("2-");
  Serial.println(analogRead(A2));
  delay(10);
  
  Serial.print("3-");
  Serial.println(analogRead(A3));
  delay(10);
  
  Serial.print("4-");
  Serial.println(analogRead(A4));
  delay(10);
  
  Serial.print("5-");
  Serial.println(analogRead(A5));
  delay(10);
  
}


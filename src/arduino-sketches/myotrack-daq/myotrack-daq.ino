#define SAMPLING_PERIOD 1000 // microseconds = 1 kHz sampling freq
#define SERIAL_PLOTTER_ENABLED 0
#define BAUD_RATE 115200 // this number is the Baudrate, and it must match the serial setup in MATLAB

int emg_pins[] = {A1, A2};   // Arduino input locations (A2 and A1 are the inputs for the EMG shield)

char message_buffer[10];    // allocate space for reading voltages

void setup()
{
  Serial.begin( BAUD_RATE); 
  delay( 10);          // evoke a delay to let the serial setup
}

void loop()
{
  unsigned long start_time = micros();  //start timer
  
  // read voltages
  // string must match in matlab code
  // use one %d per channel separated by a space
  sprintf( message_buffer,
           "%d",
           analogRead( emg_pins[0])
  );

  if (SERIAL_PLOTTER_ENABLED)
  {
    Serial.print(0);
    Serial.print("\t");
    Serial.print(1024);
    Serial.print("\t");
  }

  Serial.println(message_buffer); // write the voltages to serial
  
  unsigned long stop_time = micros() - start_time; // determine how long it took to write
  
  while( stop_time < SAMPLING_PERIOD) // enforce a maximum sampling rate of 1 kHz
  {
    stop_time = micros() - start_time;
  }
}

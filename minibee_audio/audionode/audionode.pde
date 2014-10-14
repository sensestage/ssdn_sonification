/**
 * Copyright (c) 2011 Marije Baalman. All rights reserved
 *
 * This file is part of the MiniBee API library.
 *
 * MiniBee_API is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MiniBee_API is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MiniBee_API.  If not, see <http://www.gnu.org/licenses/>.
 */


/// in the header file of the MiniBee you can disable some options to save
/// space on the MiniBee. If you don't the board may not work as it runs
/// out of RAM.

/// Wire needs to be included if TWI is enabled

// #include <Wire.h>
// 
// #include <LIS302DL.h>
// #include <ADXL345.h>
// #include <TMP102.h>
// #include <BMP085.h>
// #include <HMC5843.h>

#include <XBee.h>
#include <MiniBee_APIn.h>

#include <avr/pgmspace.h>

#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

// uint8_t ledval[3] = {0,0,0};

enum {
	WF_TRI,
	WF_SAW,
	WF_SAWINV,
	WF_PUL,
	WF_DC,
	WF_SIN,
	WF_NOI
};

enum {
	ENV_ATTACK,
	ENV_DECAY,
	ENV_REST,
	ENV_DC
};

#define NUMOSC 3
#define AUDIO_PWM_PIN       11
#define PWM_VALUE_DESTINATION     OCR2A
#define PWM_INTERRUPT TIMER2_OVF_vect

// volatile byte audiosample;
byte audiosample;
// volatile boolean calcaudiosample = true;
// int audiorms;

boolean usenoise = true;

uint8_t totalamplitude;

// filter:
uint8_t coefA0 = 127; // == 1
uint8_t coefA1 = 0; // == 0
uint8_t coefA2 = 0; // == 0
uint8_t coefB1 = 0; // == 0
uint8_t coefB2 = 0; // == 0
boolean filtersigns = B00011111; // all positive

#define AMPTHRESHOLD 32
#define AMPLONGTHRESHOLD 200

// uint16_t pwm_count;
uint8_t pwm_count = 0; // more efficient to update!
#define CONTROLRATE 50
uint8_t pwm_count2 = 0; // more efficient to update!
// #define CONTROLRATE 100

const int timerPrescale=1<<9;

const unsigned int LUTsize = 1<<8; // Look Up Table size: has to be power of 2 so that the modulo LUTsize
                                   // can be done by picking bits from the phase avoiding arithmetic
// uint8_t profiletable[LUTsize] PROGMEM = {
//   0, 22, 43, 62, 79, 96, 111, 125, 137, 149, 160, 170, 180, 189, 197, 204, 211, 217, 223, 228, 233, 238, 242, 246, 250, 253, 254, 251, 249, 246, 244, 241, 239, 236, 234, 232, 229, 227, 225, 222, 220, 218, 216, 213, 211, 209, 207, 205, 202, 200, 198, 196, 194, 192, 190, 188, 186, 184, 182, 180, 178, 177, 175, 173, 171, 169, 167, 166, 164, 162, 160, 158, 157, 155, 153, 152, 150, 148, 147, 145, 143, 142, 140, 139, 137, 136, 134, 133, 131, 130, 128, 127, 125, 124, 122, 121, 120, 118, 117, 116, 114, 113, 112, 110, 109, 108, 106, 105, 104, 103, 101, 100, 99, 98, 96, 95, 94, 93, 92, 91, 90, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 61, 60, 59, 58, 57, 56, 55, 55, 54, 53, 52, 51, 51, 50, 49, 48, 48, 47, 46, 45, 45, 44, 43, 42, 42, 41, 40, 40, 39, 38, 37, 37, 36, 35, 35, 34, 34, 33, 32, 32, 31, 30, 30, 29, 29, 28, 27, 27, 26, 26, 25, 25, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17, 16, 16, 15, 15, 14, 14, 13, 13, 12, 12, 11, 11, 11, 10, 10, 9, 9, 8, 8, 8, 7, 7, 6, 6, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 1, 1, 1, 0, 0 
// };

const uint8_t sintable[LUTsize] PROGMEM = { 127, 130, 133, 136, 139, 143, 146, 149, 152, 155, 158, 161, 164, 167, 170, 173, 176, 179, 182, 184, 187, 190, 193, 195, 198, 200, 203, 205, 208, 210, 213, 215, 217, 219, 221, 224, 226, 228, 229, 231, 233, 235, 236, 238, 239, 241, 242, 244, 245, 246, 247, 248, 249, 250, 251, 251, 252, 253, 253, 254, 254, 254, 254, 254, 255, 254, 254, 254, 254, 254, 253, 253, 252, 251, 251, 250, 249, 248, 247, 246, 245, 244, 242, 241, 239, 238, 236, 235, 233, 231, 229, 228, 226, 224, 221, 219, 217, 215, 213, 210, 208, 205, 203, 200, 198, 195, 193, 190, 187, 184, 182, 179, 176, 173, 170, 167, 164, 161, 158, 155, 152, 149, 146, 143, 139, 136, 133, 130, 127, 124, 121, 118, 115, 111, 108, 105, 102, 99, 96, 93, 90, 87, 84, 81, 78, 75, 72, 70, 67, 64, 61, 59, 56, 54, 51, 49, 46, 44, 41, 39, 37, 35, 33, 30, 28, 26, 25, 23, 21, 19, 18, 16, 15, 13, 12, 10, 9, 8, 7, 6, 5, 4, 3, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 15, 16, 18, 19, 21, 23, 25, 26, 28, 30, 33, 35, 37, 39, 41, 44, 46, 49, 51, 54, 56, 59, 61, 64, 67, 70, 72, 75, 78, 81, 84, 87, 90, 93, 96, 99, 102, 105, 108, 111, 115, 118, 121, 124 };

const uint8_t triangletable[LUTsize] PROGMEM = { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 146, 148, 150, 152, 154, 156, 158, 160, 162, 164, 166, 168, 170, 172, 174, 176, 178, 180, 182, 184, 186, 188, 190, 192, 194, 196, 198, 200, 202, 204, 206, 208, 210, 212, 214, 216, 218, 220, 222, 224, 226, 228, 230, 232, 234, 236, 238, 240, 242, 244, 246, 248, 250, 252, 254, 255, 253, 251, 249, 247, 245, 243, 241, 239, 237, 235, 233, 231, 229, 227, 225, 223, 221, 219, 217, 215, 213, 211, 209, 207, 205, 203, 201, 199, 197, 195, 193, 191, 189, 187, 185, 183, 181, 179, 177, 175, 173, 171, 169, 167, 165, 163, 161, 159, 157, 155, 153, 151, 149, 147, 145, 143, 141, 139, 137, 135, 133, 131, 129, 127, 125, 123, 121, 119, 117, 115, 113, 111, 109, 107, 105, 103, 101, 99, 97, 95, 93, 91, 89, 87, 85, 83, 81, 79, 77, 75, 73, 71, 69, 67, 65, 63, 61, 59, 57, 55, 53, 51, 49, 47, 45, 43, 41, 39, 37, 35, 33, 31, 29, 27, 25, 23, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1 };

const uint8_t sawtable[LUTsize] PROGMEM = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 };

const uint8_t sawinvtable[LUTsize] PROGMEM = { 255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240, 239, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 228, 227, 226, 225, 224, 223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208, 207, 206, 205, 204, 203, 202, 201, 200, 199, 198, 197, 196, 195, 194, 193, 192, 191, 190, 189, 188, 187, 186, 185, 184, 183, 182, 181, 180, 179, 178, 177, 176, 175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162, 161, 160, 159, 158, 157, 156, 155, 154, 153, 152, 151, 150, 149, 148, 147, 146, 145, 144, 143, 142, 141, 140, 139, 138, 137, 136, 135, 134, 133, 132, 131, 130, 129, 128, 127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112, 111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 99, 98, 97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 87, 86, 85, 84, 83, 82, 81, 80, 79, 78, 77, 76, 75, 74, 73, 72, 71, 70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };

const uint8_t pulsetable[LUTsize] PROGMEM = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

const uint8_t dctable[LUTsize] PROGMEM = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };

struct oscillator {
    uint8_t waveform;
    boolean repeat; // on/off
//     uint8_t useenv; // on/off
    
    uint16_t duration;
    uint16_t duration_set;
    uint16_t duration_random;

//    uint8_t phase;
//     uint8_t phase_increment;
    uint16_t phase;
    uint16_t phase_increment;
    
    uint16_t phase_increment_set;
    uint16_t phase_increment_random;
    uint8_t randommode;
    boolean randomset;
//     uint32_t phase;
//     int32_t phase_increment;
    
    uint8_t amplitude; // is volume
    uint8_t offset;    // is dc offset

//     uint8_t duty; // for pulse wave

    uint8_t current_amplitude; // is huidig volume
    uint8_t profile_amplitude; // is current profile based amplitude

    uint8_t attack;
    uint8_t decay;
    uint8_t env_phase;

//     uint8_t *profile;
    uint8_t profile_pwm_steps; // "control rate of envelope, how often we update the step, thus relates to duration"
    uint16_t profile_step;      // current step in envelope

    const uint8_t *wavetable;
} osc[NUMOSC];

const int fractionalbits = 16; // 16 bits fractional phase
// compute a phase increment from a frequency
// unsigned long phaseinc(float frequency_in_Hz)
unsigned int phaseinc(float frequency_in_Hz)
{
   return LUTsize *(((uint16_t)1)<<fractionalbits) * frequency_in_Hz/(F_CPU/timerPrescale);
}

volatile uint8_t calcLdr = 0;
#define LDRINTERVAL 13

// uint8_t ledcount = 0;
// 16kHz / 16 = 1000 Hz sampling rate for LED accuracy = 1 ms per on flash
// #define MAXLEDCOUNT 6

// volatile uint8_t calcLed = 0;
// #define LEDINTERVAL 20

// uint8_t curled1 = 0;
// volatile uint8_t curled2 = 0;

// struct ledoscillator {
//     uint8_t curval;
//     uint8_t run;
//     uint16_t duration;
//     uint16_t duration_set;
//     uint16_t duration_random;
//     
//     uint8_t waveform;    
//     uint8_t repeat;
//   
//     uint16_t phase;
//     uint16_t phase_increment;
// 
//     uint16_t phase_increment_set;
//     uint16_t phase_increment_random;
//     uint8_t randommode;
//     boolean randomset;
// 
//     uint16_t duty; // for pulse wave
//     
//     uint8_t bottom;
//     uint8_t top;
//     
//     uint8_t range; // calculated
//     uint16_t time;
//         
// //     uint8_t *wavetable;
// } ledosc[3];
// 

MiniBee_API Bee = MiniBee_API();

// #define MAXSENDCOUNT 1600
// int sendcount = 0;

#define MAXSENDCOUNT 80
uint8_t sendcount = 0;
// uint8_t amphigh = 0;

// uint8_t ldrvalue[3] = { 0, 0, 0 };
// int ldrvalue[3] = { 0, 0, 0 };
// uint16_t maMicFix = 0;

// int micin;

// #define MAXMA 128
// uint8_t cntMA = 0;
// uint8_t sizeMA = MAXMA;

// uint8_t samplesMic[MAXMA];

// int aup = 50;
// int adown = 99;
// int envtrack = 0;
// int aup2, adown2;

// #define MAXMAL 64
// uint8_t ldrSizeMA[3];
// uint8_t ldrCntMA[3] = {0,0,0};
// uint8_t ldrSamples[3][MAXMAL];


uint8_t sendRead = 0;
#define SENDREADRATIO 4

// uint16_t adcsamples = 0;
// uint16_t adcsampled = 0;

// volatile uint8_t adcvalue[4]  = { 0, 0, 0, 0 };
// byte curADC = 0;
// byte curLDR = 0;
// volatile boolean startnewadc = true;
// boolean measureLDR = false;
// byte newadc;


/// this will be our parser for the custom messages we will send:
/// msg[0] and msg[1] will be msg type ('E') and message ID
/// the remainder are the actual contents of the message
/// if you want to send several kinds of messages, you can e.g.
/// switch based on msg[2] for message type
void customMsgParser( uint8_t * msg, uint8_t size, uint16_t source ){
  uint8_t id;
  uint8_t offset;
  switch( msg[2] ){
//     case 'I': // input parameter
//        switch( msg[3] ){
// 	case 'a': // amplitude tracker
// 	    aup = msg[4];
// 	    adown = msg[5];
// 	    aup2 = 100 - aup;
// 	    adown2 = 100 - adown;
// 	  break;
//        }
//        break;
    case 'S': // sound parameter
      switch( msg[3] ){
	case 'A': // change all amplitudes
	    osc[0].amplitude = msg[4];
	    osc[1].amplitude = msg[5];
	    osc[2].amplitude = msg[6];
// 	    osc[3].amplitude = msg[7];
	  break;
	case 'a': // change all amplitudes
	    id = msg[4];
	    osc[ id ].amplitude = msg[5];
	  break;
	case 'E':
	    osc[0].env_phase = msg[4]; // 3 is dc, means no envelope
	    osc[0].attack = msg[5];
	    osc[0].decay = msg[6];
	    osc[0].profile_pwm_steps = msg[7];
	    osc[1].env_phase = msg[8]; // 3 is dc, means no envelope
	    osc[1].attack = msg[9];
	    osc[1].decay = msg[10];
	    osc[1].profile_pwm_steps = msg[11];
	    osc[2].env_phase = msg[12]; // 3 is dc, means no envelope
	    osc[2].attack = msg[13];
	    osc[2].decay = msg[14];
	    osc[2].profile_pwm_steps = msg[15];    
// 	    osc[3].env_phase = msg[13]; // 3 is dc, means no envelope
// 	    osc[3].attack = msg[14];
// 	    osc[3].decay = msg[15]; 
	  break;
	case 'e':
	    id = msg[4];
	    osc[ id ].env_phase = msg[5]; // 3 is dc, means no envelope
	    osc[ id ].attack = msg[6];
	    osc[ id ].decay = msg[7];
	    osc[ id ].profile_pwm_steps = msg[8];
	  break;
	case 'F': // change all frequencies
	    osc[0].phase_increment_set = msg[4]*256 + msg[5];
	    osc[1].phase_increment_set = msg[6]*256 + msg[7];
	    osc[2].phase_increment_set = msg[8]*256 + msg[9];
	    osc[0].randomset = false;
	    osc[1].randomset = false;
	    osc[2].randomset = false;
	    set_phaseinc( 0 );
	    set_phaseinc( 1 );
	    set_phaseinc( 2 );
// 	    osc[3].phase_increment = msg[10]*256 + msg[11];
	    break;
	case 'f': // change one frequency
	    id = msg[4];
	    osc[ id ].phase_increment_set = msg[5]*256 + msg[6];
	    osc[ id ].randomset = false;
	    set_phaseinc( id );
	  break;
	case 'H': // change repeat
	    osc[0].repeat = msg[4];
	    osc[1].repeat = msg[5];
	    osc[2].repeat = msg[6];
// 	    osc[3].repeat = msg[7];
	  break;
	case 'h':
	    id = msg[4];
	    osc[ id ].repeat = msg[5];
	  break;
	case 'L': // change duration
	    osc[0].duration_set = msg[4]*256 + msg[5];
	    osc[1].duration_set = msg[6]*256 + msg[7];
	    osc[2].duration_set = msg[8]*256 + msg[9];
	    osc[0].randomset = false;
	    osc[1].randomset = false;
	    osc[2].randomset = false;
	    set_dur( 0 );
	    set_dur( 1 );
	    set_dur( 2 );
	    osc[0].randomset = true;
	    osc[1].randomset = true;
	    osc[2].randomset = true;
// 	    osc[3].duration = msg[10]*256 + msg[11];
	    break;
	case 'l': // change duration
	    id = msg[4];
	    osc[ id ].duration = msg[5]*256 + msg[6];
	    osc[ id ].randomset = false;
	    set_dur( id );
	    osc[ id ].randomset = true;
	  break;
	case 'O': // change all offsets
	    osc[0].offset = msg[4];
	    osc[1].offset = msg[5];
	    osc[2].offset = msg[6];
// 	    osc[3].offset = msg[7];
	  break;
	case 'o': // change all amplitudes
	    id = msg[4];
	    osc[ id ].offset = msg[5];
	  break;
	case 'P': // change poles and zeros
	    coefA0 = msg[4];
	    coefA1 = msg[5];
	    coefA2 = msg[6];
	    coefB1 = msg[7];
	    coefB2 = msg[8];
	    filtersigns = msg[9];
// 	    osc[3].offset = msg[7];
	  break;
	case 'R': // change all randomness
	    osc[0].randommode = ( msg[4] & 0x03 );
	    osc[0].phase_increment_random = msg[5]*256 + msg[6];
	    osc[0].duration_random = msg[7]*256 + msg[8];
	    osc[1].randommode = ( (msg[4]>>2) & 0x03 );
	    osc[1].phase_increment_random = msg[9]*256 + msg[10];
	    osc[1].duration_random = msg[11]*256 + msg[12];
	    osc[2].randommode = ( (msg[4]>>4) & 0x03 );
	    osc[2].phase_increment_random = msg[13]*256 + msg[14];
	    osc[2].duration_random = msg[15]*256 + msg[16];
	    osc[0].randomset = false;
	    osc[1].randomset = false;
	    osc[2].randomset = false;
	    set_dur(0);
	    set_dur(1);
	    set_dur(2);
	    set_phaseinc(0);
	    set_phaseinc(1);
	    set_phaseinc(2);
	  break;
	case 'r': // change randomness
	    id = msg[4];
	    osc[ id ].phase_increment_random = msg[5]*256+msg[6];
	    osc[ id ].duration_random = msg[7]*256+msg[8];
	    osc[ id ].randommode = msg[9];
	    osc[ id ].randomset = false;
	    set_dur( id );
	    set_phaseinc(id);
	  break;
	case 's': // settings
	    id = msg[4];
	    osc[ id ].repeat = bit_is_set( msg[5], 7 ); // 1 bit
	    osc[ id ].randommode = (msg[5] >> 5 ) & 0x03; // 2 bits (bits 5,6)
	    osc[ id ].env_phase =  (msg[5] >> 3 ) & 0x03; // 2 bits (bits 3,4)
	    set_waveform( id, msg[5] & 0x07 ); // 3 bits (last three; bits 0,1,2)
	    osc[ id ].amplitude = msg[6];
	    osc[ id ].offset = msg[7];
	    osc[ id ].duration_set = msg[8]*256 + msg[9];
	    osc[ id ].attack = msg[10];
	    osc[ id ].decay = msg[11];
	    osc[ id ].profile_pwm_steps = msg[12];
	    osc[ id ].phase_increment_set = msg[13]*256 + msg[14];
	    osc[ id ].phase_increment_random = msg[15]*256 + msg[16];
	    osc[ id ].duration_random = msg[17]*256 + msg[18];
// 	    osc[ id ].duty = msg[13]; // IS THIS ONE STILL USED??
	    osc[ id ].profile_step = osc[ id ].duration + 1;
	    osc[ id ].randomset = false;
	    set_dur( id );
	    set_phaseinc( id );
	  break;
	case 'S': // settings
	    //offset = 4;
	    for ( id = 0; id<NUMOSC; id++ ){
	      offset = 4 + (id*14);
	      osc[ id ].repeat = bit_is_set( msg[offset], 7 );
	      osc[ id ].randommode = ( msg[offset] >> 5 ) & 0x03; // 2 bits
	      osc[ id ].env_phase = ( msg[offset] >> 3 ) & 0x03; // 2 bits
	      set_waveform( id, msg[offset] & 0x07 ); // 3 bits
	      offset++;
	      osc[ id ].amplitude = msg[offset++];
	      osc[ id ].offset = msg[offset++];
	      osc[ id ].duration_set = msg[offset++]*256 + msg[offset++];
	      osc[ id ].attack = msg[offset++];
	      osc[ id ].decay = msg[offset++];
	      osc[ id ].profile_pwm_steps = msg[offset++];
	      osc[ id ].phase_increment_set = msg[offset++]*256 + msg[offset++];
	      osc[ id ].phase_increment_random = msg[offset++]*256 + msg[offset++];
	      osc[ id ].duration_random = msg[offset++]*256 + msg[offset++];
// 	      osc[ id ].duty = msg[offset++];
	      osc[ id ].profile_step = osc[ id ].duration + 1;
	      osc[ id ].randomset = false;
	      set_dur(id);
	      set_phaseinc(id);
	    }
	    coefA0 = msg[offset++];
	    coefA1 = msg[offset++];
	    coefA2 = msg[offset++];
	    coefB1 = msg[offset++];
	    coefB2 = msg[offset++];
	    filtersigns = msg[offset];
	  break;
	case 'T': // trigger all oscillators
// 	    osc[0].env_phase = ENV_ATTACK;
// 	    osc[1].env_phase = ENV_ATTACK;
// 	    osc[2].env_phase = ENV_ATTACK;
// 	    osc[0].profile_step = osc[0].duration + 1;
// 	    osc[1].profile_step = osc[1].duration + 1;
// 	    osc[2].profile_step = osc[2].duration + 1;
	    set_dur(0);
	    set_dur(1);
	    set_dur(2);
	    set_phaseinc(0);
	    set_phaseinc(1);
	    set_phaseinc(2);
	    osc[0].profile_step = 0; // start envelope from start
	    osc[1].profile_step = 0; // start envelope from start
	    osc[2].profile_step = 0; // start envelope from start
	    osc[0].env_phase = ENV_ATTACK;
	    osc[1].env_phase = ENV_ATTACK;
	    osc[2].env_phase = ENV_ATTACK;
// 	    osc[3].profile_step = osc[3].duration + 1;
	  break;
	case 't': // trigger specific oscillator
	    id = msg[4];
// 	    osc[ id ].env_phase = ENV_ATTACK;
// 	    osc[ id ].profile_step = osc[ id ].duration + 1;
	    set_dur(id);
	    set_phaseinc(id);
	    osc[ id ].profile_step = 0; // start envelope from start
	    osc[ id ].env_phase = ENV_ATTACK;
	  break;
	case 'W': // waveform
	    set_waveform( 0, msg[4] );
	    set_waveform( 1, msg[5] );
	    set_waveform( 2, msg[6] );
	  break;
	case 'w':
	    set_waveform( msg[4], msg[5] );
	  break;
      }
      break;
  }
}

void set_phaseinc( uint8_t thisosc ){
    switch( osc[ thisosc ].randommode ){
      case 1: // random once at setting
	if ( !osc[ thisosc ].randomset ){
	  osc[ thisosc ].phase_increment = osc[ thisosc ].phase_increment_set;
	  osc[ thisosc ].phase_increment += ( (osc[  thisosc ].phase_increment_random * get_random()) >> 8 );
	  osc[ thisosc ].randomset = true;
	} // don't change phase increment if already set
	break;
      case 2: // random each time
	osc[ thisosc ].phase_increment = osc[ thisosc ].phase_increment_set;
	osc[ thisosc ].phase_increment += ( (osc[  thisosc ].phase_increment_random * get_random()) >> 8 );
// 	osc[ thisosc ].phase_increment += osc[ thisosc ].phase_increment_random * get_random();
	break;
      case 0: // no random
	osc[ thisosc ].phase_increment = osc[ thisosc ].phase_increment_set;
	break;
    }
}

void set_dur( uint8_t thisosc ){
    switch( osc[ thisosc ].randommode ){
      case 1: // random once at setting
	if ( !osc[ thisosc ].randomset ){
	  osc[ thisosc ].duration = osc[ thisosc ].duration_set;
	  osc[ thisosc ].duration += ( (osc[  thisosc ].duration_random * get_random()) >> 8 );
// 	  osc[ thisosc ].randomset = true;
	} // don't change phase increment if already set
	break;
      case 2: // random each time
	osc[ thisosc ].duration = osc[ thisosc ].duration_set;
	osc[ thisosc ].duration += ( (osc[  thisosc ].duration_random * get_random()) >> 8 );
// 	osc[ thisosc ].phase_increment += osc[ thisosc ].phase_increment_random * get_random();
	break;
      case 0: // no random
	osc[ thisosc ].duration = osc[ thisosc ].duration_set;
	break;
    }
}

void set_waveform( uint8_t thisosc, uint8_t waveform ){
  osc[ thisosc ].waveform = waveform;
  switch( waveform ){
     case WF_SIN:
       osc[ thisosc ].wavetable = sintable;
       break;
     case WF_TRI:
       osc[ thisosc ].wavetable = triangletable;
       break;
     case WF_SAW:
       osc[ thisosc ].wavetable = sawtable;
       break;
     case WF_SAWINV:
       osc[ thisosc ].wavetable = sawinvtable;
       break;
     case WF_PUL:
       osc[ thisosc ].wavetable = pulsetable;
       break;
     case WF_DC:
       osc[ thisosc ].wavetable = dctable;
       break;
   }
   if ( (thisosc == 2) && (waveform == WF_NOI) ){
     usenoise = true;
   } else {
     usenoise = false;
   }
}

uint16_t randomseed = 1;

uint8_t get_random(){
    uint8_t newbit;
    newbit = 0;
    if(randomseed & 0x8000) newbit ^= 1;
    if(randomseed & 0x0100) newbit ^= 1;
    if(randomseed & 0x0040) newbit ^= 1;
    if(randomseed & 0x0200) newbit ^= 1;
    randomseed = (randomseed << 1) | newbit;
    return (randomseed>>8);
}

// void set_frequency( int thisosc, int freq10 ){
//   float freq = (float) freq10 / 10.0;
//   osc[ thisosc ].phase_increment = phaseinc( freq );
// }

// uint8_t myConfig[] = { 'C', 0, 1, 0, 100, 1, // configuration, null, config id, msgInt high byte, msgInt low byte, samples per message
//   NotUsed, NotUsed, Custom, Custom, NotUsed, NotUsed, // D3 to D8 (D4 is reserved for status LED)
//   Custom, NotUsed, Custom, NotUsed, NotUsed,  // D9,D10,D11,D12,D13 (D12, D13 are also reserved)
//   NotUsed, Custom, NotUsed, Custom, NotUsed, NotUsed, Custom, Custom, // A0, A1, A2, A3, A4, A5, A6, A7
//   0
// };

void setup() {
//   Bee.setRemoteConfig( 1 ); // 1 is id is remotely configured, configuration bytes are locally configured

  Bee.setup(57600, 'D' ); // arguments are the baudrate, and the board revision
  
//   Bee.setCustomPin( 5, 0 );
//   Bee.setCustomPin( 6, 0 );
//   Bee.setCustomPin( 9, 0 );
  Bee.setCustomPin( 11, 0 );
  // analog pins:
//   Bee.setCustomPin( 18, 2 );
//   Bee.setCustomPin( 18, 1 );
//   Bee.setCustomPin( 15, 1 );
//   Bee.setCustomPin( 17, 1 );
//   Bee.setCustomPin( 19, 1 );
//   Bee.setCustomPin( 15, 2 );
//   Bee.setCustomPin( 17, 2 );
//   Bee.setCustomPin( 19, 2 );

//   Bee.setCustomInput( 1, 2 ); // adcsamples
//   Bee.setCustomInput( 1, 1 ); // totalamplitude

  // set the custom message function
  Bee.setCustomCall( &customMsgParser );
//   Bee.readConfigMsg( myConfig, 26 );

//   pinMode( 5, OUTPUT );
//   pinMode( 6, OUTPUT );
//   pinMode( 9, OUTPUT );
  
//   aup2 = 100 - aup;
//   adown2 = 100 - adown;

  for (uint8_t i=0; i<NUMOSC; i++) {
    osc[i].phase_increment_set = 2560;
    osc[i].phase_increment_random = 0;
    osc[i].randommode = 0;
    osc[i].repeat = 0;
    osc[i].amplitude = 0; //127; //127 - i*32;
    osc[i].offset = 0;
    osc[i].duration_set = 512;
    osc[i].duration_random = 0;

    osc[i].phase_increment = 2560;
    osc[i].duration = 512;
    osc[i].randomset = false;
    osc[i].phase = 0;
//     osc[i].duty = 127;
    
//     osc[i].profile = profiletable;
    osc[i].profile_step = 0;
    osc[i].profile_amplitude = 0;

    osc[i].profile_pwm_steps = 20;
    osc[i].env_phase = ENV_ATTACK;
    osc[i].attack = 10;
    osc[i].decay = 5;
  }
  set_waveform( 0, WF_SIN );
  set_waveform( 1, WF_SIN );
  set_waveform( 2, WF_SIN );
  
//   osc[0].amplitude = 0; // phase modulation
//   osc[0].env_phase = ENV_ATTACK;
  osc[0].phase_increment = 50;
//   osc[1].amplitude = 127; // amplitude modulation
//   osc[1].env_phase = ENV_DC;
  osc[1].phase_increment = 20;
  
  noInterrupts();

  // set adc prescaler  to 64 for 19kHz sampling frequency
  // 12 MHz / 64 = 187500 Hz / 13 cycles per conversion = 19230 Hz
//   cbi(ADCSRA, ADPS2);
//   sbi(ADCSRA, ADPS1);
//   sbi(ADCSRA, ADPS0);
// 
//   sbi(ADMUX,ADLAR);  // 8-Bit ADC in ADCH Register --- 
//   sbi(ADMUX,REFS0);  // VCC Reference
//   cbi(ADMUX,REFS1);
// //   cbi(ADMUX,ADLAR);  // 10-Bit ADC in ADCH Register --- 
// 
//   cbi(ADMUX,MUX0);   // Set Input Multiplexer to Channel 6
//   sbi(ADMUX,MUX1);
//   sbi(ADMUX,MUX2);
//   cbi(ADMUX,MUX3);
// 
//   sbi(ADCSRA,ADSC); // start next conversion

 // Set up PWM  with Clock/256 (i.e.  31.25kHz on Arduino 16MHz;
 // and  phase accurate
  TCCR2A = _BV(COM2B1) | _BV(COM2A1) | _BV(WGM21) | _BV(WGM20);
  //   TCCR2A = _BV(COM2A1) | _BV(WGM20);
  TCCR2B = _BV(CS20);
  TIMSK2 = _BV(TOIE2);
//   sbi (TIMSK2,TOIE2);              // enable Timer2 Interrupt
  pinMode(AUDIO_PWM_PIN,OUTPUT);
  
  interrupts();
}

void loop() {
  uint16_t tempAmp;
  uint8_t envamp;
//   totalamplitude = 0;
  if ( pwm_count >= CONTROLRATE ){
    pwm_count2++;
    pwm_count = 0;
//     if ( pwm_count2 >= CONTROLRATE2 ){
    for ( uint8_t i=0; i<NUMOSC; i++ ){
      if ((pwm_count2 % osc[i].profile_pwm_steps) == 0) { // update amplitude only every pwm-steps, so pwm_steps is a measure for duration!
	switch( osc[i].env_phase ){
	  case ENV_ATTACK:
	      osc[i].profile_amplitude += osc[i].attack;
	      if ( osc[i].profile_amplitude > (255 - osc[i].attack) ){
		osc[i].env_phase = ENV_DECAY;
	      }
	      tempAmp = osc[i].profile_amplitude * osc[i].amplitude;
	      osc[i].current_amplitude = (uint8_t) (tempAmp >> 8);
	    break;
	  case ENV_DECAY:
	      osc[i].profile_amplitude -= osc[i].decay;
	      if ( osc[i].profile_amplitude < osc[i].decay ){
		osc[i].env_phase = ENV_REST;
	      }
	      tempAmp = osc[i].profile_amplitude * osc[i].amplitude;
	      osc[i].current_amplitude = (uint8_t) (tempAmp >> 8);
	    break;
	  case ENV_REST:   
	      osc[i].current_amplitude = 0;
	      osc[i].profile_amplitude = 0;
	      if ( osc[i].repeat ){
		if ( osc[i].profile_step > osc[i].duration ){
		  set_dur(i);
		  set_phaseinc(i);
		  osc[i].profile_step = 0; // start envelope from start
		  osc[i].env_phase = ENV_ATTACK;
		}
	      }
	    break;
	  case ENV_DC:   
	      osc[i].current_amplitude = osc[i].amplitude;
	    break;
	}
	osc[i].profile_step++;
//       totalamplitude += osc[i].current_amplitude;
      }
    }
  }
  totalamplitude = osc[2].current_amplitude; // + osc[3].current_amplitude;

//   if ( calcLdr >= LDRINTERVAL ){
//     startnewadc = true;
//     calcLdr = 0;
//       int newval;
// //       measureLDR = true; // next one will be an LDR measurement
//       curADC = 3;
//       newval = int( newadc );
//       newval = newval - 127;
//       newval = abs( newval ); // absolute value
//       if ( envtrack < newval ){
// 	envtrack *= aup;
// 	envtrack += aup2*newval;
//       } else {
// 	envtrack *= adown;
// 	envtrack += adown2*newval;  
//       }
//       envtrack = envtrack / 100;
// //       curADC = 3;
//       ADMUX = B01100110;
//   }
    
  sendcount++;
  if ( (sendcount > MAXSENDCOUNT) ){
    	Bee.loopReadOnly();
  }
//     if ( (totalamplitude > AMPTHRESHOLD) && (amphigh < AMPLONGTHRESHOLD) ){
//       amphigh++;
//     } else {
//       amphigh=0;
//       sendRead++;
//       sendcount = 0;
//       if ( (sendRead >= SENDREADRATIO) ){
// 	sendRead = 0;
// //       maMicFix = 20;
// //       for ( uint8_t i=0; i < 3; i++ ){
// // 	ldrvalue[i] = adcvalue[i];
// 	// TESTING:
// //  	ldrvalue[i] = ledval[i];
// //       }
//       // add our customly measured data to the data package:
// // 	Bee.addCustomData( &maMicFix, 1 );
// 	envamp = (uint8_t) envtrack;
// 	Bee.addCustomData( &envamp, 1 );
// 	Bee.addCustomData( &totalamplitude, 1 );
// // 	adcsamples = 0;
// 	// do a loop step of the remaining firmware:
// 	Bee.loopStep( false );
//       } else {
// 	Bee.loopReadOnly();
//       }
//     }
//   }
  
//   if ( startnewadc ){
//     startnewadc = false;  
//     if ( bit_is_clear( ADCSRA, ADSC ) ){
//     // ADC
//       sbi(ADCSRA,ADSC);              // start next conversion
//     }
//   }

//    delay(1);
}


uint16_t noiseseed = 1;

uint8_t insample = 0;
uint8_t previnsample = 0;
uint8_t prevoutsample = 0;
uint8_t previnsample2 = 0;
uint8_t prevoutsample2 = 0;

boolean calcaudiosample;

// union twobyte_t 
// {
// 	uint16_t	i;
// 	uint8_t	        b[2];
// } valueA;

ISR(TIMER2_OVF_vect) {
  uint8_t value;
  uint16_t valueA;
//   long filterValue;

  uint8_t valueO1;
  uint8_t valueO2;
  uint8_t valueO3;
// uint8_t valueN1;
  uint8_t newbit;
//   uint16_t valueA0;
  uint16_t valueA1;
  uint16_t valueA2;
  uint16_t valueB1;
  uint16_t valueB2;

  // write new sample to pwm
  PWM_VALUE_DESTINATION = audiosample;
//   sendcount++;
//   calcLed++;
  calcLdr++;
//   adcsamples++;
    
//   if ( bit_is_clear( ADCSRA, ADSC ) ){
//     // write new adc sample to variable
//     newadc=ADCH;   // get ADC channel 0
// //     startnewadc = true;
// //     adcsampled = adcsamples;
// //     adcsamples = 0;
//   }

/// --------- calculating audio sample --------

  // divide the calculation over two interrupts
  if ( calcaudiosample ){
    prevoutsample2 = prevoutsample;
    previnsample2 = previnsample;
    prevoutsample = audiosample;
    previnsample = insample;

    // calculate next audio sample:
    pwm_count++;
    value = pgm_read_byte( osc[0].wavetable + ( ( (uint8_t) (osc[0].phase>>8) ) %LUTsize ) );
    valueA = value * osc[0].current_amplitude;
    valueO1 = (valueA>>8) + osc[0].offset;
    osc[0].phase += osc[0].phase_increment;

    value = pgm_read_byte( osc[1].wavetable + ( ( (uint8_t) (osc[1].phase>>8) ) %LUTsize ) );
    valueA = value * osc[1].current_amplitude;
    valueO2 = (valueA>>8) + osc[1].offset;
    osc[1].phase += osc[1].phase_increment;
//     audiosample = 0;

    if ( usenoise ){
      // noise generator
      newbit = 0;
      if(noiseseed & 0x8000) newbit ^= 1;
      if(noiseseed & 0x0100) newbit ^= 1;
      if(noiseseed & 0x0040) newbit ^= 1;
      if(noiseseed & 0x0200) newbit ^= 1;
      noiseseed = (noiseseed << 1) | newbit;
      value = (noiseseed >> 8);
    } else {
      value = pgm_read_byte( osc[2].wavetable + ( ( (uint8_t) (osc[2].phase>>8) )%LUTsize ) );
      osc[2].phase += osc[2].phase_increment;
      osc[2].phase += valueO1;
    }
    valueA = value * osc[2].current_amplitude;
    valueO3 = (valueA>>8);
    valueA = valueO2 * valueO3;
    insample = (valueA>>8); // + osc[2].offset;
  } else {    
//     insample = audiosample;
    // filter:
    // coefA0*insample + coefA1*previnsample+ coefB1*prevoutsample
    // FOF: out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (b1 * out(i-1))
    // SOS: out(i) = (a0 * in(i)) + (a1 * in(i-1)) + (a2 * in(i-2)) + (b1 * out(i-1)) + (b2 * out(i-2))
    valueA = coefA0*insample;
//     audiosample = (valueA>>8);
    valueA1 = coefA1*previnsample;
    valueA2 = coefA2*previnsample2;
    valueB1 = coefB1*prevoutsample;
    valueB2 = coefB2*prevoutsample2;
    
//     filterValue = valueA;
    if ( bit_is_set( filtersigns, 1 ) ){
//       filterValue += valueA1;
      valueA += valueA1;
//       valueA = (valueA>>1);
//       audiosample += (valueA>>8);
    }
    if ( bit_is_set( filtersigns, 2 ) ){
      valueA += valueA2;
//       valueA = (valueA>>1);
//       filterValue += valueA2;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_set( filtersigns, 3 ) ){
      valueA += valueB1;
//       valueA = (valueA>>1);
//       filterValue += valueB1;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_set( filtersigns, 4 ) ){
      valueA += valueB2;
//       valueA = (valueA>>1);
//       filterValue += valueB2;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_clear( filtersigns, 1 ) ){
      valueA -= valueA1;
//       valueA = (valueA>>1);
//       filterValue -= valueA1;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_clear( filtersigns, 2 ) ){
      valueA -= valueA2;
//       valueA = (valueA>>1);
//       filterValue -= valueA2;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_clear( filtersigns, 3 ) ){
      valueA -= valueB1;
//       valueA = (valueA>>1);
//       filterValue -= valueB1;
//       audiosample += (valueA>>8);
    }
    if ( bit_is_clear( filtersigns, 4 ) ){
      valueA -= valueB2;
//       valueA = (valueA>>1);
//       filterValue -= valueB2;
//       audiosample += (valueA>>8);
    }
    audiosample = (valueA>>8);    
//     audiosample = (filterValue>>11);    
//     if ( bit_is_clear( ADCSRA, ADSC ) ){
//     // ADC
//       sbi(ADCSRA,ADSC);              // start next conversion
//     }
  }
  calcaudiosample = !calcaudiosample;
}

/*    acc = 0;

    for (uint8_t i = 0; i<NUMOSC; i++) { //add contributions from each oscillator, the different wavetables could be part of one array to eliminate if()
      value1 = (uint8_t)( (osc[i].amplitude * osc[i].profile_amplitude)>>8);      
      switch(osc[i].waveform) {
	case WF_SIN:
	case WF_TRI:
 	  value2 = pgm_read_byte( osc[i].wavetable + ( (osc[i].phase)%LUTsize ) );
// 	  value = ( osc[i].profile_amplitude * pgm_read_byte( osc[i].wavetable + ( (osc[i].phase>>16)%LUTsize ) ) ) >> 8;
	  break;
	case WF_SAW:
	case WF_SAWINV:  
	  value2 = osc[i].phase;
	  break;
	case WF_PUL:
	  value2 = (osc[i].phase > osc[i].duty) ? 0 : 255;
	  break;
	case WF_NOI:
	  value2 = random(255);
	  break;
      }
      osc[i].phase += osc[i].phase_increment;
      value = (value1 * value2) >> 8;

//       if (osc[i].useenv == 1 ) { // i.e. only do this if profile_step set to lower value and not yet reached end of table
	if ((pwm_count % osc[i].profile_pwm_steps) == 0) { // update amplitude only every pwm-steps, so pwm_steps is a measure for duration!
	  if (osc[i].profile_step < LUTsize) { // i.e. only do this if profile_step set to lower value and not yet reached end of table
	    osc[i].profile_amplitude = pgm_read_byte( osc[i].profile + osc[i].profile_step++ );
	  } else { // after envelope:
// 	    if ( osc[i].repeat == 1 ){
	      if ( osc[i].profile_step++ > osc[i].duration ){
		osc[i].profile_step = 0; // start envelope from start
	      }
// 	    }
	  }
	}
//       }
      acc += value; // rhs = [-8160,7905] // multiply with volume and add to total accumulation (all four oscillators)
    } // end of iteration over oscillators
    audiosample = acc;
*/
// }



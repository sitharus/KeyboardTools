#ifndef G15_DEFINES_H
#define G15_DEFINES_H

enum {
	G15_KEY_G1  = 1<<0,
	G15_KEY_G2  = 1<<1,
	G15_KEY_G3  = 1<<2,
	G15_KEY_G4  = 1<<3,
	G15_KEY_G5  = 1<<4,
	G15_KEY_G6  = 1<<5,
	G15_KEY_G7  = 1<<6,
	G15_KEY_G8  = 1<<7,
	G15_KEY_G9  = 1<<8,
	G15_KEY_G10 = 1<<9,
	G15_KEY_G11 = 1<<10,
	G15_KEY_G12 = 1<<11,
	G15_KEY_G13 = 1<<12,
	G15_KEY_G14 = 1<<13,
	G15_KEY_G15 = 1<<14,
	G15_KEY_G16 = 1<<15,
	G15_KEY_G17 = 1<<16,
	G15_KEY_G18 = 1<<17,
	
	G15_KEY_M1  = 1<<18,
	G15_KEY_M2  = 1<<19,
	G15_KEY_M3  = 1<<20,
	G15_KEY_MR  = 1<<21,
	
	G15_KEY_L1  = 1<<22,
	G15_KEY_L2  = 1<<23,
	G15_KEY_L3  = 1<<24,
	G15_KEY_L4  = 1<<25,
	G15_KEY_L5  = 1<<26,
	
	G15_KEY_LIGHT = 1<<27
};

enum
{
    G15_LED_M1=1<<0,
    G15_LED_M2=1<<1,
    G15_LED_M3=1<<2,
    G15_LED_MR=1<<3
};


typedef struct {
	UInt8 control[0x0020];
	UInt8 buffer[0x03c0];
} G15Screen;

#endif
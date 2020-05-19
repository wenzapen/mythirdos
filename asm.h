// assembler macros to create x86 gdt descriptor

#define SEG_NULLASM	\
	.word 0, 0;	\
	.byte 0, 0, 0, 0

//0xC0 means size 4096 for 32 bits pMode
#define SEG_ASM(type, base, lim)	\
	.word (((lim)>>12) & 0xffff),((base) & 0xffff);	\
	.byte (((base)>>16) & 0xff), (0x90 | (type)),	\
		((((lim)>>28) & 0xf) | 0xc0), (((base)>>24) & 0xff)

#define STA_X 0x8  //excutable
#define STA_E 0x4  //expand down
#define STA_C 0x4  //conforming code segment
#define STA_W 0x2  //writable
#define STA_R 0x2  //readble
#define STA_A 0x1  //accessed



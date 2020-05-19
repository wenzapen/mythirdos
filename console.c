#include "types.h"
#include "spinlock.h"
#include "x86.h"
#include "defs.h"
#include "memlayout.h"

static void consputc(int);
//static int panicked = 0;

/*
static struct {
    struct spinlock lock;
    int locking;
} cons;
*/
static void printint(int xx, int base, int sign) {
    static char digits[] = "0123456789abcdef";
    char buf[16];
    uint x;
    int i;

    if(sign && (sign = xx < 0))
	x = -xx;
    else 
	x = xx;
    i = 0;
    do {
	buf[i++] = digits[x % base];
    } while((x /= base) != 0);
    if(sign)
	buf[i] = '-';
    while(i-- >= 0) 
	consputc(buf[i]);

}

// print to console, only understand %d,%x,%p,%s
void cprintf(char *fmt, ...) {

    int i, c;
    char *s;
    uint *argp;

    argp = (uint*)(&fmt+1);
    for(i=0; (c=fmt[i] & 0xff)!=0; i++) {
	if(c != '%') {
	    consputc(c);
	    continue;
	}	
	c = fmt[i+1] & 0xff;
	if(c==0)
	    break;
	switch(c) {
	    case 'd': 
		printint(*argp++, 10, 1);
		break;
	    case 'x':
	    case 'p':
		printint(*argp++, 16, 0);
		break;
	    case 's':
		if((s = (char*)*argp++) == 0)
		    s = "(null)";
		for(; *s; s++)
		    consputc(*s);
		break;
	    case '%':
		consputc('%');
		break;
	    default:
		consputc('%');
		consputc(c);
		break;
	}

    }
}

#define BACKSPACE 0x100
#define CRTPORT 0x3d4

static ushort *crt = (ushort*)P2V(0xb8000); 

static void cgaputc(int c) {
    int pos;
    outb(CRTPORT, 14);
    pos = inb(CRTPORT+1) << 8;
    outb(CRTPORT, 15);
    pos |= inb(CRTPORT+1);

    if(c=='\n')
	pos += 80 - pos % 80;
    else if(c==BACKSPACE) {
	if(pos>0)
	    pos--;
    } else {
	crt[pos++] = (c & 0xff) | 0x0700;
    }

    if((pos/80)>=24) {
	memmove(crt, crt+80, sizeof(crt[0])*23*80);
	pos -= 80;
	memset(crt+pos, 0, sizeof(crt[0])*(24*80-pos));
    }
	
    outb(CRTPORT, 14);
    outb(CRTPORT+1, pos>>8);
    outb(CRTPORT, 15);
    outb(CRTPORT+1, pos);
    crt[pos] = ' ' | 0x0700;

}

void consputc(int c) {
    cgaputc(c);
}

void panic(char *s) {
    cprintf("panic: %s\n", s);
    for(;;)
	;
}

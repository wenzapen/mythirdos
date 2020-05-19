#include "types.h"
#include "elf.h"
#include "x86.h"
#include "memlayout.h"

#define SECTSIZE  512

// offset: from the start of the file
void readseg(uchar* pa, uint count, uint offset); 

void bootmain(void) {

    struct elfhdr *elf;
    struct proghdr *ph, *eph;
    uchar *pa;
    void (*entry)(void);

    elf = (struct elfhdr *)0x10000;
    readseg((uchar *)elf, 4096, 0); 


    if(elf->magic != ELF_MAGIC)
	return;
    
    ph = (struct proghdr *)((uchar *)elf + elf->phoff);
    eph = ph + elf->phnum;
    for(; ph < eph; ph++) {
	pa = (uchar *)ph->paddr;
	readseg(pa, ph->filesz, ph->off);
	if(ph->filesz < ph->memsz)
	    stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
    }

    entry = (void (*)(void))(elf->entry);
    entry();

}

void waitdisk(void) {
    while((inb(0x1f7) & 0xc0) != 0x40) 
	;
}

void readsect(void *dst, uint offset) {
    waitdisk();
    outb(0x1f2, 1);
    outb(0x1f3, offset);
    outb(0x1f4, offset >> 8);
    outb(0x1f5, offset >> 16);
    outb(0x1f6, (offset >> 24) | 0xe0 );
    outb(0x1f7, 0x20);

    waitdisk();
    insl(0x1f0, dst, SECTSIZE/4);
}

void readseg(uchar *pa, uint count, uint offset) {
    uchar *epa;
    epa = pa + count;
    pa -= offset % SECTSIZE;
    

// convert offset in byte to offset in sector, kernel starts from sector 1
    offset = (offset / SECTSIZE) + 1; 
    for(; pa < epa; pa += SECTSIZE, offset++)
	readsect(pa, offset);
}

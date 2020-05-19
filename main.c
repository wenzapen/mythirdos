#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"

static void mpmain(void) __attribute__((noreturn));

pde_t entrypgdir[];

int main(void) {

    mpmain();
    for(;;)
	;
}

static void mpmain(void) {
  //  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
    cprintf("cpu%d: starting %d\n", 0, 0);
    for(;;)
	;
}


__attribute__((__aligned__(PGSIZE)))
pde_t entrypgdir[NPDENTRIES] = {
    [0] = (0) | PTE_P | PTE_W | PTE_PS,
    [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS
};

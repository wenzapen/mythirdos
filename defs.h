


// console.c
void cprintf(char*, ...);
void panic(char*)__attribute__((noreturn));

//proc.c
int cpuid(void);


//string.c
void *memmove(void*, const void*, uint);
void *memset(void*, int, uint);

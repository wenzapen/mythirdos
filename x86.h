

// Routines to let C code use special x86 instructions

static inline uchar inb(ushort port) {
    uchar data;
    asm volatile("in %1, %0" : "=a"(data) : "d"(port));
    return data;
}

//read 4 * cnt bytes from IO port to *addr
static inline void insl(int port, void *addr, int cnt) {
    asm volatile("cld; rep insl" :
			"=D"(addr),"=c"(cnt) :
			"d"(port), "0"(addr),"1"(cnt) :
			"memory", "cc");
}

static inline void outb(ushort port, uchar data) {
    asm volatile("out %0, %1" : : "a"(data), "d"(port));
}

static inline void stosb(void *addr, int data, int cnt) {
    asm volatile("cld; rep stosb" :
			"=D"(addr),"=c"(cnt) :
			"a"(data), "0"(addr),"1"(cnt) :
			"memory", "cc");
}

static inline void stosl(void *addr, int data, int cnt) {
    asm volatile("cld; rep stosl" :
			"=D"(addr),"=c"(cnt) :
			"a"(data), "0"(addr),"1"(cnt) :
			"memory", "cc");

}

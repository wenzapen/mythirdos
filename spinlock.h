
//mutual exclusion lock

struct spinlock {
    uint locked;

// for debugging
    char* name;  //name of lock
    struct cpu *cpu;  // The cpu holding the lock
    uint pcs[10];  // The call stack(an array of program counters) that locked the lock
};

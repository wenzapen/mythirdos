#include "asm.h"
#include "memlayout.h"
#include "mmu.h"
#include "param.h"

# 1) Enable paging
# 2) jump to main

.text
.p2align 2
.global multiboot_header
multiboot_header:
    #define magic 0x1badb002
    #define flags 0
    .long magic
    .long flags
    .long (-magic-flags)

.global _start
_start = V2P_WO(entry)

.global entry
# entering xv6 from boot loader
# turn on page size extension for 4M pages
entry:
    movl %cr4, %eax
    orl $(CR4_PSE), %eax
    movl %eax, %cr4
# set page directory
movl $(V2P_WO(entrypgdir)), %eax
movl %eax, %cr3

# Turn on paging
movl %cr0, %eax
orl $(CR0_PG|CR0_WP), %eax
movl %eax, %cr0

# setup stack pointer
movl $(bootstacktop), %esp

# Jump to main() via indirect jump and switch to excuting at high address
movl $main, %eax
jmp *%eax

#.comm stack, KSTACKSIZE

.data
.p2align 12         # force page alignment
.global bootstack
bootstack:
.space  KSTACKSIZE
.global bootstacktop
bootstacktop:



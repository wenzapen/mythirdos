
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# %cs=0, %ip=0x7c00

.code16
.global start
start:
	cli
    7c00:	fa                   	cli    

	xorw %ax, %ax
    7c01:	31 c0                	xor    %eax,%eax
	movw %ax, %ds
    7c03:	8e d8                	mov    %eax,%ds
	movw %ax, %es
    7c05:	8e c0                	mov    %eax,%es
	movw %ax, %ss
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:

# enable A20
seta20.1:
	inb $0x64, %al
    7c09:	e4 64                	in     $0x64,%al
	testb $0x2, %al
    7c0b:	a8 02                	test   $0x2,%al
	jnz seta20.1
    7c0d:	75 fa                	jne    7c09 <seta20.1>
	
	movb $0xd1, %al
    7c0f:	b0 d1                	mov    $0xd1,%al
	outb %al, $0x64
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:

seta20.2:
	inb $0x64, %al
    7c13:	e4 64                	in     $0x64,%al
	testb $0x2, %al
    7c15:	a8 02                	test   $0x2,%al
	jnz seta20.2
    7c17:	75 fa                	jne    7c13 <seta20.2>

	movb $0xdf, %al
    7c19:	b0 df                	mov    $0xdf,%al
	outb %al, $0x60
    7c1b:	e6 60                	out    %al,$0x60

# load gdt
	lgdt gdtdesc
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	68 7c 0f 20 c0       	push   $0xc0200f7c

# enter Protected mode
	movl %cr0, %eax
	orl $CR0_PE, %eax
    7c25:	66 83 c8 01          	or     $0x1,%ax
	movl %eax, %cr0
    7c29:	0f 22 c0             	mov    %eax,%cr0
	ljmp $(SEG_KCODE<<3), $start32
    7c2c:	ea                   	.byte 0xea
    7c2d:	31 7c 08 00          	xor    %edi,0x0(%eax,%ecx,1)

00007c31 <start32>:

.code32
start32:
	movw $(SEG_KDATA<<3), %ax
    7c31:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds	
    7c35:	8e d8                	mov    %eax,%ds
	movw %ax, %es	
    7c37:	8e c0                	mov    %eax,%es
	movw %ax, %ss	
    7c39:	8e d0                	mov    %eax,%ss
	movw $0, %ax
    7c3b:	66 b8 00 00          	mov    $0x0,%ax
	movw %ax, %fs
    7c3f:	8e e0                	mov    %eax,%fs
	movw %ax, %gs
    7c41:	8e e8                	mov    %eax,%gs

#setup stack point and call into C
	movl $start, %esp
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
	call bootmain
    7c48:	e8 e0 00 00 00       	call   7d2d <bootmain>
	cli
    7c4d:	fa                   	cli    
	hlt
    7c4e:	f4                   	hlt    
    7c4f:	90                   	nop

00007c50 <gdt>:
	...
    7c58:	ff                   	(bad)  
    7c59:	ff 00                	incl   (%eax)
    7c5b:	00 00                	add    %al,(%eax)
    7c5d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c64:	00                   	.byte 0x0
    7c65:	92                   	xchg   %eax,%edx
    7c66:	cf                   	iret   
	...

00007c68 <gdtdesc>:
    7c68:	17                   	pop    %ss
    7c69:	00 50 7c             	add    %dl,0x7c(%eax)
	...

00007c6e <waitdisk>:

// Routines to let C code use special x86 instructions

static inline uchar inb(ushort port) {
    uchar data;
    asm volatile("in %1, %0" : "=a"(data) : "d"(port));
    7c6e:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c73:	ec                   	in     (%dx),%al
    entry();

}

void waitdisk(void) {
    while((inb(0x1f7) & 0xc0) != 0x40) 
    7c74:	83 e0 c0             	and    $0xffffffc0,%eax
    7c77:	3c 40                	cmp    $0x40,%al
    7c79:	75 f8                	jne    7c73 <waitdisk+0x5>
	;
}
    7c7b:	c3                   	ret    

00007c7c <readsect>:

void readsect(void *dst, uint offset) {
    7c7c:	55                   	push   %ebp
    7c7d:	89 e5                	mov    %esp,%ebp
    7c7f:	57                   	push   %edi
    7c80:	53                   	push   %ebx
    7c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    waitdisk();
    7c84:	e8 e5 ff ff ff       	call   7c6e <waitdisk>
			"d"(port), "0"(addr),"1"(cnt) :
			"memory", "cc");
}

static inline void outb(ushort port, uchar data) {
    asm volatile("out %0, %1" : : "a"(data), "d"(port));
    7c89:	b8 01 00 00 00       	mov    $0x1,%eax
    7c8e:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c93:	ee                   	out    %al,(%dx)
    7c94:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c99:	89 d8                	mov    %ebx,%eax
    7c9b:	ee                   	out    %al,(%dx)
    outb(0x1f2, 1);
    outb(0x1f3, offset);
    outb(0x1f4, offset >> 8);
    7c9c:	89 d8                	mov    %ebx,%eax
    7c9e:	c1 e8 08             	shr    $0x8,%eax
    7ca1:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca6:	ee                   	out    %al,(%dx)
    outb(0x1f5, offset >> 16);
    7ca7:	89 d8                	mov    %ebx,%eax
    7ca9:	c1 e8 10             	shr    $0x10,%eax
    7cac:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cb1:	ee                   	out    %al,(%dx)
    outb(0x1f6, (offset >> 24) | 0xe0 );
    7cb2:	89 d8                	mov    %ebx,%eax
    7cb4:	c1 e8 18             	shr    $0x18,%eax
    7cb7:	83 c8 e0             	or     $0xffffffe0,%eax
    7cba:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbf:	ee                   	out    %al,(%dx)
    7cc0:	b8 20 00 00 00       	mov    $0x20,%eax
    7cc5:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cca:	ee                   	out    %al,(%dx)
    outb(0x1f7, 0x20);

    waitdisk();
    7ccb:	e8 9e ff ff ff       	call   7c6e <waitdisk>
    asm volatile("cld; rep insl" :
    7cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd3:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd8:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdd:	fc                   	cld    
    7cde:	f3 6d                	rep insl (%dx),%es:(%edi)
    insl(0x1f0, dst, SECTSIZE/4);
}
    7ce0:	5b                   	pop    %ebx
    7ce1:	5f                   	pop    %edi
    7ce2:	5d                   	pop    %ebp
    7ce3:	c3                   	ret    

00007ce4 <readseg>:

void readseg(uchar *pa, uint count, uint offset) {
    7ce4:	55                   	push   %ebp
    7ce5:	89 e5                	mov    %esp,%ebp
    7ce7:	57                   	push   %edi
    7ce8:	56                   	push   %esi
    7ce9:	53                   	push   %ebx
    7cea:	83 ec 0c             	sub    $0xc,%esp
    7ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf0:	8b 75 10             	mov    0x10(%ebp),%esi
    uchar *epa;
    epa = pa + count;
    7cf3:	89 df                	mov    %ebx,%edi
    7cf5:	03 7d 0c             	add    0xc(%ebp),%edi
    pa -= offset % SECTSIZE;
    7cf8:	89 f0                	mov    %esi,%eax
    7cfa:	25 ff 01 00 00       	and    $0x1ff,%eax
    7cff:	29 c3                	sub    %eax,%ebx
    

// convert offset in byte to offset in sector, kernel starts from sector 1
    offset = (offset / SECTSIZE) + 1; 
    7d01:	c1 ee 09             	shr    $0x9,%esi
    7d04:	83 c6 01             	add    $0x1,%esi
    for(; pa < epa; pa += SECTSIZE, offset++)
    7d07:	39 df                	cmp    %ebx,%edi
    7d09:	76 1a                	jbe    7d25 <readseg+0x41>
	readsect(pa, offset);
    7d0b:	83 ec 08             	sub    $0x8,%esp
    7d0e:	56                   	push   %esi
    7d0f:	53                   	push   %ebx
    7d10:	e8 67 ff ff ff       	call   7c7c <readsect>
    for(; pa < epa; pa += SECTSIZE, offset++)
    7d15:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d1b:	83 c6 01             	add    $0x1,%esi
    7d1e:	83 c4 10             	add    $0x10,%esp
    7d21:	39 df                	cmp    %ebx,%edi
    7d23:	77 e6                	ja     7d0b <readseg+0x27>
}
    7d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d28:	5b                   	pop    %ebx
    7d29:	5e                   	pop    %esi
    7d2a:	5f                   	pop    %edi
    7d2b:	5d                   	pop    %ebp
    7d2c:	c3                   	ret    

00007d2d <bootmain>:
void bootmain(void) {
    7d2d:	55                   	push   %ebp
    7d2e:	89 e5                	mov    %esp,%ebp
    7d30:	57                   	push   %edi
    7d31:	56                   	push   %esi
    7d32:	53                   	push   %ebx
    7d33:	83 ec 10             	sub    $0x10,%esp
    readseg((uchar *)elf, 4096, 0); 
    7d36:	6a 00                	push   $0x0
    7d38:	68 00 10 00 00       	push   $0x1000
    7d3d:	68 00 00 01 00       	push   $0x10000
    7d42:	e8 9d ff ff ff       	call   7ce4 <readseg>
    if(elf->magic != ELF_MAGIC)
    7d47:	83 c4 10             	add    $0x10,%esp
    7d4a:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d51:	45 4c 46 
    7d54:	75 21                	jne    7d77 <bootmain+0x4a>
    ph = (struct proghdr *)((uchar *)elf + elf->phoff);
    7d56:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d5b:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    eph = ph + elf->phnum;
    7d61:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d68:	c1 e6 05             	shl    $0x5,%esi
    7d6b:	01 de                	add    %ebx,%esi
    for(; ph < eph; ph++) {
    7d6d:	39 f3                	cmp    %esi,%ebx
    7d6f:	72 15                	jb     7d86 <bootmain+0x59>
    entry();
    7d71:	ff 15 18 00 01 00    	call   *0x10018
}
    7d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d7a:	5b                   	pop    %ebx
    7d7b:	5e                   	pop    %esi
    7d7c:	5f                   	pop    %edi
    7d7d:	5d                   	pop    %ebp
    7d7e:	c3                   	ret    
    for(; ph < eph; ph++) {
    7d7f:	83 c3 20             	add    $0x20,%ebx
    7d82:	39 de                	cmp    %ebx,%esi
    7d84:	76 eb                	jbe    7d71 <bootmain+0x44>
	pa = (uchar *)ph->paddr;
    7d86:	8b 7b 0c             	mov    0xc(%ebx),%edi
	readseg(pa, ph->filesz, ph->off);
    7d89:	83 ec 04             	sub    $0x4,%esp
    7d8c:	ff 73 04             	pushl  0x4(%ebx)
    7d8f:	ff 73 10             	pushl  0x10(%ebx)
    7d92:	57                   	push   %edi
    7d93:	e8 4c ff ff ff       	call   7ce4 <readseg>
	if(ph->filesz < ph->memsz)
    7d98:	8b 43 10             	mov    0x10(%ebx),%eax
    7d9b:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7d9e:	83 c4 10             	add    $0x10,%esp
    7da1:	39 c8                	cmp    %ecx,%eax
    7da3:	73 da                	jae    7d7f <bootmain+0x52>
	    stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
    7da5:	01 c7                	add    %eax,%edi
    7da7:	29 c1                	sub    %eax,%ecx
}

static inline void stosb(void *addr, int data, int cnt) {
    asm volatile("cld; rep stosb" :
    7da9:	b8 00 00 00 00       	mov    $0x0,%eax
    7dae:	fc                   	cld    
    7daf:	f3 aa                	rep stos %al,%es:(%edi)
			"=D"(addr),"=c"(cnt) :
			"a"(data), "0"(addr),"1"(cnt) :
			"memory", "cc");
}
    7db1:	eb cc                	jmp    7d7f <bootmain+0x52>

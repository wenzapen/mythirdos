
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

.global entry
# entering xv6 from boot loader
# turn on page size extension for 4M pages
entry:
    movl %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
    orl $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
    movl %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
# set page directory
movl $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 20 10 00       	mov    $0x102000,%eax
movl %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3

# Turn on paging
movl %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
orl $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
movl %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

# setup stack pointer
movl $(bootstacktop), %esp
80100028:	bc 00 20 10 80       	mov    $0x80102000,%esp

# Jump to main() via indirect jump and switch to excuting at high address
movl $main, %eax
8010002d:	b8 30 03 10 80       	mov    $0x80100330,%eax
jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <cgaputc>:
#define BACKSPACE 0x100
#define CRTPORT 0x3d4

static ushort *crt = (ushort*)P2V(0xb8000); 

static void cgaputc(int c) {
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
			"d"(port), "0"(addr),"1"(cnt) :
			"memory", "cc");
}

static inline void outb(ushort port, uchar data) {
    asm volatile("out %0, %1" : : "a"(data), "d"(port));
80100044:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100049:	56                   	push   %esi
8010004a:	89 fa                	mov    %edi,%edx
8010004c:	53                   	push   %ebx
8010004d:	89 c3                	mov    %eax,%ebx
8010004f:	b8 0e 00 00 00       	mov    $0xe,%eax
80100054:	83 ec 0c             	sub    $0xc,%esp
80100057:	ee                   	out    %al,(%dx)
    asm volatile("in %1, %0" : "=a"(data) : "d"(port));
80100058:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010005d:	89 ca                	mov    %ecx,%edx
8010005f:	ec                   	in     (%dx),%al
    int pos;
    outb(CRTPORT, 14);
    pos = inb(CRTPORT+1) << 8;
80100060:	0f b6 c0             	movzbl %al,%eax
    asm volatile("out %0, %1" : : "a"(data), "d"(port));
80100063:	89 fa                	mov    %edi,%edx
80100065:	c1 e0 08             	shl    $0x8,%eax
80100068:	89 c6                	mov    %eax,%esi
8010006a:	b8 0f 00 00 00       	mov    $0xf,%eax
8010006f:	ee                   	out    %al,(%dx)
    asm volatile("in %1, %0" : "=a"(data) : "d"(port));
80100070:	89 ca                	mov    %ecx,%edx
80100072:	ec                   	in     (%dx),%al
    outb(CRTPORT, 15);
    pos |= inb(CRTPORT+1);
80100073:	0f b6 c0             	movzbl %al,%eax
80100076:	09 f0                	or     %esi,%eax

    if(c=='\n')
80100078:	83 fb 0a             	cmp    $0xa,%ebx
8010007b:	74 63                	je     801000e0 <cgaputc+0xa0>
	pos += 80 - pos % 80;
    else if(c==BACKSPACE) {
	if(pos>0)
	    pos--;
    } else {
	crt[pos++] = (c & 0xff) | 0x0700;
8010007d:	0f b6 db             	movzbl %bl,%ebx
80100080:	8d 70 01             	lea    0x1(%eax),%esi
80100083:	80 cf 07             	or     $0x7,%bh
80100086:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010008d:	80 
    }

    if((pos/80)>=24) {
8010008e:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100094:	7f 65                	jg     801000fb <cgaputc+0xbb>
80100096:	8d bc 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%edi
    asm volatile("out %0, %1" : : "a"(data), "d"(port));
8010009d:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801000a2:	b8 0e 00 00 00       	mov    $0xe,%eax
801000a7:	89 da                	mov    %ebx,%edx
801000a9:	ee                   	out    %al,(%dx)
801000aa:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
	pos -= 80;
	memset(crt+pos, 0, sizeof(crt[0])*(24*80-pos));
    }
	
    outb(CRTPORT, 14);
    outb(CRTPORT+1, pos>>8);
801000af:	89 f0                	mov    %esi,%eax
801000b1:	c1 f8 08             	sar    $0x8,%eax
801000b4:	89 ca                	mov    %ecx,%edx
801000b6:	ee                   	out    %al,(%dx)
801000b7:	b8 0f 00 00 00       	mov    $0xf,%eax
801000bc:	89 da                	mov    %ebx,%edx
801000be:	ee                   	out    %al,(%dx)
801000bf:	89 f0                	mov    %esi,%eax
801000c1:	89 ca                	mov    %ecx,%edx
801000c3:	ee                   	out    %al,(%dx)
    outb(CRTPORT, 15);
    outb(CRTPORT+1, pos);
    crt[pos] = ' ' | 0x0700;
801000c4:	b8 20 07 00 00       	mov    $0x720,%eax
801000c9:	66 89 07             	mov    %ax,(%edi)

}
801000cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000cf:	5b                   	pop    %ebx
801000d0:	5e                   	pop    %esi
801000d1:	5f                   	pop    %edi
801000d2:	5d                   	pop    %ebp
801000d3:	c3                   	ret    
801000d4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801000df:	90                   	nop
	pos += 80 - pos % 80;
801000e0:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801000e5:	f7 e2                	mul    %edx
801000e7:	c1 ea 06             	shr    $0x6,%edx
801000ea:	8d 04 92             	lea    (%edx,%edx,4),%eax
801000ed:	c1 e0 04             	shl    $0x4,%eax
801000f0:	8d 70 50             	lea    0x50(%eax),%esi
    if((pos/80)>=24) {
801000f3:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
801000f9:	7e 9b                	jle    80100096 <cgaputc+0x56>
	memmove(crt, crt+80, sizeof(crt[0])*23*80);
801000fb:	83 ec 04             	sub    $0x4,%esp
	pos -= 80;
801000fe:	83 ee 50             	sub    $0x50,%esi
	memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100101:	68 60 0e 00 00       	push   $0xe60
	memset(crt+pos, 0, sizeof(crt[0])*(24*80-pos));
80100106:	8d bc 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%edi
	memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010010d:	68 a0 80 0b 80       	push   $0x800b80a0
80100112:	68 00 80 0b 80       	push   $0x800b8000
80100117:	e8 94 02 00 00       	call   801003b0 <memmove>
	memset(crt+pos, 0, sizeof(crt[0])*(24*80-pos));
8010011c:	b8 80 07 00 00       	mov    $0x780,%eax
80100121:	83 c4 0c             	add    $0xc,%esp
80100124:	29 f0                	sub    %esi,%eax
80100126:	01 c0                	add    %eax,%eax
80100128:	50                   	push   %eax
80100129:	6a 00                	push   $0x0
8010012b:	57                   	push   %edi
8010012c:	e8 2f 02 00 00       	call   80100360 <memset>
80100131:	83 c4 10             	add    $0x10,%esp
80100134:	e9 64 ff ff ff       	jmp    8010009d <cgaputc+0x5d>
80100139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100140 <printint>:
static void printint(int xx, int base, int sign) {
80100140:	55                   	push   %ebp
80100141:	89 e5                	mov    %esp,%ebp
80100143:	57                   	push   %edi
80100144:	56                   	push   %esi
80100145:	53                   	push   %ebx
80100146:	83 ec 2c             	sub    $0x2c,%esp
80100149:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010014c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
    if(sign && (sign = xx < 0))
8010014f:	85 c9                	test   %ecx,%ecx
80100151:	74 04                	je     80100157 <printint+0x17>
80100153:	85 c0                	test   %eax,%eax
80100155:	78 79                	js     801001d0 <printint+0x90>
	x = xx;
80100157:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010015e:	89 c1                	mov    %eax,%ecx
    i = 0;
80100160:	31 db                	xor    %ebx,%ebx
80100162:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
	buf[i++] = digits[x % base];
80100170:	89 c8                	mov    %ecx,%eax
80100172:	31 d2                	xor    %edx,%edx
80100174:	89 de                	mov    %ebx,%esi
80100176:	89 cf                	mov    %ecx,%edi
80100178:	f7 75 d4             	divl   -0x2c(%ebp)
8010017b:	8d 5b 01             	lea    0x1(%ebx),%ebx
8010017e:	0f b6 92 20 04 10 80 	movzbl -0x7feffbe0(%edx),%edx
    } while((x /= base) != 0);
80100185:	89 c1                	mov    %eax,%ecx
	buf[i++] = digits[x % base];
80100187:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
    } while((x /= base) != 0);
8010018b:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
8010018e:	73 e0                	jae    80100170 <printint+0x30>
    if(sign)
80100190:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100193:	85 c0                	test   %eax,%eax
80100195:	74 0a                	je     801001a1 <printint+0x61>
	buf[i] = '-';
80100197:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
8010019c:	0f b6 54 35 d8       	movzbl -0x28(%ebp,%esi,1),%edx
    while(i-- >= 0) 
801001a1:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
801001a5:	0f be c2             	movsbl %dl,%eax
801001a8:	8d 75 d6             	lea    -0x2a(%ebp),%esi
801001ab:	eb 09                	jmp    801001b6 <printint+0x76>
801001ad:	8d 76 00             	lea    0x0(%esi),%esi
801001b0:	0f be 03             	movsbl (%ebx),%eax
801001b3:	83 eb 01             	sub    $0x1,%ebx

void consputc(int c) {
    cgaputc(c);
801001b6:	e8 85 fe ff ff       	call   80100040 <cgaputc>
    while(i-- >= 0) 
801001bb:	39 de                	cmp    %ebx,%esi
801001bd:	75 f1                	jne    801001b0 <printint+0x70>
}
801001bf:	83 c4 2c             	add    $0x2c,%esp
801001c2:	5b                   	pop    %ebx
801001c3:	5e                   	pop    %esi
801001c4:	5f                   	pop    %edi
801001c5:	5d                   	pop    %ebp
801001c6:	c3                   	ret    
801001c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ce:	66 90                	xchg   %ax,%ax
	x = -xx;
801001d0:	f7 d8                	neg    %eax
801001d2:	89 c1                	mov    %eax,%ecx
801001d4:	eb 8a                	jmp    80100160 <printint+0x20>
801001d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001dd:	8d 76 00             	lea    0x0(%esi),%esi

801001e0 <cprintf>:
void cprintf(char *fmt, ...) {
801001e0:	55                   	push   %ebp
801001e1:	89 e5                	mov    %esp,%ebp
801001e3:	57                   	push   %edi
801001e4:	56                   	push   %esi
801001e5:	53                   	push   %ebx
801001e6:	83 ec 0c             	sub    $0xc,%esp
    for(i=0; (c=fmt[i] & 0xff)!=0; i++) {
801001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801001ec:	0f b6 03             	movzbl (%ebx),%eax
801001ef:	85 c0                	test   %eax,%eax
801001f1:	74 65                	je     80100258 <cprintf+0x78>
801001f3:	83 c3 01             	add    $0x1,%ebx
    argp = (uint*)(&fmt+1);
801001f6:	8d 7d 0c             	lea    0xc(%ebp),%edi
801001f9:	eb 49                	jmp    80100244 <cprintf+0x64>
801001fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001ff:	90                   	nop
	c = fmt[i+1] & 0xff;
80100200:	0f b6 33             	movzbl (%ebx),%esi
	if(c==0)
80100203:	85 f6                	test   %esi,%esi
80100205:	74 51                	je     80100258 <cprintf+0x78>
	switch(c) {
80100207:	83 fe 70             	cmp    $0x70,%esi
8010020a:	0f 84 95 00 00 00    	je     801002a5 <cprintf+0xc5>
80100210:	7f 4e                	jg     80100260 <cprintf+0x80>
80100212:	83 fe 25             	cmp    $0x25,%esi
80100215:	0f 84 b5 00 00 00    	je     801002d0 <cprintf+0xf0>
8010021b:	83 fe 64             	cmp    $0x64,%esi
8010021e:	0f 85 96 00 00 00    	jne    801002ba <cprintf+0xda>
		printint(*argp++, 10, 1);
80100224:	8b 07                	mov    (%edi),%eax
80100226:	8d 77 04             	lea    0x4(%edi),%esi
80100229:	b9 01 00 00 00       	mov    $0x1,%ecx
8010022e:	ba 0a 00 00 00       	mov    $0xa,%edx
80100233:	89 f7                	mov    %esi,%edi
80100235:	e8 06 ff ff ff       	call   80100140 <printint>
    for(i=0; (c=fmt[i] & 0xff)!=0; i++) {
8010023a:	0f b6 03             	movzbl (%ebx),%eax
8010023d:	83 c3 01             	add    $0x1,%ebx
80100240:	85 c0                	test   %eax,%eax
80100242:	74 14                	je     80100258 <cprintf+0x78>
	if(c != '%') {
80100244:	83 f8 25             	cmp    $0x25,%eax
80100247:	74 b7                	je     80100200 <cprintf+0x20>
    cgaputc(c);
80100249:	e8 f2 fd ff ff       	call   80100040 <cgaputc>
    for(i=0; (c=fmt[i] & 0xff)!=0; i++) {
8010024e:	0f b6 03             	movzbl (%ebx),%eax
80100251:	83 c3 01             	add    $0x1,%ebx
80100254:	85 c0                	test   %eax,%eax
80100256:	75 ec                	jne    80100244 <cprintf+0x64>
}
80100258:	83 c4 0c             	add    $0xc,%esp
8010025b:	5b                   	pop    %ebx
8010025c:	5e                   	pop    %esi
8010025d:	5f                   	pop    %edi
8010025e:	5d                   	pop    %ebp
8010025f:	c3                   	ret    
	switch(c) {
80100260:	83 fe 73             	cmp    $0x73,%esi
80100263:	75 3b                	jne    801002a0 <cprintf+0xc0>
		if((s = (char*)*argp++) == 0)
80100265:	8d 77 04             	lea    0x4(%edi),%esi
80100268:	8b 3f                	mov    (%edi),%edi
8010026a:	85 ff                	test   %edi,%edi
8010026c:	74 72                	je     801002e0 <cprintf+0x100>
		for(; *s; s++)
8010026e:	0f be 07             	movsbl (%edi),%eax
80100271:	84 c0                	test   %al,%al
80100273:	74 7b                	je     801002f0 <cprintf+0x110>
80100275:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010027c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cgaputc(c);
80100280:	e8 bb fd ff ff       	call   80100040 <cgaputc>
		for(; *s; s++)
80100285:	0f be 47 01          	movsbl 0x1(%edi),%eax
80100289:	83 c7 01             	add    $0x1,%edi
8010028c:	84 c0                	test   %al,%al
8010028e:	75 f0                	jne    80100280 <cprintf+0xa0>
		if((s = (char*)*argp++) == 0)
80100290:	89 f7                	mov    %esi,%edi
80100292:	eb a6                	jmp    8010023a <cprintf+0x5a>
80100294:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010029b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010029f:	90                   	nop
	switch(c) {
801002a0:	83 fe 78             	cmp    $0x78,%esi
801002a3:	75 15                	jne    801002ba <cprintf+0xda>
		printint(*argp++, 16, 0);
801002a5:	8b 07                	mov    (%edi),%eax
801002a7:	8d 77 04             	lea    0x4(%edi),%esi
801002aa:	31 c9                	xor    %ecx,%ecx
801002ac:	ba 10 00 00 00       	mov    $0x10,%edx
801002b1:	89 f7                	mov    %esi,%edi
801002b3:	e8 88 fe ff ff       	call   80100140 <printint>
		break;
801002b8:	eb 80                	jmp    8010023a <cprintf+0x5a>
    cgaputc(c);
801002ba:	b8 25 00 00 00       	mov    $0x25,%eax
801002bf:	e8 7c fd ff ff       	call   80100040 <cgaputc>
801002c4:	89 f0                	mov    %esi,%eax
801002c6:	e8 75 fd ff ff       	call   80100040 <cgaputc>
801002cb:	eb 81                	jmp    8010024e <cprintf+0x6e>
801002cd:	8d 76 00             	lea    0x0(%esi),%esi
801002d0:	b8 25 00 00 00       	mov    $0x25,%eax
801002d5:	e8 66 fd ff ff       	call   80100040 <cgaputc>
}
801002da:	e9 5b ff ff ff       	jmp    8010023a <cprintf+0x5a>
801002df:	90                   	nop
		    s = "(null)";
801002e0:	bf 0c 04 10 80       	mov    $0x8010040c,%edi
		for(; *s; s++)
801002e5:	b8 28 00 00 00       	mov    $0x28,%eax
801002ea:	eb 94                	jmp    80100280 <cprintf+0xa0>
801002ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    for(i=0; (c=fmt[i] & 0xff)!=0; i++) {
801002f0:	b8 73 00 00 00       	mov    $0x73,%eax
801002f5:	83 c3 01             	add    $0x1,%ebx
		if((s = (char*)*argp++) == 0)
801002f8:	89 f7                	mov    %esi,%edi
    cgaputc(c);
801002fa:	e8 41 fd ff ff       	call   80100040 <cgaputc>
801002ff:	e9 4a ff ff ff       	jmp    8010024e <cprintf+0x6e>
80100304:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010030b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010030f:	90                   	nop

80100310 <panic>:

void panic(char *s) {
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
80100313:	83 ec 10             	sub    $0x10,%esp
    cprintf("panic: %s\n", s);
80100316:	ff 75 08             	pushl  0x8(%ebp)
80100319:	68 13 04 10 80       	push   $0x80100413
8010031e:	e8 bd fe ff ff       	call   801001e0 <cprintf>
80100323:	83 c4 10             	add    $0x10,%esp
    for(;;)
80100326:	eb fe                	jmp    80100326 <panic+0x16>
80100328:	66 90                	xchg   %ax,%ax
8010032a:	66 90                	xchg   %ax,%ax
8010032c:	66 90                	xchg   %ax,%ax
8010032e:	66 90                	xchg   %ax,%ax

80100330 <main>:

static void mpmain(void) __attribute__((noreturn));

pde_t entrypgdir[];

int main(void) {
80100330:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80100334:	83 e4 f0             	and    $0xfffffff0,%esp
80100337:	ff 71 fc             	pushl  -0x4(%ecx)
8010033a:	55                   	push   %ebp
8010033b:	89 e5                	mov    %esp,%ebp
8010033d:	51                   	push   %ecx
8010033e:	83 ec 08             	sub    $0x8,%esp
	;
}

static void mpmain(void) {
  //  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
    cprintf("cpu%d: starting %d\n", 0, 0);
80100341:	6a 00                	push   $0x0
80100343:	6a 00                	push   $0x0
80100345:	68 31 04 10 80       	push   $0x80100431
8010034a:	e8 91 fe ff ff       	call   801001e0 <cprintf>
8010034f:	83 c4 10             	add    $0x10,%esp
    for(;;)
80100352:	eb fe                	jmp    80100352 <main+0x22>
80100354:	66 90                	xchg   %ax,%ax
80100356:	66 90                	xchg   %ax,%ax
80100358:	66 90                	xchg   %ax,%ax
8010035a:	66 90                	xchg   %ax,%ax
8010035c:	66 90                	xchg   %ax,%ax
8010035e:	66 90                	xchg   %ax,%ax

80100360 <memset>:
#include "types.h"
#include "x86.h"

void* memset(void *dst, int c, uint n) {
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	57                   	push   %edi
80100364:	8b 55 08             	mov    0x8(%ebp),%edx
80100367:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010036a:	53                   	push   %ebx
8010036b:	8b 45 0c             	mov    0xc(%ebp),%eax
    if((int)dst%4 == 0 && n%4 == 0) {
8010036e:	89 d7                	mov    %edx,%edi
80100370:	09 cf                	or     %ecx,%edi
80100372:	83 e7 03             	and    $0x3,%edi
80100375:	75 29                	jne    801003a0 <memset+0x40>
	c &= 0xff;
80100377:	0f b6 f8             	movzbl %al,%edi
	stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010037a:	c1 e0 18             	shl    $0x18,%eax
8010037d:	89 fb                	mov    %edi,%ebx
8010037f:	c1 e9 02             	shr    $0x2,%ecx
80100382:	c1 e3 10             	shl    $0x10,%ebx
80100385:	09 d8                	or     %ebx,%eax
80100387:	09 f8                	or     %edi,%eax
80100389:	c1 e7 08             	shl    $0x8,%edi
8010038c:	09 f8                	or     %edi,%eax
			"a"(data), "0"(addr),"1"(cnt) :
			"memory", "cc");
}

static inline void stosl(void *addr, int data, int cnt) {
    asm volatile("cld; rep stosl" :
8010038e:	89 d7                	mov    %edx,%edi
80100390:	fc                   	cld    
80100391:	f3 ab                	rep stos %eax,%es:(%edi)
    } else {
	stosb(dst, c, n);
    }
    return dst;
}
80100393:	5b                   	pop    %ebx
80100394:	89 d0                	mov    %edx,%eax
80100396:	5f                   	pop    %edi
80100397:	5d                   	pop    %ebp
80100398:	c3                   	ret    
80100399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    asm volatile("cld; rep stosb" :
801003a0:	89 d7                	mov    %edx,%edi
801003a2:	fc                   	cld    
801003a3:	f3 aa                	rep stos %al,%es:(%edi)
801003a5:	5b                   	pop    %ebx
801003a6:	89 d0                	mov    %edx,%eax
801003a8:	5f                   	pop    %edi
801003a9:	5d                   	pop    %ebp
801003aa:	c3                   	ret    
801003ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801003af:	90                   	nop

801003b0 <memmove>:

void* memmove(void *dst, const void *src, uint n) {
801003b0:	55                   	push   %ebp
801003b1:	89 e5                	mov    %esp,%ebp
801003b3:	57                   	push   %edi
801003b4:	8b 55 08             	mov    0x8(%ebp),%edx
801003b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801003ba:	56                   	push   %esi
801003bb:	8b 75 0c             	mov    0xc(%ebp),%esi
    const char *s;
    char *d;
    s = src;
    d = dst;
    if(s<d && s+n > d) {
801003be:	39 d6                	cmp    %edx,%esi
801003c0:	73 2e                	jae    801003f0 <memmove+0x40>
801003c2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
801003c5:	39 fa                	cmp    %edi,%edx
801003c7:	73 27                	jae    801003f0 <memmove+0x40>
801003c9:	8d 41 ff             	lea    -0x1(%ecx),%eax
	s += n;
	d += n;
	while(n-->0) {
801003cc:	85 c9                	test   %ecx,%ecx
801003ce:	74 11                	je     801003e1 <memmove+0x31>
	    *d-- = *s--;
801003d0:	0f b6 4c 06 01       	movzbl 0x1(%esi,%eax,1),%ecx
801003d5:	88 4c 02 01          	mov    %cl,0x1(%edx,%eax,1)
	while(n-->0) {
801003d9:	83 e8 01             	sub    $0x1,%eax
801003dc:	83 f8 ff             	cmp    $0xffffffff,%eax
801003df:	75 ef                	jne    801003d0 <memmove+0x20>
    } else {
	while(n-->0) 
	    *d++ = *s++;
    }
    return dst;
}
801003e1:	5e                   	pop    %esi
801003e2:	89 d0                	mov    %edx,%eax
801003e4:	5f                   	pop    %edi
801003e5:	5d                   	pop    %ebp
801003e6:	c3                   	ret    
801003e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003ee:	66 90                	xchg   %ax,%ax
	while(n-->0) 
801003f0:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
801003f3:	89 d7                	mov    %edx,%edi
801003f5:	85 c9                	test   %ecx,%ecx
801003f7:	74 e8                	je     801003e1 <memmove+0x31>
801003f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
	    *d++ = *s++;
80100400:	a4                   	movsb  %ds:(%esi),%es:(%edi)
	while(n-->0) 
80100401:	39 f0                	cmp    %esi,%eax
80100403:	75 fb                	jne    80100400 <memmove+0x50>
}
80100405:	5e                   	pop    %esi
80100406:	89 d0                	mov    %edx,%eax
80100408:	5f                   	pop    %edi
80100409:	5d                   	pop    %ebp
8010040a:	c3                   	ret    

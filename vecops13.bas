#define MINIMUM_ADJ_ 1e-20!

sub hsixteen naked (x as single ptr, n as ulongint,scale as single)
asm	
	shufps xmm0,xmm0,0
	.align 16
h16:
	subq rsi,16
	movups xmm1,[rdi]
	movups xmm2,[rdi+16]
	movups xmm3,[rdi+2*16]
	movups xmm4,[rdi+3*16]
	movups xmm5,xmm1
	movups xmm6,xmm3
	haddps xmm1,xmm2
	haddps xmm3,xmm4
	hsubps xmm5,xmm2
	hsubps xmm6,xmm4
	movups xmm2,xmm1
	movups xmm4,xmm3
	haddps xmm1,xmm5
	haddps xmm3,xmm6
	hsubps xmm2,xmm5
	hsubps xmm4,xmm6
	movups xmm5,xmm1
	movups xmm6,xmm3
	haddps xmm1,xmm2
	haddps xmm3,xmm4
	hsubps xmm5,xmm2
	hsubps xmm6,xmm4
	movups xmm2,xmm1
	movups xmm4,xmm5
	addps xmm1,xmm3
	addps xmm5,xmm6
	subps xmm2,xmm3
	subps xmm4,xmm6
	mulps xmm1,xmm0
	mulps xmm5,xmm0
	mulps xmm2,xmm0
	mulps xmm4,xmm0
	movups [rdi],xmm1
	movups [rdi+16],xmm5
	movups [rdi+2*16],xmm2
	movups [rdi+3*16],xmm4
	lea rdi,[rdi+64]
	jnz h16
	ret
end asm
end sub

sub hgap naked (x as single ptr,gap as ulongint,n as ulongint)
asm
    movq rcx,rsi
	lea r8,[rdi+4*rsi]
	shr rdx,1
	.align 16	
hgaploop:
	subq rcx,16
	movups xmm0,[rdi]
	movups xmm1,[rdi+16]
	movups xmm2,[rdi+2*16]
	movups xmm3,[rdi+3*16]
	movups xmm8,[r8]
	movups xmm9,[r8+16]
	movups xmm10,[r8+2*16]
	movups xmm11,[r8+3*16]
	movups xmm4,xmm0
	movups xmm5,xmm1
	movups xmm6,xmm2
	movups xmm7,xmm3
	addps xmm0,xmm8
	addps xmm1,xmm9
	addps xmm2,xmm10
	addps xmm3,xmm11
	subps xmm4,xmm8
	subps xmm5,xmm9
	subps xmm6,xmm10
	subps xmm7,xmm11
	movups [rdi],xmm0
	movups [rdi+16],xmm1
	movups [rdi+2*16],xmm2
	movups [rdi+3*16],xmm3
	movups [r8],xmm4
	movups [r8+16],xmm5
	movups [r8+2*16],xmm6
	movups [r8+3*16],xmm7
	lea rdi,[rdi+64]
	lea r8,[r8+64]
	jnz hgaploop
	subq rdx,rsi
	movq rcx,rsi
	movq rdi,r8
	lea r8,[r8+4*rsi]
	jnz hgaploop
	ret
end asm
end sub

sub hashflip naked (result as single ptr,x as single ptr,h as ulongint,n as ulongint)
asm
	movq rax,rndphi[rip]
	movq r8,rndsqr3[rip]
	movdqu xmm8,flipshift[rip]
	add rdx,r8
	movdqu xmm9,flipshift[rip+16]
	imulq rdx,rax
	movdqu xmm10,flipshift[rip+32]
	bswapq rdx
	movdqu xmm11,flipshift[rip+48]
	add rdx,r8
	movdqu xmm12,flipmask[rip]
	imulq rdx,rax
	movd xmm4,edx
	bswapq rdx
	.align 16
flipAlp:
	imulq rdx,rax
	pshufd xmm4,xmm4,0
	movdqu xmm0,[rsi]
	movdqu xmm1,[rsi+16]
	movdqu xmm2,[rsi+2*16]
	movdqu xmm3,[rsi+3*16]
	addq rdx,r8
	movdqa xmm5,xmm4
	movdqa xmm6,xmm4
	movdqa xmm7,xmm4
	imulq rdx,rax
	pmulld xmm4,xmm8
	pmulld xmm5,xmm9
	pmulld xmm6,xmm10
	pmulld xmm7,xmm11
	addq rdx,r8
	pand xmm4,xmm12
	pand xmm5,xmm12
	pand xmm6,xmm12
	pand xmm7,xmm12
	bswapq rdx
	pxor xmm0,xmm4
	pxor xmm1,xmm5
	pxor xmm2,xmm6
	pxor xmm3,xmm7
	movd xmm4,edx
	sub rcx,16
	movdqu [rdi],xmm0
	movdqu [rdi+16],xmm1
	movdqu [rdi+2*16],xmm2
	movdqu [rdi+3*16],xmm3
	lea rsi,[rsi+64]
	lea rdi,[rdi+64]
	jnz flipAlp
	ret
 flipshift:   .int 1,2,4,8,16,32,64,128
			   .int 256,512,1024,2048,4096,8192,16384,32768
 flipmask:	   .int 0x80000000,0x80000000,0x80000000,0x80000000
 rndphi:	   .quad 0x9E3779B97F4A7C15
 rndsqr3:	   .quad 0xBB67AE8584CAA73B
end asm
end sub

function sumsquare naked (x as single ptr,n as ulongint) as single
asm
	xorps xmm0,xmm0
	xorps xmm1,xmm1
	xorps xmm2,xmm2
	xorps xmm3,xmm3
	.align 16
sumsquarelp:
    movups xmm4,[rdi]
    movups xmm5,[rdi+16]
    movups xmm6,[rdi+32]
    movups xmm7,[rdi+48]
    sub rsi,16
    mulps xmm4,xmm4
    mulps xmm5,xmm5
    mulps xmm6,xmm6
    mulps xmm7,xmm7
    lea rdi,[rdi+64]
    addps xmm0,xmm4
    addps xmm1,xmm5
    addps xmm2,xmm6
    addps xmm3,xmm7
    jnz sumsquarelp
    haddps xmm0,xmm1
    haddps xmm2,xmm3
    haddps xmm0,xmm2
    haddps xmm0,xmm0
    haddps xmm0,xmm0
    ret 
end asm
end function

function errorl2 naked (x as single ptr,y as single ptr,n as ulongint) as single
asm
	xorps xmm0,xmm0
	xorps xmm1,xmm1
	xorps xmm2,xmm2
	xorps xmm3,xmm3
	.align 16
errorl2lp:
    movups xmm4,[rdi]
    movups xmm5,[rdi+16]
    movups xmm6,[rdi+32]
    movups xmm7,[rdi+48]
    sub rdx,16
    subps xmm4,[rsi]
    subps xmm5,[rsi+16]
    subps xmm6,[rsi+32]
    subps xmm7,[rsi+48]
    lea rdi,[rdi+64]
    mulps xmm4,xmm4
    mulps xmm5,xmm5
    mulps xmm6,xmm6
    mulps xmm7,xmm7
    lea rsi,[rsi+64]
    addps xmm0,xmm4
    addps xmm1,xmm5
    addps xmm2,xmm6
    addps xmm3,xmm7
    jnz errorl2lp
    haddps xmm0,xmm1
    haddps xmm2,xmm3
    haddps xmm0,xmm2
    haddps xmm0,xmm0
    haddps xmm0,xmm0
    ret 
end asm
end function

function errorl1 naked (x as single ptr,y as single ptr,n as ulongint) as single
asm
	mov ecx,0x7fffffff
	xorps xmm0,xmm0
	xorps xmm1,xmm1
	movd xmm8,ecx
	xorps xmm2,xmm2
	xorps xmm3,xmm3
	pshufd xmm8,xmm8,0
	.align 16
errorl1lp:
    movups xmm4,[rdi]
    movups xmm5,[rdi+16]
    movups xmm6,[rdi+32]
    movups xmm7,[rdi+48]
    sub rdx,16
    subps xmm4,[rsi]
    subps xmm5,[rsi+16]
    subps xmm6,[rsi+32]
    subps xmm7,[rsi+48]
    lea rdi,[rdi+64]
    andps xmm4,xmm8
    andps xmm5,xmm8
    andps xmm6,xmm8
    andps xmm7,xmm8
    lea rsi,[rsi+64]
    addps xmm0,xmm4
    addps xmm1,xmm5
    addps xmm2,xmm6
    addps xmm3,xmm7
    jnz errorl1lp
    haddps xmm0,xmm1
    haddps xmm2,xmm3
    haddps xmm0,xmm2
    haddps xmm0,xmm0
    haddps xmm0,xmm0
    ret 
end asm
end function

sub cdf naked (result as single ptr,x as single ptr,n as ulongint)
asm
	movaps xmm15,cdfAconst[rip]
	movaps xmm14,cdfAconst[rip+16]
	movaps xmm13,cdfAconst[rip+2*16]
	movaps xmm12,cdfAconst[rip+3*16]
	subq rdx,16
	.align 16
cdfAlp:
	movups xmm0,[rsi+4*rdx+16*3]
	movups xmm1,[rsi+4*rdx+16*2]
	movups xmm2,[rsi+4*rdx+16]
	movups xmm3,[rsi+4*rdx]
	movaps xmm4,cdfAconst[rip+9*16]
	movaps xmm8,xmm0
	movaps xmm9,xmm1
	movaps xmm10,xmm2
	movaps xmm11,xmm3
	andps xmm0,xmm15
	andps xmm1,xmm15
	andps xmm2,xmm15
	andps xmm3,xmm15
	mulps xmm0,xmm12
	mulps xmm1,xmm12
	mulps xmm2,xmm12
	mulps xmm3,xmm12
	movaps xmm5,xmm4
	movaps xmm6,xmm4
	movaps xmm7,xmm4
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,cdfAconst[rip+8*16]
	addps xmm5,cdfAconst[rip+8*16]
	addps xmm6,cdfAconst[rip+8*16]
	addps xmm7,cdfAconst[rip+8*16]
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,cdfAconst[rip+7*16]
	addps xmm5,cdfAconst[rip+7*16]
	addps xmm6,cdfAconst[rip+7*16]
	addps xmm7,cdfAconst[rip+7*16]
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,cdfAconst[rip+6*16]
	addps xmm5,cdfAconst[rip+6*16]
	addps xmm6,cdfAconst[rip+6*16]
	addps xmm7,cdfAconst[rip+6*16]
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,cdfAconst[rip+5*16]
	addps xmm5,cdfAconst[rip+5*16]
	addps xmm6,cdfAconst[rip+5*16]
	addps xmm7,cdfAconst[rip+5*16]
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,cdfAconst[rip+4*16]
	addps xmm5,cdfAconst[rip+4*16]
	addps xmm6,cdfAconst[rip+4*16]
	addps xmm7,cdfAconst[rip+4*16]
	mulps xmm4,xmm0
	mulps xmm5,xmm1
	mulps xmm6,xmm2
	mulps xmm7,xmm3
	addps xmm4,xmm13
	addps xmm5,xmm13
	addps xmm6,xmm13
	addps xmm7,xmm13
	
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	mulps xmm7,xmm7
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	mulps xmm7,xmm7
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	mulps xmm7,xmm7
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	mulps xmm7,xmm7
	
	movaps xmm0,xmm13
	movaps xmm1,xmm13
	movaps xmm2,xmm13
	movaps xmm3,xmm13
	
	divps xmm0,xmm4
	divps xmm1,xmm5
	divps xmm2,xmm6
	divps xmm3,xmm7
	subq rdx,16
	
	andps xmm8,xmm14
	andps xmm9,xmm14
	andps xmm10,xmm14
	andps xmm11,xmm14
	movaps xmm4,xmm13
	movaps xmm5,xmm13
	movaps xmm6,xmm13
	movaps xmm7,xmm13
	
	subps xmm4,xmm0
	subps xmm5,xmm1
	subps xmm6,xmm2
	subps xmm7,xmm3
	orps xmm4,xmm8
	orps xmm5,xmm9
	orps xmm6,xmm10
	orps xmm7,xmm11
	
	movups [rdi+4*rdx+64+16*3],xmm4
	movups [rdi+4*rdx+64+16*2],xmm5
	movups [rdi+4*rdx+64+16],xmm6
	movups [rdi+4*rdx+64],xmm7

	jnc cdfAlp
	ret
	.align 16
cdfAconst:
	.int 0x7fffffff,0x7fffffff,0x7fffffff,0x7fffffff
	.int 0x80000000,0x80000000,0x80000000,0x80000000
	.float 1,1,1,1
	.float 0.707106781,0.707106781,0.707106781,0.707106781
	.float 0.0705230784,0.0705230784,0.0705230784,0.0705230784
	.float 0.0422820123,0.0422820123,0.0422820123,0.0422820123
	.float 0.0092705272,0.0092705272,0.0092705272,0.0092705272
	.float 0.0001520143,0.0001520143,0.0001520143,0.0001520143
	.float 0.0002765672,0.0002765672,0.0002765672,0.0002765672
	.float 0.0000430638,0.0000430638,0.0000430638,0.0000430638
end asm
end sub

sub switch naked(x as single ptr,wts as single ptr,n as ulongint)
asm
	xorps xmm0,xmm0  'zero xmm0
	.align 16
switchlp:
	movups xmm12,[rdi]	'x values
	movups xmm13,[rdi+16]
	movups xmm14,[rdi+32]
	movups xmm15,[rdi+48]
	movups xmm5,[rsi]   'wt block 1
	movups xmm6,[rsi+16]
	movups xmm7,[rsi+32]
	movups xmm8,[rsi+48]
	sub rdx,16
	movaps xmm1,xmm12	'copy x values
	movaps xmm2,xmm13
	movaps xmm3,xmm14
	movaps xmm4,xmm15
	cmpltps xmm1,xmm0	'masks
	cmpltps xmm2,xmm0
	cmpltps xmm3,xmm0
	cmpltps xmm4,xmm0
	andps xmm5,xmm1 	'wt block 1 and mask
	andps xmm6,xmm2
	andps xmm7,xmm3
	andps xmm8,xmm4
	andnps xmm1,[rsi+64] 'wt block 2 and not mask
	andnps xmm2,[rsi+80]
	andnps xmm3,[rsi+96]
	andnps xmm4,[rsi+112]
    orps xmm1,xmm5
    orps xmm2,xmm6
    orps xmm3,xmm7
    orps xmm4,xmm8
    mulps xmm1,xmm12
    mulps xmm2,xmm13
    mulps xmm3,xmm14
    mulps xmm4,xmm15
   
    movups [rdi],xmm1
    movups [rdi+16],xmm2
    movups [rdi+32],xmm3
    movups [rdi+48],xmm4
    lea rdi,[rdi+64]
    lea rsi,[rsi+128]
    jnz switchlp
    ret
end asm
end sub

sub switchaddto naked(addto as single ptr,x as single ptr,wts as single ptr,n as ulongint)
asm
	xorps xmm0,xmm0  'zero xmm0
	.align 16
switchaddtolp:
	movups xmm12,[rsi]	'x values
	movups xmm13,[rsi+16]
	movups xmm14,[rsi+32]
	movups xmm15,[rsi+48]
	movups xmm5,[rdx]   'wt block 1
	movups xmm6,[rdx+16]
	movups xmm7,[rdx+32]
	movups xmm8,[rdx+48]
	sub rcx,16
	movaps xmm1,xmm12	'copy x values
	movaps xmm2,xmm13
	movaps xmm3,xmm14
	movaps xmm4,xmm15
	cmpltps xmm1,xmm0	'masks
	cmpltps xmm2,xmm0
	cmpltps xmm3,xmm0
	cmpltps xmm4,xmm0
	andps xmm5,xmm1 	'wt block 1 and mask
	andps xmm6,xmm2
	andps xmm7,xmm3
	andps xmm8,xmm4
	andnps xmm1,[rdx+64] 'wt block 2 and not mask
	andnps xmm2,[rdx+80]
	andnps xmm3,[rdx+96]
	andnps xmm4,[rdx+112]
    orps xmm1,xmm5
    orps xmm2,xmm6
    orps xmm3,xmm7
    orps xmm4,xmm8
    mulps xmm1,xmm12
    mulps xmm2,xmm13
    mulps xmm3,xmm14
    mulps xmm4,xmm15
    addps xmm1,[rdi]
    addps xmm2,[rdi+16]
    addps xmm3,[rdi+32]
    addps xmm4,[rdi+48]
    lea rsi,[rsi+64]
    lea rdx,[rdx+128]
    movups [rdi],xmm1
    movups [rdi+16],xmm2
    movups [rdi+32],xmm3
    movups [rdi+48],xmm4
    lea rdi,[rdi+64]
    jnz switchaddtolp
    ret
end asm
end sub

sub hashprm naked (x as single ptr,h as ulong,n as ulongint)
asm	
	push r12
	push r13
	push r14
	push r15
	.align 16
hashprmlp:
	lea r11d,[edx+esi]
	lea r10d,[edx+esi-1]
	lea r9d,[edx+esi-2]
	lea r8d,[edx+esi-3]
	imul r11d,741103597
	imul r10d,887987685
	imul r9d,1597334677
	imul r8d,204209821
	bswap r11d
	bswap r10d
	bswap r9d
	bswap r8d
	add r11d,0x79f43981
	add r10d,0xb5c84c33
	add r9d,0x5e5c7f2b
    add r8d,0x9be72e55
    imul r11d,741103597
	imul r10d,887987685
	imul r9d,1597334677
	imul r8d,204209821
    lea r15,[rdx]
    lea r14,[rdx-1]
    lea r13,[rdx-2]
    lea r12,[rdx-3]
    imulq r11,r15
    imulq r10,r14
    imulq r9,r13
    imulq r8,r12
    shrq r11,32
    shrq r10,32
    shrq r9,32
    shrq r8,32
    mov eax,[rdi+4*rdx-4]
    mov ecx,[rdi+4*r11]
    mov [rdi+4*r11],eax
    mov [rdi+4*rdx-4],ecx
    mov eax,[rdi+4*rdx-8]
    mov ecx,[rdi+4*r10]
    mov [rdi+4*r10],eax
    mov [rdi+4*rdx-8],ecx  
    mov eax,[rdi+4*rdx-12]
    mov ecx,[rdi+4*r9]
    mov [rdi+4*r9],eax
    mov [rdi+4*rdx-12],ecx
    mov eax,[rdi+4*rdx-16]
    mov ecx,[rdi+4*r8]
    mov [rdi+4*r8],eax
    mov [rdi+4*rdx-16],ecx
    sub rdx,4
    jnz hashprmlp
    pop r15
    pop r14
    pop r13
    pop r12
    ret
end asm
end sub

sub hashprminv naked (x as single ptr,h as ulong,n as ulongint)
asm
	push r12
	push r13
	push r14
	push r15
	push rbx
	mov rbx,4
	.align 16
hashprminvlp:
	lea r8,[rbx+rsi-3]
	lea r9,[rbx+rsi-2]
	lea r10,[rbx+rsi-1]
	lea r11,[rbx+rsi]
	imul r8d,204209821
	imul r9d,1597334677
	imul r10d,887987685
	imul r11d,741103597
	bswap r8d
	bswap r9d
	bswap r10d
	bswap r11d
	add r8d,0x9be72e55
	add r9d,0x5e5c7f2b
	add r10d,0xb5c84c33
	add r11d,0x79f43981
	imul r8d,204209821
	imul r9d,1597334677
    imul r10d,887987685
    imul r11d,741103597
	lea r12,[rbx-3]
	lea r13,[rbx-2]
    lea r14,[rbx-1]
    lea r15,[rbx]
    imulq r8,r12
    imulq r9,r13
    imulq r10,r14
    imulq r11,r15
    shrq r8,32
    shrq r9,32
    shrq r10,32
    shrq r11,32 
    mov eax,[rdi+4*rbx-16]
    mov ecx,[rdi+4*r8]
    mov [rdi+4*r8],eax
    mov [rdi+4*rbx-16],ecx
    mov eax,[rdi+4*rbx-12]
    mov ecx,[rdi+4*r9]
    mov [rdi+4*r9],eax
    mov [rdi+4*rbx-12],ecx
    mov eax,[rdi+4*rbx-8]
    mov ecx,[rdi+4*r10]
    mov [rdi+4*r10],eax
    mov [rdi+4*rbx-8],ecx
    mov eax,[rdi+4*rbx-4]
    mov ecx,[rdi+4*r11]
    mov [rdi+4*r11],eax
    mov [rdi+4*rbx-4],ecx
    sub rdx,4
    lea rbx,[rbx+4]
    jnz hashprminvlp
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret
end asm
end sub

sub hstep naked(x as single ptr,y as single ptr,n as ulongint)	
asm
   movups xmm13,recipsqrt2[rip]
   lea rcx,[rdi+2*rdx]
   .align 16
hstep1lp:
	subq rdx,32
	movups xmm0,[rsi]
	movups xmm1,[rsi+16]
	movups xmm2,[rsi+2*16]
	movups xmm3,[rsi+3*16]
	movups xmm4,[rsi+4*16]
	movups xmm5,[rsi+5*16]
	movups xmm6,[rsi+6*16]
	movups xmm7,[rsi+7*16]
	movups xmm8,xmm0
	movups xmm9,xmm2
	movups xmm10,xmm4
	movups xmm11,xmm6
	haddps xmm0,xmm1
	haddps xmm2,xmm3
	haddps xmm4,xmm5
	haddps xmm6,xmm7
	hsubps xmm8,xmm1
	hsubps xmm9,xmm3
	hsubps xmm10,xmm5
	hsubps xmm11,xmm7
	mulps xmm0,xmm13
	mulps xmm2,xmm13
	mulps xmm4,xmm13
	mulps xmm6,xmm13
	mulps xmm8,xmm13
	mulps xmm9,xmm13
	mulps xmm10,xmm13
	mulps xmm11,xmm13
	movups [rdi],xmm0
	movups [rdi+1*16],xmm2
	movups [rdi+2*16],xmm4
	movups [rdi+3*16],xmm6
	movups [rcx],xmm8
	movups [rcx+1*16],xmm9
	movups [rcx+2*16],xmm10
	movups [rcx+3*16],xmm11
	lea rsi,[rsi+128]
	lea rdi,[rdi+64]
	lea rcx,[rcx+64]
	jnz hstep1lp
	ret
	recipsqrt2:   .int 0x3f3504f3,0x3f3504f3,0x3f3504f3,0x3f3504f3
end asm
end sub	


sub	clipmin naked (result as single ptr,x as single ptr,min as single,n as ulongint)
asm
	subq rdx,16
	shufps XMM0,XMM0,0
	.align 16
clipminlp:
	movups xmm1,[rsi+4*rdx+16*3]
	movups xmm2,[rsi+4*rdx+16*2]
	movups xmm3,[rsi+4*rdx+16]
	movups xmm4,[rsi+4*rdx]
	subq rdx,16
	maxps xmm1,xmm0
	maxps xmm2,xmm0
	maxps xmm3,xmm0
	maxps xmm4,xmm0
	movups [rdi+4*rdx+64+16*3],xmm1
	movups [rdi+4*rdx+64+16*2],xmm2
	movups [rdi+4*rdx+64+16],xmm3
	movups [rdi+4*rdx+64],xmm4
	jnc clipminlp
	ret
end asm
end sub

sub	clipmax naked (result as single ptr,x as single ptr,max as single,n as ulongint)
asm
	subq rdx,16
	shufps XMM0,XMM0,0
	.align 16
clipmaxlp:
	movups xmm1,[rsi+4*rdx+16*3]
	movups xmm2,[rsi+4*rdx+16*2]
	movups xmm3,[rsi+4*rdx+16]
	movups xmm4,[rsi+4*rdx]
	subq rdx,16
	minps xmm1,xmm0
	minps xmm2,xmm0
	minps xmm3,xmm0
	minps xmm4,xmm0
	movups [rdi+4*rdx+64+16*3],xmm1
	movups [rdi+4*rdx+64+16*2],xmm2
	movups [rdi+4*rdx+64+16],xmm3
	movups [rdi+4*rdx+64],xmm4
	jnc clipmaxlp
	ret
end asm
end sub

sub	clip naked (result as single ptr,x as single ptr,min as single,max as single,n as ulongint)
asm
	subq rdx,16
	shufps XMM0,XMM0,0
	shufps xmm1,xmm1,0
	.align 16
cliplp:
	movups xmm2,[rsi+4*rdx+16*3]
	movups xmm3,[rsi+4*rdx+16*2]
	movups xmm4,[rsi+4*rdx+16]
	movups xmm5,[rsi+4*rdx]
	subq rdx,16
	maxps xmm2,xmm0
	maxps xmm3,xmm0
	maxps xmm4,xmm0
	maxps xmm5,xmm0
	minps xmm2,xmm1
	minps xmm3,xmm1
	minps xmm4,xmm1
	minps xmm5,xmm1
	movups [rdi+4*rdx+64+16*3],xmm2
	movups [rdi+4*rdx+64+16*2],xmm3
	movups [rdi+4*rdx+64+16],xmm4
	movups [rdi+4*rdx+64],xmm5
	jnc cliplp
	ret
end asm 
end sub

sub	softswitch naked (x as single ptr,wts as single ptr,n as ulongint)
asm
	movups xmm8,ones[rip]
	movups xmm9,mones[rip]
	movups xmm10,halfs[rip]
	.align 16
softlp:
	movups xmm0,[rdi]
	movups xmm1,[rdi+16]
	movups xmm2,[rdi+2*16]
	movups xmm3,[rdi+3*16]
	movaps xmm4,xmm0
	movaps xmm5,xmm1
	movaps xmm6,xmm2
	movaps xmm7,xmm3
	subq rdx,16
	maxps xmm4,xmm8
	maxps xmm5,xmm8
	maxps xmm6,xmm8
	maxps xmm7,xmm8
	minps xmm4,xmm9
	minps xmm5,xmm9
	minps xmm6,xmm9
	minps xmm7,xmm9
	addps xmm4,xmm8
	addps xmm5,xmm8
	addps xmm6,xmm8
	addps xmm7,xmm8
	mulps xmm4,xmm10
	mulps xmm5,xmm10
	mulps xmm6,xmm10
	mulps xmm7,xmm10
	movaps xmm11,xmm8
	movaps xmm12,xmm8
	movaps xmm13,xmm8
	movaps xmm14,xmm8
	subps xmm11,xmm4
	subps xmm12,xmm5
	subps xmm13,xmm6
	subps xmm14,xmm7
	mulps xmm4,[rsi]
	mulps xmm5,[rsi+16]
	mulps xmm6,[rsi+2*16]
	mulps xmm7,[rsi+3*16]
	mulps xmm11,[rsi+4*16]
	mulps xmm12,[rsi+5*16]
	mulps xmm13,[rsi+6*16]
	mulps xmm14,[rsi+7*16]
	addps xmm4,xmm11
	addps xmm5,xmm12
	addps xmm6,xmm13
	addps xmm7,xmm14
	mulps xmm0,xmm4
	mulps xmm1,xmm5
	mulps xmm2,xmm6
	mulps xmm3,xmm7
	movups [rdi],xmm0
	movups [rdi+16],xmm1
	movups [rdi+2*16],xmm2
	movups [rdi+3*16],xmm3
	lea rdi,[rdi+64]
	lea rsi,[rsi+128]
	jnz softlp
	ret
	.align 16
	ones: .float 1,1,1,1
	mones: .float -1,-1,-1,-1
	halfs: .float 0.5,0.5,0.5,0.5
end asm 
end sub

sub truncate naked (result as single ptr,x as single ptr,tr as single,n as ulongint)
asm
  shufps xmm0,xmm0,0
  xorps xmm13,xmm13
  movaps xmm14,amask[rip]
  movaps xmm15,smask[rip]
  .align 16
truncatelp:
	movups xmm1,[rsi]
	movups xmm2,[rsi+16]
	movups xmm3,[rsi+2*16]
	movups xmm4,[rsi+3*16]
	subq rdx,16
	movaps xmm5,xmm1
	movaps xmm6,xmm2
	movaps xmm7,xmm3
	movaps xmm8,xmm4
	andps xmm1,xmm14
	andps xmm2,xmm14
	andps xmm3,xmm14
	andps xmm4,xmm14
	andps xmm5,xmm15
	andps xmm6,xmm15
	andps xmm7,xmm15
	andps xmm8,xmm15
	subps xmm1,xmm0
	subps xmm2,xmm0
	subps xmm3,xmm0
	subps xmm4,xmm0
	maxps xmm1,xmm13
	maxps xmm2,xmm13
	maxps xmm3,xmm13
	maxps xmm4,xmm13
	orps xmm1,xmm5
	orps xmm2,xmm6
	orps xmm3,xmm7
	orps xmm4,xmm8
	movups [rdi],xmm1
	movups [rdi+16],xmm2
	movups [rdi+2*16],xmm3
	movups [rdi+3*16],xmm4
	lea rsi,[rsi+64]
	lea rdi,[rdi+64]
	jnz truncatelp
	ret
	.align 16
    amask: .int 0x7fffffff,0x7fffffff,0x7fffffff,0x7fffffff
	smask: .int 0x80000000,0x80000000,0x80000000,0x80000000
end asm
end sub
'if an element of ifzero is zero the corresponding element of vec is made zero
sub zeroifzero naked (vec as single ptr,ifzero as single ptr,n as ulongint)
asm
  xorps xmm8,xmm8
  .align 16
zifzlp:
	movups xmm0,[rsi]
	movups xmm1,[rsi+16]
	movups xmm2,[rsi+2*16]
	movups xmm3,[rsi+3*16]
	movups xmm4,[rdi]
	movups xmm5,[rdi+16]
	movups xmm6,[rdi+2*16]
	movups xmm7,[rdi+3*16] 
	subq rdx,16
    cmpneqps xmm0,xmm8
    cmpneqps xmm1,xmm8
    cmpneqps xmm2,xmm8
    cmpneqps xmm3,xmm8
    andps xmm4,xmm0
    andps xmm5,xmm1
    andps xmm6,xmm2
    andps xmm7,xmm3
    movups [rdi],xmm4
    movups [rdi+16],xmm5
    movups [rdi+2*16],xmm6
    movups [rdi+3*16],xmm7
    lea rsi,[rsi+64]
	lea rdi,[rdi+64]
	jnz zifzlp   
	ret
end asm
end sub

sub wht(vec as single ptr, n as ulongint)
	   dim as ulongint gap=16
	   dim as single scale=1.0/sqr(n)
	  ' if n<16 then error(1) 				'at least 16 elements
	   'if (n and (n-1))<>0 then error(1)	'must be a power of 2
	   hsixteen(vec,n,scale)
	   while gap<n
		  hgap(vec,gap,n)
		  gap+=gap
	   wend
end sub

'faster for long arrays
sub whtq(vec as single ptr,n as ulongint)
	   const lim as ulongint=8192
	   dim as single scale=1.0/sqr(n)
	   'if n<16 then error(1) 				'at least 16 elements
	   'if (n and (n-1))<>0 then error(1)	'must be a power of 2
	   var k=n
	   if k>lim then k=lim
	   dim as ulongint gap
	   for i as ulongint=0 to n-1 step lim
		   hsixteen(vec+i,k,scale)
		   gap=16
		   while gap<k
			  hgap(vec+i,gap,k)
			  gap+=gap
		   wend
		next
		while gap<n
			hgap(vec,gap,n)
			gap+=gap
		wend	
end sub

sub whtqscale(vec as single ptr,scale as single,n as ulongint)
	   const lim as ulongint=8192
	   scale=scale/sqr(n)
	   'if n<16 then error(1) 				'at least 16 elements
	   'if (n and (n-1))<>0 then error(1)	'must be a power of 2
	   var k=n
	   if k>lim then k=lim
	   dim as ulongint gap
	   for i as ulongint=0 to n-1 step lim
		   hsixteen(vec+i,k,scale)
		   gap=16
		   while gap<k
			  hgap(vec+i,gap,k)
			  gap+=gap
		   wend
		next
		while gap<n
			hgap(vec,gap,n)
			gap+=gap
		wend	
end sub

'40000/s
sub absolute(result as single ptr,x as single ptr,n as ulongint)
	dim as ulong ptr resultptr=cast(ulong ptr,result)
	dim as ulong ptr xptr=cast(ulong ptr,x)
	for i as ulongint=0 to n-1
		resultptr[i]=xptr[i] and &h7fffffff
	next
end sub

sub square(result as single ptr,x as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]*x[i]
	next
end sub

'39000/s
sub signof(result as single ptr,x as single ptr,n as ulongint)
	dim as ulong ptr resultptr=cast(ulong ptr,result)
	dim as ulong ptr xptr=cast(ulong ptr,x)
	for i as ulongint=0 to n-1
		resultptr[i]=(xptr[i] and &h80000000) or &h3f800000 ' or 1!
	next
end sub

'29000/s
sub signedsqr(result as single ptr,x as single ptr,n as ulongint)
	dim as ulong ptr resultptr=cast(ulong ptr,result)
	dim as ulong ptr xptr=cast(ulong ptr,x)
	for i as ulongint=0 to n-1
		dim as ulong f=xptr[i],s=f and &h80000000
		f and=&h7fffffff
		f +=&h3f800000
		f shr=1
		f or=s
		resultptr[i]=f
	next
end sub

'38000/s
sub signedsquare(result as single ptr,x as single ptr,n as ulongint)
	dim as ulong ptr rlptr=cast(ulong ptr,result)
	dim as ulong ptr xlptr=cast(ulong ptr,x)
	for i as ulongint=0 to n-1
		dim as ulong s=&h80000000ul and xlptr[i]
		result[i]=x[i]*x[i]
		rlptr[i] or=s
	next
end sub

'44000/s
sub scale(result as single ptr,x as single ptr,sc as single,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]*sc
	next
end sub

'47000/s
sub add(result as single ptr,x as single ptr,y as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]+y[i]
	next
end sub

'46000/s
sub subtract(result as single ptr,x as single ptr,y as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]-y[i]
	next
end sub

'43000/s
sub multiply(result as single ptr,x as single ptr,y as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]*y[i]
	next
end sub

sub adjust (result as single ptr,x as single ptr,adjscale as single,n as ulongint)
	dim as single adj=adjscale/(sqr(sumsquare(x,n)/n)+MINIMUM_ADJ_)
	scale(result,x,adj,n)
end sub
		
sub zero(x as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		x[i]=0!
	next
end sub

sub zeroidx(x as ulong ptr,n as ulongint)
	for i as ulongint=0 to n-1
		x[i]=0!
	next
end sub

sub copy(result as single ptr,x as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]=x[i]
	next
end sub
 
'25000/s
sub multiplyaddto(result as single ptr,x as single ptr,y as single ptr,n as ulongint)
	for i as ulongint=0 to n-1
		result[i]+=x[i]*y[i]
	next
end sub

'highest set bit, undefined if x=0
function bitscanreverse naked (x as ulong) as ulong
	asm
	bsr eax,edi
	ret
	end asm
end function

' Or signs to s
sub extractsigns(s as ulong ptr,x as single ptr,tobit as ubyte,n as ulongint)
	dim as ulong ptr xptr=cast(ulong ptr,x)
	tobit=31-tobit
	for i as ulongint=0 to n-1
	  s[i] or=(xptr[i] and &h80000000) shr tobit
	next
end sub  

' there must be enough sign bits in x or overrun crash
sub extractindexes(idx() as ulong,x as single ptr,nbits as ubyte)
    dim as ulong ptr xptr=cast(ulong ptr,x),idxptr=@idx(0)
	for i as ulong=0 to ubound(idx)
	  idxptr[i]=0
	  for j as ubyte=0 to nbits-1
		 idxptr[i] or=(*xptr and &h80000000) shr (31-j)
		 xptr+=1
      next
    next
end sub

function extractindex(x as single ptr,nbits as byte) as ulong
	dim as ulong ptr xptr=cast(ulong ptr,x)
	dim as ulong idx
	for i as byte=0 to nbits-1
		 idx or=(*xptr and &h80000000) shr (31-i)
		 xptr+=1
    next
    return idx
end function
	  /' 

randomize 
screenres 512,256,32
dim as single x(65535),y(65535),w(2*65536-1)
dim as ulong s(65535),t(5)
' Test wht
for i as ulong=0 to ubound(x)
	x(i)=rnd()-0.5!
	y(i)=x(i)
next
var t1=timer
for i as ulong=0 to 999
extractsigns(@s(0),@x(0),1,65536)
next
var t2=timer
print " per second",1000/(t2-t1)
'print "Error",errorl2(@x(0),@y(0),65536)
for i as ulong=0 to 20
print s(i):next
extractindexes(t(),@x(0),2)
for i as ulong=0 to ubound(t)
print i,t(i)
next
getkey
'
'hashflip
for i as ulong=0 to ubound(x)
	y(i)=1!
next
for i as ulong=0 to 255
hashflip(@x(0),@y(0),i,65536)
for j as ulong=0 to 255
  pset (j,i),rgb(127*(x(j)+1),0,0)
next
next
t1=timer
for i as ulong=0 to 999
hashflip(@x(0),@y(0),i,65536)
next
t2=timer
print "Hashflip Number per second",1000/(t2-t1)
getkey
'
'sum squared
dim as single uxv
for i as ulong=0 to ubound(x)
	x(i)=rnd
	uxv+=x(i)*x(i)
next
t1=timer
for i as ulong=0 to 999
sumsquare(@x(0),65536)
next
t2=timer
print "SumSq  per second",1000/(t2-t1)
print "Value true,calc",uxv,sumsquare(@x(0),65536)
getkey

'
'errorl2 squared
dim as single iyt
for i as ulong=0 to ubound(x)
	x(i)=rnd
	y(i)=rnd
	iyt+=(x(i)-y(i))*(x(i)-y(i))
next
t1=timer
for i as ulong=0 to 999
errorl2(@x(0),@y(0),65536)
next
t2=timer
print "Errorl2  per second",1000/(t2-t1)
print "Value true,calc",iyt,errorl2(@x(0),@y(0),65536)
getkey

'
'errorl1 abs
dim as single ppo
for i as ulong=0 to ubound(x)
	x(i)=rnd
	y(i)=rnd
	ppo+=abs(x(i)-y(i))
next
t1=timer
for i as ulong=0 to 999
errorl1(@x(0),@y(0),65536)
next
t2=timer
print "Errorl1  per second",1000/(t2-t1)
print "Value true,calc",ppo,errorl1(@x(0),@y(0),65536)
getkey

'
'cdf
cls
for i as ulong=0 to ubound(y)
	y(i)=rnd*2!-1!
next
wht(@y(0),65536)
adjust(@y(0),@y(0),1!,65536)
t1=timer
for i as ulong=0 to 999
cdf(@x(0),@y(0),65536)
next
t2=timer
for i as ulong=0 to 10000 step 2
	dim as ulong r=128+70*x(i)
	dim as ulong s=128+70*x(i+1)
	pset (r,s),rgb(255,255,255)
next	
print "CDF  per second",1000/(t2-t1)
getkey
'
'switch
for i as ulong=0 to ubound(x)
	x(i)=0
next
for i as ulong=0 to ubound(w)
    w(i)=i
next    
t1=timer
for i as ulong=0 to 999
switch(@x(0),@w(0),65536)
next
t2=timer
print "switch  per second",1000/(t2-t1)
for i as ulong=0 to ubound(x)
	x(i)=1
next
switch(@x(0),@w(0),65536)
for i as ulong =0 to 100
print x(i);
next
getkey

'
'switch add to
cls
for i as ulong=0 to ubound(x)
	x(i)=0
next
for i as ulong=0 to ubound(w)
    w(i)=i
next    
t1=timer
for i as ulong=0 to 999
switchaddto(@x(0),@y(0),@w(0),65536)
next
t2=timer
print "switchaddto  per second",1000/(t2-t1)
for i as ulong=0 to ubound(x)
	x(i)=0
	y(i)=1
next
switchaddto(@x(0),@y(0),@w(0),65536)
for i as ulong =0 to 100
print x(i);
next
print
switchaddto(@x(0),@y(0),@w(0),65536)
for i as ulong =0 to 100
print x(i);
next
getkey
'
'
'hashpermute
cls

for i as ulong=0 to 255
for k as ulong=0 to ubound(x)/2
	x(k)=1!
next
for k as ulong=ubound(x)/2 to ubound(x)
	x(k)=-1!
next
hashprm(@x(0),i,65536)
for j as ulong=0 to 255
  pset (j,i),rgb(127*(x(j)+1),0,0)
next
next
t1=timer
for i as ulong=0 to 999
hashprm(@x(0),i,65536)
next
t2=timer
print "Hashpermute Number per second",1000/(t2-t1)
getkey

'
'hashpermuteinv
cls
for k as ulong=0 to ubound(x)
	x(k)=k
next
hashprm(@x(0),123456,65536)
print 12345,x(12345),"not equal ok,prm"
hashprminv(@x(0),123456,65536)
print 12345,x(12345),"equal ok,invprm"
t1=timer
for i as ulong=0 to 999
hashprminv(@x(0),i,65536)
next
t2=timer
print "Hashpermuteinv Number per second",1000/(t2-t1)
getkey

'
'hstep
cls
for k as ulong=0 to ubound(y)
	y(k)=k
next
dim as single ptr xp=@x(0),yp=@y(0),tp
for i as ulong=0 to 31
hstep(xp,yp,65536)
tp=xp
xp=yp
yp=tp
next
print "hstep",0,y(0),6777,y(6777),65535,y(65535)
t1=timer
for i as ulong=0 to 999
hstep(xp,yp,65536)
next
t2=timer
print "Hstep per second",1000/(t2-t1)
getkey
'
'clip
cls
for k as ulong=0 to ubound(y)
	y(k)=rnd*2!-1!
next
clipmin(@x(0),@y(0),-.3!,65536)
for i as ulong=0 to 65535
 dim as single v=y(i)
 if v<-0.3! then v=-0.3!
 if v<>x(i) then print "clip min error"
next
clipmax(@x(0),@y(0),.7!,65536)
for i as ulong=0 to 65535
 dim as single v=y(i)
 if v>0.7! then v=0.7!
 if v<>x(i) then print "clip max error"
next
clip(@x(0),@y(0),-.5!,.5!,65536)
for i as ulong=0 to 65535
 dim as single v=y(i)
 if v>0.5! then v=0.5!
 if v<-.5! then v=-.5!
 if v<>x(i) then print "clip error"
next
t1=timer
for i as ulong=0 to 999
clip(@x(0),@y(0),-.5!,.5!,65536)
next
t2=timer
print "Clip per second",1000/(t2-t1)
getkey
'/

/'
dim as single x(65535),y(65535)
for i as ulong=0 to 65535 step 2
 y(i)=i
 y(i+1)=-i
next
truncate(@x(0),@y(0),0,65536)
for i as ulong=0 to 200
   print x(i),y(i)
next 
'/
/'
dim as single x(65535),y(65535)
for i as ulong=0 to 65535
  x(i)=i
  y(i)=-i-1
next
truncate(@y(0),@y(0),29,65536)
zeroifzero(@x(0),@y(0),65536)
for i as ulong=0 to 200
   print x(i),y(i)
next 
getkey
'/


.section .data
filename: .string "input.txt"
yes: .string "Yes\n"
nope: .string "No\n"
mode: .string "r"

.section .text
.global main


main:
    addi sp, sp, -32
    sd s2, 24(sp)
    sd s1, 16(sp)
    sd ra, 8(sp)
    sd s0, 0(sp)

    la a0, filename
    la a1, mode
    call fopen

    # now suppose I have the pointer in a0

    mv s0, a0
    li a1, 0
    li a2, 2
    call fseek
    mv a0,s0
    call ftell

    li s1, 0
    mv s2, a0   # s2 contains the number of characters now
    addi s2, s2, -1     #stores the left offset

recur:
    bge s1, s2, success
    mv a0,s0
    mv a1, s1
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    #now a0 contains the first element
    mv t0, a0

    mv a0,s0
    mv a1, s2
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    #now a0 contains the second element
    mv t1, a0
    bne t0,t1, fail
    addi s1, s1, 1
    addi s2, s2, -1

    j recur
    


fail:
    #printf no
    la a0, nope
    call printf
    ld s2, 24(sp)
    ld s1, 16(sp)
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 32
    ret

success:
    #printf
    la a0, yes
    call printf
    ld s2, 24(sp)
    ld s1, 16(sp)
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 32
    ret
    

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

    la a0, filename #loading the address of the string as the first arguement
    la a1, mode     #loading the "r" mode
    call fopen      #calling the func with above two args

    # now I have the pointer in a0

    mv s0, a0   #moving it for other function calls
    li a1, 0    #offset from the start
    li a2, 2    #end of the file
    call fseek
    mv a0,s0    #moving the pointer back
    call ftell  #to check the size of the file(cursor and start difference)

    li s1, 0    #for the before offset
    mv s2, a0   # s2 contains the number of characters now
    addi s2, s2, -1     #stores the left offset

recur:
    bge s1, s2, success     #if the pointers cross, then success
    mv a0,s0    #file pointer
    mv a1, s1   #offset
    li a2, 0
    call fseek  #the cursor gets updated and goes there
    mv a0, s0
    call fgetc
    #now a0 contains the first element
    mv t0, a0   #moving it to t0

    mv a0,s0
    mv a1, s2
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    #now a0 contains the second element
    mv t1, a0   #moving it to t1 for comparison with t0
    bne t0,t1, fail
    addi s1, s1, 1
    addi s2, s2, -1     #updating the offsets

    j recur
    


fail:
    #printf no
    la a0, nope #loading the address of the no string for printing
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
    call printf     #printing yes
    ld s2, 24(sp)
    ld s1, 16(sp)
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 32
    ret
    

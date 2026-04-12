# Saved registers:
#   s0 = argc
#   s1 = argv
#   s2 = n  (argc - 1)
#   s3 = arr[]        
#   s4 = result[]    
#   s5 = stack_data[] (monotonic index stack)
#   s6 = stack top    (current stack size)
#   s7 = loop index i

.data
fmt_val:    .string "%lld "
fmt_nl:     .string "\n"

.text
.globl main

main:
        # save ra + s0-s7 (9 regs × 8 = 72; and then padding for alignment)
        addi sp, sp, -80
        sd ra, 72(sp)
        sd s0, 64(sp)
        sd s1, 56(sp)
        sd s2, 48(sp)
        sd s3, 40(sp)
        sd s4, 32(sp)
        sd s5, 24(sp)
        sd s6, 16(sp)
        sd s7,  8(sp)

        mv s0, a0   # s0 = argc
        mv s1, a1   # s1 = argv

        addi s2, s0, -1     # s2 = n = argc-1
        beq s2, x0, exit_main

        #using malloc for the arrays

        slli a0, s2, 3   # n * 8 bytes
        call malloc
        mv s3, a0   # s3 = arr

        slli a0, s2, 3
        call malloc
        mv s4, a0   # s4 = result

        slli a0, s2, 3
        call malloc
        mv  s5, a0  # s5 = stack_data

        # Parse argv into arr[] into integer
        li  s7, 0

parse_loop:
        bge s7, s2, parse_done
        addi t0, s7, 1  # argv index = i+1
        slli t0, t0, 3
        add t0, s1, t0  # &argv[i+1]
        ld a0, 0(t0)    # getting the actual char into a0
        call atoi
        slli a0, a0, 32     # manual sign-extend start
        srai a0, a0, 32     # manual sign-extend end
        slli t1, s7, 3
        add t1, s3, t1
        sd a0, 0(t1)        # arr[i] = value
        addi s7, s7, 1
        j parse_loop

parse_done:
        # initializing all as -1 first
        li s7, 0
init_loop:
        bge s7, s2, init_done
        slli t0, s7, 3
        add t0, s4, t0
        li t1, -1
        sd t1, 0(t0)
        addi s7, s7, 1
        j init_loop

init_done:
        li s6, 0    # s6 = stack size

        # Main loop from n-1 down to 0
        addi s7, s2, -1     # i = n-1
main_loop:
        blt s7, x0, main_done     # breaking from the loop

        # t4 = arr[i]
        slli t4, s7, 3
        add t4, s3, t4
        ld t4, 0(t4)

        # keep popping till not empty or the curr empty is greater than equal to the top of the stack
while_loop:
        beq s6, x0, while_done

        addi t0, s6, -1
        slli t0, t0, 3
        add t0, s5, t0
        ld t1, 0(t0)    # t1 = top index

        slli t2, t1, 3
        add t2, s3, t2
        ld t2, 0(t2)    # t2 = arr[top_index]

        bgt t2, t4, while_done      # arr[top] > arr[i] stop pop
        addi s6, s6, -1     # pop
        j while_loop

while_done:
        # if stack not empty: result[i] = stack.top()
        beq s6, x0, do_push
        addi t0, s6, -1
        slli t0, t0, 3
        add t0, s5, t0
        ld t1, 0(t0)    # t1 = top index
        slli t2, s7, 3
        add t2, s4, t2
        sd t1, 0(t2)    # result[i] = top index

do_push:
        # stack.push(i)
        slli t0, s6, 3
        add t0, s5, t0
        sd s7, 0(t0)    # stack_data[s6] = i
        addi s6, s6, 1

        addi s7, s7, -1
        j main_loop

main_done:
        # printing the array 
        li s7, 0    # Start printing from index 0
print_loop:
        bge s7, s2, print_done
        slli t0, s7, 3
        add t0, s4, t0
        ld a1, 0(t0)    # result[i]
        la a0, fmt_val              
        call printf
        addi s7, s7, 1
        j print_loop

print_done:
        la a0, fmt_nl   # "\n"
        call printf

        #freeing the malloced array
        mv a0, s3
        call free
        mv a0, s4
        call free
        mv a0, s5
        call free

exit_main:
        li a0, 0    # return 0

        ld s7,  8(sp)
        ld s6, 16(sp)
        ld s5, 24(sp)
        ld s4, 32(sp)
        ld s3, 40(sp)
        ld s2, 48(sp)
        ld s1, 56(sp)
        ld s0, 64(sp)
        ld ra, 72(sp)
        addi sp, sp, 80
        ret

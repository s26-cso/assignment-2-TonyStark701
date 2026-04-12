.section .text
.extern malloc
.extern free
.global make_node
.global insert
.global get
.global getAtMost


make_node:
    addi sp,sp,-16
    sd ra, 8(sp)
    sd s0, 0(sp)

    mv s0,a0

    li a0, 24
    call malloc

    sw s0, 0(a0)
    sd x0, 8(a0)
    sd x0,16(a0)

    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp,sp,16
    ret

insert:
    addi sp, sp, -48
    sd ra, 16(sp)
    sd s0, 24(sp)
    sd s1, 32(sp)
    sd a0, 0(sp)
    sw a1, 8(sp) 

    mv a0,a1
    jal ra, make_node

    # so now the a0 contains the node
    mv s0, a0 # move it so that the root and the val can be loaded

    ld a0, 0(sp)
    lw a1, 8(sp)

    mv s1, a0

    #s0 has our struct pointer, a0 has root (struct pointer), a1 has our inputted val, s1 is used for the current struct ka pointer

    beq a0, x0, insert_create_tree

    #better to check if null before moving either left or right
    #ao contains root and a1 contains the val to be inserted

    insert_main:
        lw t0, 0(s1) #so t0 has the integer value now

        blt t0, a1, insert_go_right   #if curr value is less than the val, then move to the right

        ld t0, 8(s1) #t0 has the left address now
        beq x0, t0, actual_insert_left

        mv s1, t0
        j insert_main


        actual_insert_left:
            sd s0, 8(s1)
            j insert_done


    insert_go_right:
        ld t0, 16(s1) #t0 has the right address now
        beq x0, t0, actual_insert

        mv s1, t0
        j insert_main


        actual_insert:
            sd s0, 16(s1)
            j  insert_done


    insert_create_tree:
        mv a0, s0

        ld ra, 16(sp)
        ld s1, 32(sp)
        ld s0, 24(sp)
        addi sp, sp, 48
        ret
    

    insert_done:
        ld a0, 0(sp)
        ld ra, 16(sp)
        ld s1, 32(sp)
        ld s0, 24(sp)
        addi sp, sp, 48
        ret

get:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    get_finder:
        get_check_null:     # add condition where a0 is null
            beq a0,x0,get_done

        lw t2, 0(a0) 
        beq a1, t2, get_done # a1 contains the target and t2 contains the curr_number
        blt a1,t2, get_move_left #target<curr
        ld a0, 16(a0)
        j get_finder # beq x0,x0 replaced with j for clarity

    get_move_left:
        ld a0, 8(a0)
        j get_finder

    get_done:
        ld ra, 8(sp)
        ld s0, 0(sp)
        addi sp,sp,16
        ret

#using a t3 for the next one

getAtMost:
    addi sp,sp,-16
    sd ra, 8(sp)
    sd s0, 0(sp)

    li t3, -1

    #a0 contains the int target
    #a1 has the pointer to the cur

    atmost_main_func:
        beq a1,x0, atmost_done
        lw s0, 0(a1)
        blt a0,s0, atmost_move_left #if a0 is smaller,then go left

        #now we know that s0 is less or equal
        mv t3, s0
        ld a1, 16(a1)
        j atmost_main_func

    atmost_move_left:
        ld a1, 8(a1)
        j atmost_main_func

    atmost_done:
        mv a0, t3
        ld ra, 8(sp)
        ld s0, 0(sp)
        addi sp,sp,16
        ret

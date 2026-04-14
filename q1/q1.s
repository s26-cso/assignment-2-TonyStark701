.section .text
.global make_node
.global insert
.global get
.global getAtMost


make_node:
    addi sp,sp,-16
    sd ra, 8(sp)
    sd s0, 0(sp)    #the usual storing ra and s registers in the stack

    mv s0,a0    #moving the integer argument from the arguement reg to the s reg

    li a0, 24
    call malloc     #calling malloc with the address at a0 and 24 coz int,left,right pointers

    sw s0, 0(a0)
    sd x0, 8(a0)
    sd x0,16(a0)    #assigning the integer, left=NULL and right = NULL

    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp,sp,16       #restoring the earlier values int the registers for returning
    ret

insert:
    addi sp, sp, -48
    sd ra, 16(sp)
    sd s0, 24(sp)
    sd s1, 32(sp)   #the usual storing ra and s registers in the stack
    sd a0, 0(sp)    #the root pointer is stored here
    sw a1, 8(sp)    #the integer is also stored in the stack just in case

    mv a0,a1    #moving the integer into the arguemnet register for the make_node function
    jal ra, make_node

    # so now the a0 contains the node
    mv s0, a0 # move it so that the root and the val can be loaded

    ld a0, 0(sp)    #root
    lw a1, 8(sp)    #insert val

    mv s1, a0   

    #s0 has our struct pointer of the node with our integer, a0 has root (struct pointer), a1 has our inputted val, s1 is used for the current struct ka pointer

    beq a0, x0, insert_create_tree      #if root is NULL, then just directly return it as the root


    insert_main:
        lw t0, 0(s1) #so t0 has the integer value of the struct now

        blt t0, a1, insert_go_right   #if curr value is less than the val, then move to the right

        ld t0, 8(s1) #t0 has the left address now
        beq x0, t0, actual_insert_left  #if the left is NULL, then insert here

        mv s1, t0   #move the t0 address to the s0 for next iteration
        j insert_main


        actual_insert_left:
            sd s0, 8(s1)    #store the s0 node as te left of the s1 node
            j insert_done


    insert_go_right:
        ld t0, 16(s1) #t0 has the right address now
        beq x0, t0, actual_insert   #if t0 is null, insert

        mv s1, t0   #changing s1 for iteration
        j insert_main


        actual_insert:
            sd s0, 16(s1)   #store s0 in the right node
            j  insert_done


    insert_create_tree:
        mv a0, s0   #mainly for the root is NULL case

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
        addi sp, sp, 48 #restoring all regs
        ret

get:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    get_finder:
        get_check_null:     # add condition where a0 is null
            beq a0,x0,get_done

        lw t2, 0(a0) 
        beq a1, t2, get_done # if a1 and t2 are equal, done
        blt a1,t2, get_move_left #target<curr
        ld a0, 16(a0)   #if curr>target, go right
        j get_finder # beq x0,x0 replaced with j for clarity

    get_move_left:
        ld a0, 8(a0)
        j get_finder

    get_done:
        ld ra, 8(sp)
        ld s0, 0(sp)
        addi sp,sp,16
        ret


getAtMost:
    addi sp,sp,-16
    sd ra, 8(sp)
    sd s0, 0(sp)

    li t3, -1   #t3 is storing -1 for now, but in general, it stores the best candidate

    #a0 contains the int target
    #a1 has the pointer to the cur

    atmost_main_func:
        beq a1,x0, atmost_done  #if a1 is NULL, done
        lw s0, 0(a1)    #getting the curr integer into s0
        blt a0,s0, atmost_move_left #if a0 is smaller,then go left

        #now we know that s0 is less or equal
        mv t3, s0   #t3 updation, as this has to be the best candidate
        ld a1, 16(a1)   #going right
        j atmost_main_func

    atmost_move_left:
        ld a1, 8(a1)
        j atmost_main_func

    atmost_done:
        mv a0, t3   #value of t3 put into a0
        ld ra, 8(sp)
        ld s0, 0(sp)
        addi sp,sp,16
        ret

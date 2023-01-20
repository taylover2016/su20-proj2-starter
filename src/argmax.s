.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:

    # Prologue
    # s0 -> index of the largest element
    # s1 -> largest value
    addi sp, sp, -8
    sw s0, 4(sp)
    sw s1, 0(sp)

    # Check the length of the array
    addi t0, x0, 1 
    bge a1, t0, continue # if a1 >= t0 then jump to loop_start
    addi a1, x0, 7
    j exit2

continue:
    # Set the initial value for the largest element and the index
    add s0, x0, x0
    lw s1, 0(a0)

loop_start:
    # Use a1 to loop
    beq a1, x0, loop_end
    addi a1, a1, -1
    
    # Use slli to index into memory
    slli t0, a1, 2
    add t0, t0, a0

    # Read in the number and compare it with the current largest one
    lw t1, 0(t0)
    blt t1, s1, loop_start # if t1 <= largest_val then no need to update
    
    # Update the value and the index
    add s1, t1, x0
    add s0, a1, x0
    j loop_start

loop_end:
    add a0, s0, x0
    # Epilogue
    lw s0, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 8
    ret
.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Prologue

    # Check the length of the array
    addi t0, x0, 1 
    bge a1, t0, loop_start # if a1 >= t0 then jump to loop_start
    addi a1, x0, 8
    j exit2

loop_start:
    # Use a1 to loop
    beq a1, x0, loop_end
    addi a1, a1, -1
    
    # Use slli to index into memory
    slli t0, a1, 2
    add t0, t0, a0

    # Read in the number and revise it if necessary
    lw t1, 0(t0)
    bge t1, x0, loop_start # if x0 <= t1 then no need to revise
    sw x0, 0(t0)
    j loop_start

loop_end:
    # Epilogue

	ret
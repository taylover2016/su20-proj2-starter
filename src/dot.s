.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:
    # Validate the input
    addi t0, x0, 1 
    blt a2, t0, exception_5 # if a2 < 1 then exit with exception code 5
    blt a3, t0, exception_6 # if a3 < 1 then exit with exception code 6
    blt a4, t0, exception_6 # if a4 < 1 then exit with exception code 6
    
    j initialize  # jump to initialize

exception_5:
    addi a1, x0, 5
    j exit2

exception_6:
    addi a1, x0, 6
    j exit2

initialize:
    # Prologue
    # s0 -> dot product cache
    addi sp, sp, -4
    sw s0, 0(sp)
    
    add s0, x0, x0

loop_start:
    beq a2, x0, loop_end
    addi a2, a2, -1
    
    # Calculate the indices
    # t0 -> index of the next element in v0
    # t1 -> index of the next element in v1
    mul t0, a2, a3
    mul t1, a2, a4
    
    # Transform into addresses
    slli t0, t0, 2
    slli t1, t1, 2
    add t0, t0, a0
    add t1, t1, a1

    # Load the elements
    lw t0, 0(t0)
    lw t1, 0(t1)

    # Calculate the product and add to cache
    mul t0, t0, t1
    add s0, s0, t0
    
    j loop_start

loop_end:
    add a0, s0, x0

    # Epilogue
    lw s0, 0(sp)
    addi sp, sp, 4
    
    ret
.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    # Check the dimensions of m0
    li t0, 1
    blt a1, t0, exception_m0
    blt a2, t0, exception_m0
    blt a4, t0, exception_m1
    blt a5, t0, exception_m1
    bne a2, a4, exception_match

    # Prologue
    # s0 -> current sum of the product
    # s1 -> current element of the final matrix product
    # ra -> need to call "dot"
    # t0 -> row index of the first matrix
    # t1 -> col index of the second matrix
    addi sp, sp, -12
    sw s1, 8(sp)
    sw s0, 4(sp)
    sw ra, 0(sp)

    add s0, x0, x0
    li t0, 0
    li t1, 0

outer_loop_start:
    beq t0, a1, outer_loop_end

inner_loop_start:
    beq t1, a5, inner_loop_end

    # Save a0-a4, t0-t1, and ra
    addi sp, sp, -32
    sw a0, 28(sp)
    sw a1, 24(sp)
    sw a2, 20(sp)
    sw a3, 16(sp)
    sw a4, 12(sp)
    sw t0, 8(sp)
    sw t1, 4(sp)
    sw ra, 0(sp)

    # Set the arguments
    # Calculate the address first
    mul t2, t0, a2
    add t3, t1, x0
    slli t2, t2, 2
    slli t3, t3, 2
    add t2, t2, a0
    add t3, t3, a3

    # Push the arguments and call the dot function
    add a0, t2, x0
    add a1, t3, x0
    add a2, a2, x0
    li a3, 1
    add a4, a5, x0

    jal dot  # jump to dot and save position to ra
    
    # Save the result and restore the registers
    add s1, a0, x0
    
    lw a0, 28(sp)
    lw a1, 24(sp)
    lw a2, 20(sp)
    lw a3, 16(sp)
    lw a4, 12(sp)
    lw t0, 8(sp)
    lw t1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    
    # Calculate the corresponding position in memory
    # At row t0, col t1
    mul t2, t0, a5
    add t3, t2, t1
    slli t3, t3, 2
    add t3, t3, a6
    sw s1, 0(t3)

    addi t1, t1, 1
    j inner_loop_start

inner_loop_end:
    addi t0, t0, 1
    add t1, x0, x0
    j outer_loop_start

outer_loop_end:
    

    # Epilogue
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12
    
    ret

exception_m0:
    addi a1, x0, 2
    j exit2

exception_m1:
    addi a1, x0, 3
    j exit2

exception_match:
    addi a1, x0, 4
    j exit2
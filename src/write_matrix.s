.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    # s0 -> pointer to the memory storing the matrix
    # s1 -> the row of the matrix
    # s2 -> the col of the matrix
    # s3 -> pointer to the filename string / file descriptor
    # s4 -> matrix size in bytes
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    # Back up the arguments
    add s0, a1, x0
    add s1, a2, x0
    add s2, a3, x0
    add s3, a0, x0
    mul s4, s1, s2

    # Open the file
    add a1, s3, x0
    li a2, 1
    jal fopen

    # Exit with error code 53 if fopen fails
    li t0, -1
    beq a0, t0, fopen_error
    add s3, a0, x0

    # Write rows and cols into the file
    # Use the stack to provide the memory address
    addi sp, sp, -8
    sw s1, 4(sp)    # sp+4 -> s1
    sw s2, 0(sp)    # sp -> s2

    # Write to the file
    # First the rows
    add a1, s3, x0
    addi a2, sp, 4
    li a3, 1
    li a4, 4
    jal fwrite

    # Check if write is complete
    addi t0, x0, 1
    bne a0, t0, fwrite_error

    # Then the cols
    add a1, s3, x0
    add a2, sp, x0
    li a3, 1
    li a4, 4
    jal fwrite

    # Check if write is complete
    addi t0, x0, 1
    bne a0, t0, fwrite_error
    addi sp, sp, 8

    # Write the matrix
    add a1, s3, x0
    add a2, s0, x0
    add a3, s4, x0
    li a4, 4
    jal fwrite

    # Check if write is complete
    add t0, x0, s4
    bne a0, t0, fwrite_error

    # Close the file
    add a0, s3, x0
    jal fclose

    # Exit with error code 55 if fclose fails
    bne a0, x0, fclose_error

    # Epilogue
    lw ra, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 24

    ret


fopen_error:
    addi a1, x0, 53
    j exit2

fwrite_error:
    addi a1, x0, 54
    j exit2

fclose_error:
    addi a1, x0, 55
    j exit2
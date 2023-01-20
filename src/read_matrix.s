.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
    # s0 -> pointer to the memory storing the matrix
    # s1 -> pointer to the row of the matrix
    # s2 -> pointer to the col of the matrix
    # s3 -> pointer to the filename string / file descriptor
    # s4 -> matrix size
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    # Back up the arguments
    add s1, a1, x0
    add s2, a2, x0
    add s3, a0, x0

    # Open the file
    add a1, s3, x0
    li a2, 0
    jal fopen

    # Exit with error code 50 if fopen fails
    li t0, -1
    beq a0, t0, fopen_error
    add s3, a0, x0

    # Read the rows and cols
    # First the rows
    add a1, s3, x0
    add a2, s1, x0
    li a3, 4
    jal fread

    # Exit with error code 51 if fread fails
    li t0, 4
    bne a0, t0, fread_error

    # Then the cols
    add a1, s3, x0
    add a2, s2, x0
    li a3, 4
    jal fread

    # Exit with error code 51 if fread fails
    li t0, 4
    bne a0, t0, fread_error

    # Read the row and the col
    lw t1, 0(s1)
    lw t2, 0(s2)

    # Calculate the bytes needed for allocation
    mul t0, t1, t2
    slli t0, t0, 2
    add s4, t0, x0

    # Allocate memory for the matrix
    add a0, s4, x0
    jal malloc

    # Exit with error code 48 if malloc fails
    li t0, 0
    beq a0, t0, malloc_error
    add s0, a0, x0

    # Read in the matrix
    add a1, s3, x0
    add a2, s0, x0
    add a3, s4, x0
    jal fread

    # Exit with error code 51 if fread fails
    bne a0, s4, fread_error

    # Close the file
    add a0, s3, x0
    jal fclose

    # Exit with error code 52 if fclose fails
    bne a0, x0, fclose_error

    # Return the pointer to caller
    add a0, s0, x0

    # Epilogue
    lw ra, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 24

    ret

malloc_error:
    addi a1, x0, 48
    j exit2

fopen_error:
    addi a1, x0, 50
    j exit2

fread_error:
    addi a1, x0, 51
    j exit2

fclose_error:
    addi a1, x0, 52
    j exit2
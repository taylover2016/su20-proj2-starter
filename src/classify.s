.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Check the command line arguments first
    li t0, 5
    bne a0, t0, argc_error

    # Prologue
    # s0 -> m0
    # s1 -> m1
    # s2 -> input
    # s3/s4 -> addresses of the dimensions of m0
    # s5/s6 -> addresses of the dimensions of m1
    # s7/s8 -> addresses of the dimensions of input
    # s9 -> a1
    # s10 -> a2
    # s11 -> address of the current result

    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    # Backup arguments
    add s9, a1, x0
    add s10, a2, x0


	# =====================================
    # LOAD MATRICES
    # =====================================

    # Decrement sp for storing dimensions
    addi sp, sp, -24

    # Load pretrained m0
    # Set the arguments
    lw s0, 4(s9)
    addi s3, sp, 0
    addi s4, sp, 4

    add a0, s0, x0
    add a1, s3, x0
    add a2, s4, x0

    jal read_matrix

    # Save the address
    add s0, a0, x0


    # Load pretrained m1
    # Set the arguments
    lw s1, 8(s9)
    addi s5, sp, 8
    addi s6, sp, 12

    add a0, s1, x0
    add a1, s5, x0
    add a2, s6, x0

    jal read_matrix

    # Save the address
    add s1, a0, x0


    # Load input matrix
    # Set the arguments
    lw s2, 12(s9)
    addi s7, sp, 16
    addi s8, sp, 20

    add a0, s2, x0
    add a1, s7, x0
    add a2, s8, x0

    jal read_matrix

    # Save the address
    add s2, a0, x0





    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # Layer 1
    # Malloc for the result
    # Calculate the bytes needed for allocation
    lw t1, 0(s3)
    lw t2, 0(s8)
    mul t0, t1, t2
    slli t0, t0, 2

    # Allocate memory for the matrix
    add a0, t0, x0
    jal malloc

    # Exit with error code 48 if malloc fails
    li t0, 0
    beq a0, t0, malloc_error
    add s11, a0, x0
    
    #a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
    add a0, s0, x0
    lw a1, 0(s3)
    lw a2, 0(s4)
    add a3, s2, x0
    lw a4, 0(s7)
    lw a5, 0(s8)
    add a6, s11, x0

    jal matmul

    # Layer 2 ReLU
#   Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
    add a0, s11, x0
    lw t1, 0(s3)
    lw t2, 0(s8)
    mul t0, t1, t2
    add a1, t0, x0
    jal relu
    
    
    # Layer 3
    # Free the room for m0 and input
    add a0, s0, x0
    jal free
    add a0, s2, x0
    jal free

    # Malloc for the result
    # Calculate the bytes needed for allocation
    lw t1, 0(s5)
    lw t2, 0(s8)
    mul t0, t1, t2
    slli t0, t0, 2

    # Allocate memory for the matrix
    add a0, t0, x0
    jal malloc

    # Exit with error code 48 if malloc fails
    li t0, 0
    beq a0, t0, malloc_error
    add s0, a0, x0
    
    #a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
    add a0, s1, x0
    lw a1, 0(s5)
    lw a2, 0(s6)
    add a3, s11, x0
    lw a4, 0(s3)
    lw a5, 0(s8)
    add a6, s0, x0

    jal matmul


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    
    # Now scores stored in s0
    # Output the matrix to a binary file
    #Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
    lw a0, 16(s9)
    add a1, s0, x0
    lw a2, 0(s5)
    lw a3, 0(s8)

    jal write_matrix




    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    # Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
    add a0, s0, x0
    lw t0, 0(s5)
    lw t1, 0(s8)
    mul a1, t0, t1
    jal argmax



    # Print classification
    bne s10, x0, skip
    add a1, a0, x0
    jal ra print_int


    # Print newline afterwards for clarity
    li a1 '\n'
    jal ra print_char

    
    # Free the malloc-ed memory
    # Memory holding all the matrices
skip:
    # s0, s1, s11
    add a0, s0, x0
    jal free
    add a0, s1, x0
    jal free
    add a0, s11, x0
    jal free

    # Epilogue
    # Increment sp for storing dimensions
    addi sp, sp, 24
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52

    ret

argc_error:
    addi a1, x0, 49
    j exit2

malloc_error:
    addi a1, x0, 48
    j exit2
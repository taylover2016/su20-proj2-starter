.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory
    # Save the row and the col to memory
    li t0, 3
    li t1, 3
    addi sp, sp, -8
    sw t0, 4(sp)
    sw t1, 0(sp)

    # Set the arguments and call the function
    la a0 file_path
    addi t2, sp, 4
    add a1, t2, x0
    add a2, sp, x0
    jal read_matrix

    # Print out elements of matrix
    #mv a0 s2
    li a1 3
    li a2 3
    jal print_int_array

    # Terminate the program
    addi sp, sp, 8
    jal exit
    
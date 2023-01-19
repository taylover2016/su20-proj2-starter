.import ../../src/matmul.s
.import ../../src/utils.s
.import ../../src/dot.s

# static values for testing
.data
m0: .word 1 2 3 4 5 6 7 8 9
m1: .word 1 2 3 4 5 6 7 8 9
d: .word 0 0 0 0 0 0 0 0 0 # allocate static space for output

.text
main:
    # Load addresses of input matrices (which are in static memory), and set their dimensions
    la s0 m0
    la s1 m1
    la s2 d

    # Set matrix attributes
    add a0, s0, x0
    addi a1, x0, 3
    addi a2, x0, 3
    add a3, s1, x0
    addi a4, x0, 3
    addi a5, x0, 3
    add a6, s2, x0

    # Call matrix multiply, m0 * m1
    jal matmul

    # Print the output (use print_int_array in utils.s)
    # Print m0 after running relu
    mv a0 s2
    li a1 3
    li a2 3
    jal print_int_array

    # Exit the program
    jal exit
.section .text
.globl _start

_start:
    add x1, x2, x3
    sub x2, x3, x4
    # xor x3, x4, x5
    # or x4, x5, x6
    # and x5, x6, x7
    # sll x6, x7, x8
    # slli x5, x6, 7
    lb x1, 3(x5)
    sb x1, 0(x4)
    sub x2, x3, x4
    xor x3, x4, x5
    lb x4, 6(x5)
    sub x2, x5, x6
    lb x1, 0(x5)
    sub x2, x3, x4
    sb x2, 0(x3)
    xor x3, x4, x5
    sb x1, 0(x4)
    sb x5, 2(x4)
# Test the RISC-V processor.
# add, sub, and, or, slt, addi, lw, sw, beq, jal
# If successful, it should write the value 71 to address 84
main:
    addi x2, x0, 5              # initialize x2 = 5             0
    addi x3, x0, 12             # initialize x3 = 12            1
    addi x7, x3, -9             # initialize x7 = 3             2
    or x4, x7, x2               # x4 = (3 OR 5) = 7             3
    and x5, x3, x4              # x5 = (12 AND 7) = 4           4
    add x5, x5, x4              # x5 = 4 + 7 = 11               5
    beq x5, x7, end             # shouldn't be taken            6
    slt x4, x3, x4              # x4 = (12 < 7) = 0             7
    beq x4, x0, around          # should be taken               8
    addi x5, x0, 0              # shouldn't happen              9
around:
    slt x4, x7, x2              # x4 = (3 < 5) = 1              10
    add x7, x4, x5              # x7 = 1 + 11 = 12              11
    sub x7, x7, x2              # x7 = 12 - 5 = 7               12
    sw x7, 68(x3)               # [80] = 7                      13
    lw x2, 80(x0)               # x2 = [80] = 7                 14
    jal x3, end                 # save 64 in x3                 15
    addi x2, x0, 1              # shouldn't happen              16
end:
    add x2, x2, x3              #x2 = 7 + 64 = 71               17
    sw x2, 84(x0)               # write mem[84] = 71            18
    j main

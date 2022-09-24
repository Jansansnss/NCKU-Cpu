main:
    addi $a0, $zero, 10 # n = 10
    addi $a1, $zero, 5  # m = 5
    jal pascal          # call pascal(10, 5)
    j exit
pascal:
    #addi $sp, $sp, -16
    slt $t0, $a1, $zero
    slt $t1, $zero, $a1
    or $t0, $t0, $t1# when m==0 the result is 0
    slt $t2, $a0, $a1
    slt $t3, $a1, $a0
    or $t2, $t2, $t3#when m==n the result is 0
    and $t0, $t2, $t0
    bne $t0, $zero, more_pascal
    addi $v0, $v0, 1
    #addi $sp, $sp, 16
    jr $ra
more_pascal: 
    addi $sp, $sp, -12
    sw $ra, 0x0($sp)    # Save $ra register into stack
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    add $a0, $a0, -1
    jal pascal
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    add $a0, $a0, -1
    add $a1, $a1, -1
    jal pascal
    lw $ra, 0x0($sp)
    addi $sp, $sp, 12
    jr $ra
exit:

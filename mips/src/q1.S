main:
    addi $a0, $zero, 19654 # a0= 19654
    addi $a1, $zero, 100654  # a1=100654
    addi $a2, $zero, 10065  # a2= 10065
    jal average     # call average
    j exit

average:
    addi $sp, $sp, -12
    sw $ra, 0x0($sp)    # Save $ra register into stack	
    add $t0, $a0, $a1
    add $t0, $t0, $a2
loop: slti $t2, $t0, 3
    beq $t2, 1, loopend
    addi $t0, $t0, -3
    addi $t3, $t3, 1
    jal loop
loopend: lw $ra, 0x0($sp)    # Load $ra register from stack
    add $v0, $zero, $t3
    addi $sp, $sp, 12
    jr $ra

exit:

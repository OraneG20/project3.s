.data
        input_too_long: .asciiz "Input is too long."
        user_input: .space 9000
        input_empty: .asciiz "Input is empty."
        wrong_base: .asciiz "Invalid base-35 number."  
.text
main:
        # getting user input

        li $v0, 8
        la $a0, user_input
        li $a1, 9000
        syscall

        add $s0, $0, 0          # Initializing registers
        add $t7, $0, 0 		# Initializing registers
        addi $s1, $0, 0		# Initializing registers

                                       # input check
        la $t4, user_input              # set pointer
        lb $s0, 0($t4)                  # load first element of string 
        beq $s0, 10, empty_error        # new line check
        beq $s0, 0, empty_error	# empty byte check

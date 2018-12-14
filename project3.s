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
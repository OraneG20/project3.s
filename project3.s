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
        beq $s0, 0, empty_error	        # empty byte check

        addi $s5, $0, 35        # Set Base number
        addi $t5, $0, 0		# Initializing registers
        addi $s3, $0, 1         # Initialize register as 1 
        addi $t6, $0, 0		# Initializing registers
        addi $t9, $0, 0		# Initializing registers
        
space_traversal:                        # this label skips the spaces in the string until we find the irst character
        lb $s0, 0($t4)                  # load character pointer is at into the register t7
        addi $t4, $t4, 1                # incrementing pointer
        addi $t7, $t7, 1                # incrementing counter
        beq $s0, 32, space_traversal    # loop and move forward if space detected
        beq $s0, 10, empty_error        # branches to Empty_error label if new line found
        beq $s0, $0, empty_error        # If a character is next, it will move on to next label automatically


char_traversal:                         #  skips over the char until a space, new line or nothing is detected 
        lb $s0, 0($t4)			# load next byte
        addi $t4, $t4, 1		# move the ptr foward
        addi $t7, $t7, 1
        addi $t9, $t9, 1
        beq $s0, 10, reset    # If we find a new line or anything branch to return to start
        beq $s0, 0, reset     
        bne $s0, 32, char_traversal    # If it is NOT a space is found, then it  loops

char_space_traversal:                   # At this point, we are checking if we are going to find only space
        lb $s0, 0($t4)                  # or another set of characters.
        addi $t4, $t4, 1                # move the ptr foward
        addi $t7, $t7, 1                # move the ptr counter
        addi $t9, $t9, 1		# move invalidLength counter forward by 1
        beq $s0, 10, reset    		# If string is finished branch to return to start
        beq $s0, 0, reset		
        bne $s0, 32, error_precedence   # will check for invalid length or default to invalid base.
        j char_space_traversal          # loops until it branches to one of the above mentioned labels


reset:					# the following below goes to the very beginning of the input
       sub $t4, $t4, $t7                # restart pointer in character array
        la $t7, 0                       # restart counter


skip_leading_spaces:
        lb $s0, 0($t4)                      # Skipping the spaces at the begin of the input (if any)
        addi $t4, $t4, 1                    # to get to the first char in the string
        beq $s0, 32, skip_leading_spaces    # this line stops iteratinng the string when it detects a letter


addi $t4, $t4, -1                       # re-aligning the pointer 


length_checker:                         # iterate over the valid set of char and ensure it is not over the limit of 4
        lb $s0, ($t4)                   # and then it would give error message
        addi $t4, $t4, 1                # otherwise the input's length is valid
        addi $t7, $t7, 1
        beq $s0, 10, return_to_start_of_string          # Checking for the end of the sequence of letters
        beq $s0, 0, return_to_start_of_string			
        beq $s0, 32, return_to_start_of_string
        beq $t7, 5, invalidLength      		        # branches to invalidLength error message
        j length_checker

return_to_start_of_string:              # reset ptr, correct string len, load 1st byte & set highest pwr
        sub $t4, $t4, $t7		# resetting the pointer to the start of the valid set of char	
        sub $t7, $t7, $s3               # this line brings the counter for the length to its correct place
        lb $s0, 0($t4)                  # load first byte
        sub $s4, $t7, $s3               # decremented and set the highest power for this particular length of valid string


        move $s6, $t7                   # place length of input in an s register so it doesn't get changed after calling a subprogram

get_max_exponent:
        beq $s4, 0, conclusion          # Determing the highest power
        mult $s3, $s5                   # Multiplying to the highest power
        mflo $s3                        # until the counter = 0
        sub $s4, $s4, 1                 # decrement highest pwr
        j get_max_exponent		# loop/jump back to the label 


conclusion:				# Concluding with the conversion, additions & printing the decimal answer
        jal conversion			# jump & link to next label (also sets the return address in the background)
        move $a0, $v0                   # moves sum to a0
        li $v0, 1                       # prints contents of a0
        syscall				# OS is called to execute
        li $v0, 10                      # Successfully ends program
        syscall				# OS is called to execute

conversion:
        addi $sp, $sp, -8               # allocate memory
        sw $ra, 0($sp)                  # store the return address
        sw $s0, 4($sp)                  # store the new 
        beq $s1, $s6, rewinding_accumulation           # base case for recursion
        add $t4, $a0, $s1               # incremental loading of pointer, iterating across input
        addi $s1, $s1, 1                # increment counter
        lb $s0, 0($t4)

        blt $s0, 48, invalidBase       # checks if character is before 0 in ASCII chart
        blt $s0, 58, Number                     # checks if character is between 48 and 57 inclusive
        blt $s0, 65, invalidBase       # checks if character is between 58 and 64 inclusive
        blt $s0, 90, Upper_Case                 # checks if character is between 65 and 89 inclusive
        blt $s0, 97, invalidBase       # checks if character is between 76 and 96 inclusive
        blt $s0, 122, Lower_Case                # checks if character is between 97 and 121 inclusive
        blt $s0, 128, invalidBase      # checks if character is between 118 and 127 inclusive

       Upper_Case:
                        addi $s0, $s0, -55                      # subtraction is done like this to the ASCII to get the value of the char
                        j multiply     
       Lower_Case:
                        addi $s0, $s0, -87                      # same is done for lower case but not for numbers
                        j multiply
        Number:
                        addi $s0, $s0, -48
                        j multiply

        multiply:
                        mul $s0, $s0, $s3               # value of letter times corresponding base^y
                        div $s3, $s3, 35                # decreasingthe exponent of the register holding the highest power
                        jal conversion

        add $v0, $s0, $v0                       # adding up the rest of the calculation for the input

        lw $ra, 0($sp)                          # reload so we can return them
        lw, $s0, 4($sp)                 
        addi $sp, $sp, 8                        # freeing up $sp, deallocating memory
        jr $ra                                  # jump return

rewinding_accumulation:
        li $v0, 0       
        lw $ra, 0($sp)                          # reload so we can return them
        lw $s0, 4($sp)                          
        addi $sp, $sp, 8                        # freeing up $sp, deallocating memory
        jr $ra

# Error Branches



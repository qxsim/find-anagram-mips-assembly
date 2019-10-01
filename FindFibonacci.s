	.data 

INPUTPROMPT: .asciiz "Provide an integer for the Fibonacci computation: "  # List of all output prompts
newLine: .asciiz "\n"
PROMPT: .asciiz "The Fibonacci numbers are: "
COLON: .asciiz ": "
ERROR: .asciiz "ERROR: Must enter a positive integer." 

	.text
main:																	   # Main method just jumps to INPUT
	j INPUT

INPUT:																	   # Takes input from user, and validates input aswell as call the recursive fibbonacci method
	la $a0, INPUTPROMPT											
	li $v0,	4		 
    syscall
    
    li $v0, 5															   # Takes the input number from the user
    syscall
    
    move $s1, $v0 														   # Store input value in $s1
    
    bgez $s1, FIBCALLER     											   # Call FIBCALLER if input is a positive integer
    
    la $a0, ERROR           											   # Return error message if input is less than 0, and ask for input again
    li $v0, 4
    syscall
    
    la $a0, newLine  
	li $v0,	4		 
    syscall
    
    j INPUT

FIBCALLER:
	li $v0, 9 															   # Create the heap
	move $a0, $s1 														   # Calculate the size of the heap  ->   (N+1)*4
	addi $a0, $a0, 1													   # Add 1 to size of array for 0
	sll $a0, $a0, 2    													   # Multiply by 4
	syscall 															   # Heap created
	
	move $s0, $v0       												   # Holds the start address of heap.
	la $t1, ($s0) 														   # Pointer (current location in the heap)	
	li $t5, 0   														   # Counter (goes from 0 -> N)
	addi $t7, $s1, 1													   # Max value for FIB to be looped
	
	la $a0, PROMPT
	li $v0,	4		 
    syscall
    
	la $a0, newLine  
	li $v0,	4		 
    syscall
	
	j FIB																   # Calls FIB function
	
PRINTELEMENT:															   # Prints current value that is selected on the heap in the form (X: N)
	move $a0, $t5														   # Prints the position of current value.
	li $v0, 1
	syscall 
	
	la $a0, COLON														   # Prints COLON.
	li $v0,	4		 
    syscall

	lw $a0, 0($t1)														   # Prints current value selected on the heap.
	li $v0, 1
	syscall
	
	la $a0, newLine  													   # Prints new line.
	li $v0,	4		 
    syscall
	
	jr $ra
	
EXIT:
	li $v0, 10		 
	syscall

FIB:
	bge $t5, $t7, EXIT														# If Counter is equal to max value, exit the program.
	beqz $t5, ADDZERO														# If Counter = 0, then call ADDZERO which adds 0 onto the heap.
	li $t2, 1
	beq $t5, $t2, ADDONE													# If Counter = 1, then call ADDONE which adds 1 onto the heap.
														
	lw $t2, -4($t1)															# Takes the 2 preceding values and sums them.
	lw $t3, -8($t1)
	add $t4, $t2, $t3
	sw $t4, 0($t1)															# Stores the sum of the preceding 2 values and stores it on the heap.
	
	jal PRINTELEMENT														# Prints the current value
	
	addi $t1, $t1, 4 														# Increments heap pointer by 1 (4 bytes per entry)
	addi $t5, $t5, 1														# Increments Counter by 1
	
	j FIB																	# Loop until EXIT condition satisfied
	
ADDONE:																		# Stores 1 on the heap, and calls FIB once done
	sw $t2, 0($t1)															
	
	jal PRINTELEMENT
	
	addi $t1, $t1, 4 
	addi $t5, $t5, 1
	
	j FIB
	
ADDZERO:																    # Stores 0 on the heap, and calls FIB once done
	sw $zero, 0($t1)
	
	jal PRINTELEMENT
	
	addi $t1, $t1, 4 
	addi $t5, $t5, 1
	
	j FIB
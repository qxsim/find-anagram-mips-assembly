    .data
    .align 2

OUTPUT: .asciiz "ANAGRAM COUNT: "
newLine: .asciiz "\n"

S: .align 2
   .asciiz "abca"
K: .word 5 						# Should be set to length of word + 1
N: .word 6                      # Should be set to number of elemenrs in List, L

L: .asciiz "abac"
   .asciiz "iade"
   .asciiz "caba"
   .asciiz "baae"
   .asciiz "ccab"
   .asciiz "aacb"
    
    .text
main:    
    lw $a0, L					# $a0: list of words to be sorted and compared
    lw $s0, S					# $a1: anagram input to be compared to list
    lw $s1, K					# $s1: size of words in bits
    lw $s2, N					# $s2: size of string list
    li $t9, 4
    addi $t5, $zero, 0			# $t5: the number 0
    
    li $v0, 9               	# $v0, 9: allocate heap space
    mul $a0, $s2, $t9      		# Calculate the amount of heap space
    syscall
 
    move $s3, $v0    			# $s3: base address of a string array
    
LOOP:   						# Iterates through each element of list, L
	lw $s1, K					# We have to redeclare all of these because the values are altered after each loop
    lw $s2, N	
    la $s0, S
    la $a0, L
    bge	$t5, $s2, SORTINPUT		# Once the loop is done, it will proceed to the SORTINPUT section 

    mul $t3, $s1, $t5		  	# Calculates increment amount for each element
    add $t4, $t3, $a0		 	# Calculates the start address for each element 
    la $a0, ($t4)		     	# Gets the value pointed to and stores it for CALLER
 
   	jal CALLER				  	# Jumps to CALLER which sorts each word
   	
	addi $t5, $t5, 1		  	# Increments the current index
	
	b LOOP				      	# Jumps to start of LOOP
	
SORTINPUT:
    la $t4, S				  	# Loads the start address of the input, S, into $t4
    jal CALLER
    
    b SORTFINISHED				# Once everything is sorted, jump to SORTFINISHED
    
CALLER:
	addi $sp, $sp, -8		  	# Allocates 8 bits for the stack
	sw $ra, 0($sp)			  	# Stores return address in the stack
	sw $a0, 4($sp)			  	# Stores the start address for the given word in the stack
	
	lw $s1, K				
	subi $s1, $s1, 1		  	# K is subtracted by 1 to obtain the actual length of the given word
	
	la	$a0, ($t4)			
	add $a1, $a0, $s1		  	# Calculates end address for each given word

	jal MERGESORT
	
	jal ADDTOHEAP
	
	lw $ra, 0($sp)			  	# All elements loaded from stack to preserve state
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
ADDTOHEAP:					  	# Adds each sorted word to the heap
  	lb $t0, ($a0)       	  	# Reads the word one byte at a time
  	sb $t0, ($s3)       	  	# Stores in the heap, one byte at a time
  	addiu $a0, $a0, 1  	      	# Increment word pointer by 1
  	addiu $s3, $s3, 1		  	# Increment heap pointer by 1
  	bne $t0, $zero, ADDTOHEAP 	# Loops until full word is inserted into the heap
  		
MERGESORT:
    addi $sp, $sp, -16			# Allocates 16 bits for the stack
    sw $ra, 0($sp)				# Stores return address in the stack
	sw $a0, 4($sp)				# Stores the start address for the given word in the stack
	sw $a1, 8($sp)				# Stores the end address for the given word in the stack
	
	sub $t0, $a1, $a0			# $t0 contains the value of the differnce between the start and end address of the given word
	li $t7, 1					# Sets $t7 to 1
	
	ble $t0, $t7, MERGESORTDONE	# Calls MERGESORTEND if there is only a single character in the given word (Can't sort single character)
	
	srl $t0, $t0, 1				# Divide the character array by 2
	add $a1, $a0, $t0			# Calculates the address for the midpoint of the character array
	sw $a1, 12($sp)				# Stores the address for the midpoint on the stack
	
	jal MERGESORT				# Recursive call on first half of character array
	
	lw $a0, 12($sp)				# Loads the address for the midpoint of the character array
	lw $a1, 8($sp)				# Load the address for the end of the character array
	
	jal MERGESORT				# Recursive call on second half of character array
	
	lw $a0, 4($sp)				# All elements loaded from stack to preserve state
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	
	jal MERGE
	
MERGESORTDONE:
    lw	$ra, 0($sp)				# Load the address for the return address from the stack
    addi $sp, $sp, 16			# Resets the stack pointer
    jr $ra
    
MERGE:
    addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	
	move $s0, $a0
	move $s1, $a1

MERGELOOP:
    lbu $t0, 0($s0)				# Load the first half position pointer
	lbu	$t1, 0($s1)				# Load the second half position pointer
	
	bgt	$t1, $t0, DONTSHIFT		# If the lower value is already first, don't shift
	
	move $a0, $s1
	move $a1, $s0				
	jal	SHIFT
	
	addi $s1, $s1, 1			# Increment the index for second half

DONTSHIFT:
	addi $s0, $s0, 1			# Increment the index for second half
	
	lw $a2, 12($sp)				# Load the end address
	bge	$s0, $a2, MERGELOOPDONE	# Call MERGELOOPDONE when both halves are empty
	bge	$s1, $a2, MERGELOOPDONE
	b MERGELOOP
	
MERGELOOPDONE:
	
	lw $ra, 0($sp)				# Load the return address
	addi $sp, $sp, 16			# Adjust the stack pointer
	jr $ra

SHIFT:
	li $t0, 10
	ble	$a0, $a1, SHIFTDONE		# Call SHIFTDONE if we have reached the end location
	addi $t6, $a0, -1			# Find the previous address in the array and store in $t6
	lb $t7, 0($a0)				# Loads the current position
	lb $t8, 0($t6)				# Loads the previous position
	sb $t7, 0($t6)				# Swaps the current position to the previous position
	sb $t8, 0($a0)				# Swaps the previous positionto the current position
	move $a0, $t6
	b SHIFT	
	
SHIFTDONE:
	jr $ra
	
SORTFINISHED:					# When merge-sort is complete
	la $a0, L					# Load all necessary parameters for our comparisons
	lw $t0, K			
	lw $t2, N
	mul $t0, $t0, $t2			# Loads the size of the list in bits
	li $s1, 0
	add $s1, $t0, $a0			# Loads the end address of the whole list
	
COMPARELOOP:   					# Iterates through each element of list, L
    bge $a0, $s1, PRINT			
    move $s0, $a0
    la $a1, S
    li $a2, 0
    
    jal ANAGRAMCHECK
    
    beqz $a2, COUNTUPDATE
    
	b NOUPDATE
	
COUNTUPDATE:
	addi $s7, $s7, 1

NOUPDATE:
    move $a0, $s0
    lw $t0, K
    add $a0, $a0, $t0
    b COMPARELOOP

# Compares an element in L, with S, bit by bit
#a0: address of the word we are on in L
#a1: address of char in s
#a2: value returned determining whether anagram or not (0=ANAGRAM, 1=NOT ANAGRAM)
ANAGRAMCHECK:
	lb $t0, 0($a0)
	beqz $t0, ANAGRAM
	lb $t2, 0($a1)
	
	beq $t0, $t2, NEXTWORD
	b NOTANAGRAM
	
NEXTWORD:
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	b ANAGRAMCHECK
	
ANAGRAM:
	jr $ra
	
NOTANAGRAM:
	li $a2, 1 
	jr $ra

##	Used to test if list sorts correctly
# TEST:  
#   lw	$t1, N			
#   lw $s1, K
#   la $a0, L
#   bge $t0, $t1, EXIT		
#   mul $t2, $s1, $t0
#   add $t3, $t2, $a0
#
#   la $a0, 0($t3)		
#   li $v0, 4				
#   syscall
#
#   la $a0, newLine
#   li $v0, 4				
#	syscall
#
#	addi $t0, $t0, 1
#
#	b TEST
##

##	Used to test if input sorts correctly
# TESTINPUTSORT:
#	la $a0, S
#   li $v0, 4				
#   syscall
#    					
#   la $a0, newLine	
#	li $v0, 4
#	syscall
##	

PRINT:
	la $a0, OUTPUT
	li $v0, 4
	syscall
	
    move $a0, $s7
    li $v0, 1				
    syscall	
    					
    la $a0, newLine
	li $v0, 4				
	syscall
    
EXIT:   						# Exits the program
	li $v0, 10
	syscall
.data
fin: .asciiz "/home/basilmari/Desktop/mips_project/input.txt" # filename for input
fout: .asciiz "/home/basilmari/Desktop/mips_project/output.txt" # filename for output
buffer: .space 1024

.text
#open a file for writing
li	$v0, 13       # system call for open file
la	$a0, fin      # board file name
li	$a1, 0        # Open for reading
li	$a2, 0
syscall            # open a file (file descriptor returned in $v0)
move	$s6, $v0      # save the file descriptor

#read from file
li	$v0, 14       # system call for read from file
move	$a0, $s6      # file descriptor
la	$a1, buffer   # address of buffer to which to read
li	$a2, 1024     # hardcoded buffer length
syscall            # read from file

# Print string
#li	$v0, 4
#la 	$a0, buffer
#syscall

# Close the file
li	$v0, 16       # system call for close file
move	$a0, $s6      # file descriptor to close
syscall            # close file

# open output file
li	$v0, 13
la	$a0, fout
li	$a1, 1
li	$a2, 0
syscall
#move	$s6, $v0

la $s0, buffer	#address of buffer
move $t0, $s0	#incrementing address
li $t1, 0		#counter
li $t2, 0		#converted integer value



# loop for parsing the buffer
parseloop1:
	lbu $t3, ($t0)
	beq $t3, 32, end1
	beq $t3, 0, end1
	blt $t3, 48, end1
	bgt $t3, 57, end1
	andi $t3,$t3,0x0F # where $s3 contains the ascii digit
	mul $t2, $t2, 10
	add $t2, $t2, $t3
	addi $t0, $t0, 1
	j parseloop1
end1:
	addi $t0, $t0, 1

move $s1, $t2	#length of matrix (4)
mul $t4, $s1, $s1	#number of elements in matrix (16)
sll $a0, $t4, 2		#size of array in bytes
li  $v0, 9
syscall			#allocate memory space for array
move $s2,$v0	#save array address in $s2

move $t5, $s2	#initialize incrementing address
loop:
	li $t2, 0
	beq $t1, $t4, endloop

	parseloop:	# loop for parsing the buffer
		lbu $t3, ($t0)
		beq $t3, 32, end
		beq $t3, 0, end
		blt $t3, 48, end
		bgt $t3, 57, end
		andi $t3,$t3,0x0F # where $s3 contains the ascii digit
		mul $t2, $t2, 10
		add $t2, $t2, $t3
		addi $t0, $t0, 1
		j parseloop
	end:
		addi $t0, $t0, 1

	sw $t2, ($t5)		#store integer in array
	li $v0, 1
	move $a0, $t2
	syscall
	li $a0, 32
	li $v0, 11
	syscall
	addi $t5, $t5, 4	#increment the address
	addi $t1, $t1, 1	#increment loop counter
	j loop
endloop:

#move $t5, $s2	#initialize incrementing address
#loop1:
#	beq $t1, 0, endloop1
#	l.s $f12, ($t5)
#	addi $t5, $t5, 4	#increment the address
#	li $v0, 2
#	syscall
#	subi $t1, $t1, 1
#endloop1:


#print integer
#li $v0, 1
#move $a0, $t2
#syscall

# write to output file
li	$v0, 15
move	$a0, $s6
la	$a1, buffer
li	$a2, 40
syscall

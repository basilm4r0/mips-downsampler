#This project is the work of Basil Mari (student ID: 1191027), and Islam Jum'a (student ID: 1191375)

.data
fin: .asciiz "/home/basilmari/Desktop/mips_project/input.txt" # filename for input
fout: .asciiz "/home/basilmari/Desktop/mips_project/output.txt" # filename for output
buffer: .space 4096
chararray: .space 64
fp1: .float 1.5
fp2: .float 0.5
fp3: .float 2
fp4: .float 4
fp5: .float 100
prompt1: .asciiz "\nEnter \"1\" to downsample using mean or \"2\" to downsample using median:\n"
prompt2: .asciiz "Enter the level of downsampling you wish to perform:\n"
error1: .asciiz "\nError: Matrix not divisible by 4\n"
error2: .asciiz "\nError: Level cannot be obtained from matrix\n"

.text
#open a file for reading
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
li	$a2, 4096     # hardcoded buffer length
syscall            # read from file

# Print string
#li	$v0, 4
#la 	$a0, buffer
#syscall

# Close the file
li	$v0, 16       # system call for close file
move	$a0, $s6      # file descriptor to close
syscall            # close file

la	$s0, buffer	#address of buffer
move	$t0, $s0	#incrementing address
li	$t1, 0		#counter
li	$t2, 0		#converted integer value


# loop for parsing the buffer
parseloop1:
	lbu	$t3, ($t0)
	sb	$0, ($t0)
	blt	$t3, 48, end1
	bgt	$t3, 57, end1
	andi	$t3,$t3,0x0F # where $t3 contains the ascii digit
	mul	$t2, $t2, 10
	add	$t2, $t2, $t3
	addi	$t0, $t0, 1
	j parseloop1
end1:
addi $t0, $t0, 1


move $s1, $t2	#order of matrix (4)
move $t9, $s1	#variable matrix order (changes as matrix is downsampled)
mul $t4, $s1, $s1	#number of elements in matrix (16)
divu $t8, $s1, 2
mfhi $t8
bne $t8, 1, no_error
	la $a0, error1
	li $v0, 4
	syscall
	j end_program
no_error:
sll $a0, $t4, 2		#size of array in bytes
li  $v0, 9
syscall			#allocate memory space for array
move $s2,$v0	#save array address in $s2

move $t5, $s2	#initialize incrementing address
loop:
	li $t2, 0
	beq $t1, $t4, endloop

	parseloop:	# loop for parsing the buffer
		lbu	$t3, ($t0)
		sb $0, ($t0)
		beq $t3, 32, end
		beq $t3, 0, end
		blt $t3, 48, end
		bgt $t3, 57, end
		andi $t3,$t3,0x0F # where $t3 contains the ascii digit
		mul $t2, $t2, 10
		add $t2, $t2, $t3
		addi $t0, $t0, 1
		j parseloop
	end:
	addi $t0, $t0, 1

	mtc1 $t2, $f12
	cvt.s.w $f12, $f12
	s.s $f12, ($t5)		#store float in array
	addi $t5, $t5, 4	#increment the address
	addi $t1, $t1, 1	#increment loop counter
	j loop
endloop:

move $t5, $s2	#initialize incrementing address
loop1:
	beq $t1, 0, endloop1
	l.s $f12, ($t5)
	addi $t5, $t5, 4	#increment the address
	li $v0, 2
	syscall
	li $a0, 32
	li $v0, 11
	syscall
	subi $t1, $t1, 1
	j loop1
endloop1:

# Print prompt
li	$v0, 4
la 	$a0, prompt1
syscall
li $v0, 5
syscall
move $s3, $v0
# Print second prompt
li	$v0, 4
la 	$a0, prompt2
syscall
li $v0, 5
syscall
move $s4, $v0
addiu $t8, $s4, -1
srlv $t8, $s1, $t8
bne $t8, 0, no_error2
	la $a0, error2
	li $v0, 4
	syscall
	j end_program
no_error2:

li $t7, 1 #initialize process function counter to 0
jal process

li $t1, 0
mul $t3, $t9, $t9
move $t5, $s2	#initialize incrementing address
loop2:			#printing result matrix to terminal
	beq $t1, $t3, endloop2
	l.s $f12, ($t5)
	addi $t5, $t5, 4	#increment the address
	li $v0, 2
	syscall
	li $a0, 32
	li $v0, 11
	syscall
	add $t1, $t1, 1
	j loop2
endloop2:

# open output file
li	$v0, 13
la	$a0, fout
li	$a1, 1
li	$a2, 0
syscall
move	$s6, $v0

li $t1, 0
la $t0, chararray
l.s $f13, fp5
move $t2, $s2	#initialize incrementing address
flt_to_int:			#
	beq $t1, $t3, flt_to_int_end
	l.s $f12, ($t2)
	mul.s $f12, $f12, $f13
	cvt.w.s $f11, $f12
	mfc1 $a0, $f11

	move $a1, $t0
	jal int2str		#convert integer to string

	move $a2, $t6
	move $a1, $v0	#write string to output file
	move $a0, $s6
	li $v0, 15
	syscall

	addi $t2, $t2, 4	#increment the float array address
	add $t1, $t1, 1
	j flt_to_int
flt_to_int_end:

# write to output file
li	$v0, 15
move	$a0, $s6
la	$a1, buffer
li	$a2, 100
syscall

j end_program	#end of main code block. jump to end of program.


process:
	add $t7, $t7, 1
	bgt $t7, $s4, process_end

	iterate:
		li $t0, 0
		li $t1, 0
		li $t2, 0
		li $t3, 0
		li $t4, 0
		li $t5, 0
		li $t6, 0
		li $t8, 0

		iterate_column:
			beq $t0, $t9, iterate_column_end
			li $t1, 0
			iterate_row:
				beq $t1, $t9, iterate_row_end
				mul $t2, $t0, $t9	#multiply matrix order by row and store in $t2
				add $t3, $t2, $t1	#add linear row index to column index to find index of first element
				sll $t3, $t3, 2		#multiply index by 4 to iterate by words (4 bytes)
				add $t3, $t3, $s2	#add relative address of element to address of array to find element address
				l.s $f0, ($t3)		#load first element
				add $t4, $t3, 4		#set $t4 = address of the second element to access
				l.s $f1, ($t4)
				sll $t8, $t9, 2
				add $t5, $t3, $t8	#$t5 = address of third element to access
				l.s $f2, ($t5)
				add $t6, $t5, 4		#$t6 = address of fourth element to access
				l.s $f3, ($t6)

				downsample:
					bne $s3, 1, l1	#branch if method is not mean
					l.s $f4, fp1
					l.s $f5, fp2
					l.s $f6, fp4
					remu $s5, $t0, 2	#check if level is even or odd to determine window
					bne $s5, 1, l2		#branch if not on odd level
					mul.s $f0, $f0, $f5
					mul.s $f1, $f1, $f4
					mul.s $f2, $f2, $f4
					mul.s $f3, $f3, $f5
					add.s $f0, $f0, $f1
					add.s $f0, $f0, $f2
					add.s $f0, $f0, $f3
					div.s $f0, $f0, $f6
					j downsample_end
					l2:
					bne $s5, 0, l1		#branch if not on even level
					mul.s $f0, $f0, $f4
					mul.s $f1, $f1, $f5
					mul.s $f2, $f2, $f5
					mul.s $f3, $f3, $f4
					add.s $f0, $f0, $f1
					add.s $f0, $f0, $f2
					add.s $f0, $f0, $f3
					div.s $f0, $f0, $f6
					j downsample_end
					l1:
					bne $s3, 2, l3		#branch if method is not median
					l.s $f5, fp3
					c.le.s $f0, $f1
					bc1t l4
					mov.s $f4, $f0
					mov.s $f0, $f1
					mov.s $f1, $f4
					l4:
					c.le.s $f2, $f3
					bc1t l5
					mov.s $f4, $f2
					mov.s $f2, $f3
					mov.s $f3, $f4
					l5:					#sorting area
					c.le.s $f0, $f2
					bc1t l6
					mov.s $f4, $f0
					mov.s $f0, $f2
					mov.s $f2, $f4
					l6:
					c.le.s $f1, $f3
					bc1t l7
					mov.s $f4, $f1
					mov.s $f1, $f3
					mov.s $f3, $f4
					l7:
					add.s $f0, $f1, $f2
					div.s $f0, $f0, $f5
					j downsample_end
					l3:
				downsample_end:


				sw $0, ($t3)
				sw $0, ($t4)
				sw $0, ($t5)
				sw $0, ($t6)
				srl $t2, $t2, 2		#calculating address to store result in
				srl $t3, $t1, 1
				add $t2, $t2, $t3
				sll $t2, $t2, 2
				add $t2, $t2, $s2
				s.s $f0, ($t2)		#store result in array
				add $t1, $t1, 2
				j iterate_row
			iterate_row_end:
			add $t0, $t0, 2
			j iterate_column
		iterate_column_end:
		srl $t9, $t9, 1

	j process
process_end:
jr $ra

int2str:
	li	$t7, 10	# $t7 = divisor = 10
	li	$a3, 46
	li	$t6, 0
	li $t8, 32
	addiu	$v0, $a1, 31	# start at end of buffer
	sb	$zero, 0($v0)	# store a NULL character
	addiu $v0, $v0, -1
	add $t6, $t6, 1
	sb $t8, 0($v0)
L1:	bne 	$t6, 3, L2
	addiu	$v0, $v0, -1
	add	$t6, $t6, 1
	sb	$a3, 0($v0)
L2:	divu	$a0, $t7	# LO  = value/10, HI = value%10
	mflo	$a0	# $a0 = value/10
	mfhi	$t5	# $t5 = value%10
	addiu	$t5, $t5, 48	# convert digit into ASCII
	addiu	$v0, $v0, -1	# point to previous byte
	add	$t6, $t6, 1
	sb	$t5, 0($v0)	# store character in memory
	bnez	$a0, L1	# loop if value is not 0
	jr	$ra	# return to caller

end_program:

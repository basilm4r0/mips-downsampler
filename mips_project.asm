.data  
fin: .asciiz "/home/basilmari/Desktop/mips_project/matrix.txt" # filename for input
fout: .asciiz "/home/basilmari/Desktop/mips_project/output" # filename for output
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
li	$v0, 4
la 	$a0, buffer
syscall

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
move	$s6, $v0

# write to output file
li	$v0, 15
move	$a0, $s6
la	$a1, buffer
li	$a2, 40
syscall
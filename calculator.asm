# by Logan Jones
.data
getnum: .asciiz "\nPlease enter your Integer: "
getOperator: .asciiz "Please enter an operand (+,-,*,/): "
result: .asciiz "The result is: "
overflow: .asciiz "I'm sorry, that would overflow."
zero: .asciiz "You cannot divide by zero."
thanks: .asciiz "Thank you. "
remainder: .asciiz " r "
equals: .asciiz " = "
opInputError: .asciiz "There was an error with your entered operator"
addOp: .byte '+'
subOp: .byte '-'
multOp: .byte '*'
divOp: .byte '/'

.text

main:
lb $t4, addOp #storing the sign so we can compare
lb $t5, subOp #storing the sign so we can compare
lb $t6, multOp #storing the sign so we can compare
lb $t7, divOp #storing the sign so we can compare

li $v0, 4       #print string
la $a0, getnum #"Enter your first number: "
syscall

li $v0, 5       #read int
syscall
move $s1, $v0    #load num1 into s1

li $v0, 4       #print string
la $a0, getOperator #"What type of calculation?..."
syscall      

li $v0, 12       #read character
syscall
move $s3, $v0 #load operator into s3

li $v0, 4       #print string
la $a0, getnum #"Enter your second number: "
syscall

li $v0, 5       #read int
syscall
move $s2, $v0   #load num2 into s2

beq $s3, $t4, addition    #if operator is == +, jump to addition
beq $s3, $t5, subtract    #if operator is == -, jump to subtract
beq $s3, $t6, multiply    #if operator is == *, jump to multiply
beq $s3, $t7, division	#if operator is == /, jump to multiply

li $v0, 4 # preparing to print a string
la $a0, opInputError # handling the case we get a bad op
syscall
li $v0, 10 # preparing to exit 
syscall 

addition:
move $a0,$s1, # storing our inputed number
move $a1,$s2, # storing our inputed number
jal isAddOverflow #checking if we are overflowing
bne $v0,$0, overflowError # jumping to error message
add $s0, $s1, $s2  #add s1 and s2, store in s0
j print # jumping to print 
subtract:
move $a0,$s1 # storing our inputed number
move $a1,$s2 # storing our inputed number
jal isSubOverflow #checking if we are overflowing
bne $v0, $s0, overflowError # jumping to error message
sub $s0, $s1, $s2  #subtract s1 and s2, store in s0
j print # jumping to print 
multiply:
move $a0,$s1 # storing our inputed number
move $a1,$s2 # storing our inputed number
jal isMultiOverflow # checking for issues
bne $v0, $0, overflow #anything other than zero means over flow so print error
mult $s1, $s2 # multiplying 
mflo $s0 # stroing lo to print as answer
j print # jumping to print 
division:
move $a0,$s1 # storing our inputed number
move $a1,$s2 # storing our inputed number
jal isDivOverflow # checking for issues
beq $v0, 0, zeroError # 0 says we are dividing by zero so print string
beq $v0, 1, overflowError # 1 says we have overflow so print error
div $s1, $s2 # actually dividing cause no issues
mfhi $t0 # storing hi
mflo $t1 #storing lo
li $v0, 4 # preparing to print a string 
la    $a0,thanks	#that string is located at ThankYou
syscall		
li    $v0,1            #print an int
move     $a0,$s1            #the first number
syscall      
li    $v0,11            #print a character 
move     $a0,$s3            #the operator
syscall        
li    $v0,1            #print an int
move     $a0, $s2        #the second nubmer
syscall        
li    $v0, 4            #print a string
la     $a0,equals       # =
syscall       
li    $v0,1            #print an int
move    $a0,$t1            #that int is the quotient
syscall          
li    $v0,4            #print a string
la    $a0,remainder            # r 
syscall           
li    $v0,1            #print an int
move    $a0,$t0            #printing the remainder
syscall         
li    $v0,10            #Exit 
syscall

overflowError:
li $v0, 4  #preparing to print a string 
la $a0, overflow # there was an overflow so we print overflow
syscall

li $v0, 10  # exit because there was an error
syscall

zeroError:
li $v0, 4 #preparing to print a string 
la $a0, zero # you cannot divide by zero so we print error
syscall

li $v0, 10 # exit because there was an error
syscall

print:
li $v0, 4	#preparing to print a string 
la    $a0,thanks	#that string is located at ThankYou
syscall		

li    $v0,1       #print an int
move     $a0,$s1           #the first number
syscall      

li    $v0,11            #print a character 
move     $a0,$s3          #that character is the operator
syscall        

li    $v0,1            #print an int
move     $a0, $s2        #the second nubmer
syscall        

li    $v0, 4            #print a string
la     $a0,equals        # the equals sign
syscall       

li    $v0,1            #print an int
move    $a0,$s0           #the answer
syscall            
        
li    $v0,10            #Exiting 
syscall

isSubOverflow:	
not	$a1, $a1 # compare inverse
		 # dont branch back as the code is the same after the not for add and sub
isAddOverflow:	
xor	$t0, $a0, $a1	# compare signs
bgez	$t0, doCheck	# branch if same
move	$v0, $0	# return 0 (false)
jr	$ra	#return to last spot
isMultiOverflow:
mult $a0,$a1 # multiplying 
mfhi $t0 # storing the hi
mflo $v1 # storing the low
li $v0, -1 # loading to use
beq $t0, $v0, checkSign # checking if there is over flow
li $v0, 0 # loading  to use
beq $t0, $v0, checkSign # checking if there is overflow 
li $t7, 1 # loading  to use
move $v0,$t7 # setting it equal to 1 so i know there is overflow
jr $ra # jumping back
checkSign:
srl $s5,$t0,31	#shifting the sign bit right
srl $s6,$v1,31	#shifting the sign bit right
bne $s5,$s6, overflowError #if $t3 != $t4 $v0 = 1 else it is 0
jr $ra		#return to last spot	
isDivOverflow:
bne     $a1,$0,isException #if not zero check if negative
li	$t0, 0 # loading  to use
move	$v0, $t0	# return 0 
jr	$ra	# jumping back
isException:
bne $a0,-2147483648, noOverflow # checking if we are the biggest number possible
li $t7, -1  # loading  to use
seq $v0,$a1,$t7 # making sure second input is not -1 if it is i return one which says there is overflow
jr $ra # jumping back
noOverflow:
jr $ra # jumping back because no issues
doCheck:	
addu	$t0, $a0, $a1	# add operands
xor	$v0, $t0, $a0	# compare signs
srl	$v0, $v0, 31	# return sign bit
jr	$ra		# going back to last spot
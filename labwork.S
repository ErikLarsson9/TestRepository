  # labwork.S
  # Written 2015 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1 2015-2016.
  # The macros PUSH and POP are in the public domain.
  
.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm

  # You can add your own code here
  #
.data 
.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	
.text 
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li $v0, 30
	syscall
	add $s0, $0, $a0 
	li $a0, 2000
	jal	delay
	nop
	add $t0, $0, $s0
	li $v0, 11
	addi $a0, $0, 0x6d
	syscall 
	addi $a0, $0, 0x73 
	syscall 
	
	li $v0, 30
	syscall
	 
	sub $a0, $a0, $t0
	li $v0, 1
	syscall
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #





.global hexasc
 hexasc:
	add $t0, $0, $a0	
	addi $t1, $0, 0xF  	#byte som används till maskning 
	and $t0, $t0, $t1	#maskat alla bitar utom de 4 minsta
	addi $t1, $0, 10	#
	slt  $t1, $t0, $t1
	beq  $t1, $0, charIsLetter
	nop
	add $v0, $t0, 0x30
	jr $ra
	nop
	
charIsLetter:
	add $v0, $t0, 0x37
	jr $ra	 
	nop  
#delay: 
	#jr $ra
	#nop

.global time2string
time2string:
	PUSH $s0 #pusha alla register som måste sparas till stacken 
	PUSH $s1
	PUSH $s2
	PUSH $s3
	PUSH $s4
	PUSH $s5
	PUSH $s6
	PUSH $s7
	PUSH $gp
	PUSH $fp
	PUSH $ra
	
	add $s0, $0, $a0 
	add $a0, $0, $a1 #Tiden som är NBCD kodad sparas i $a0 som är parameter till hexasc 
	jal hexasc
	nop
	sb $v0, 4($s0) #Entalsdelen av tiden i sekunder sparas som en char och lagras i timestr  
	
	add $a0, $0, $a1
	srl $a0, $a0, 4 #Tiotalsdelen av tiden i sekunder hamnar på de fyra första bitarna
	jal hexasc
	nop
	
	sb $v0, 3($s0) #Tiotalsdelen av tiden i sekunder sparas som en char och lagras i timestr   
	addi $t0, $0, 0x3A #Tecknet ":"
	sb $t0, 2($s0) #Tecknet ":" lagras i timestr
	
	add $a0, $0, $a1
	srl $a0, $a0, 8 #Entalsdelen av tiden i minuter hamnar på de fyra första bitarna
	jal hexasc
	nop
	
	sb $v0, 1($s0) #Entalsdelen av tiden i minuter lagras som en char i timestr
	
	add $a0, $0, $a1 
	srl $a0, $a0, 12 #Tiotalsdelen av tiden i minuter hamnar på de fyra första bitarna
	jal hexasc
	nop
	
	sb $v0, 0($s0)  #Tiotalsdelen av tiden i minuter lagras som en char i timestr

	add $t4, $0, $a1
	and $t4, $t4, 0xFF
	
	bne $t4, $0, NotZeroZero
	nop
	addi $t0, $0, 0x58 #X
	sb $t0, 5($s0)
	addi $t0, $0, 0 #NULL
	sb $t0, 6($s0)
	j ZeroZero 
	nop 
	
NotZeroZero:	
	addi $t0, $0, 0 #Nullbyten 
	sb $t0, 5($s0)  #Nullbyten lagras i timestr
ZeroZero:
	POP $ra #Ta bort registrerna från stacken (POP)
	POP $fp
	POP $gp
	POP $s7
	POP $s6
	POP $s5
	POP $s4
	POP $s3
	POP $s2
	POP $s1
	POP $s0
	jr $ra
	nop
.global delay
delay:
	PUSH $s0
	add $s0, $0, $a0  
	add $t0, $0, $s0 #Delaytiden  s0 läggs till t0 
delayloop1:
	slt $t1, $0, $t0 # Är den kvarvarande delaytiden större än 0 ms
	bne $t1, $0, delayloop2 #ifall den kvarvarande tiden är mindre än eller lika med 0 ms gå main programmet
	nop
	POP $s0
	jr $ra	#Hoppa till main 
	nop
delayloop2: 
	addi $t0, $t0, -1 #Minska tiden i ms med 1
	add $t2, $0, $0	  #Sätt i = 0
delayloop3:
	slti $t1, $t2, 11420 #for loop för i<4771
	beq $t1, $0, delayloop1 #ifall i => 4771 gå tillbaks till while loopen 
	nop
	addi $t2, $t2, 1 #Öka i med 1 
	j delayloop3 #gå till början av for loopen 
	nop	 
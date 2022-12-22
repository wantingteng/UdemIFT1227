#Wanting Teng 20179470 wanting.teng@umontreal.ca TENW87540202
#Yuxiang Lin  20172116 yuxaing.lin@umontreal.ca LINY87030003
#2022/11/19

#Le but de ce programme est de convertir les chiffres arabes de 0 à 3999 en chiffres romains

#segment de la mémoire contenant les données globales
.data
#tampon résérvé pour une chaîne encodée
buffer: .space 30       #for chiffre(num,1)
buf1: .space 10	        #for chiffre(num,10)
buf2: .space 10		#for chiffre(num,100)
buf3: .space 10		#for chiffre(num,1000)
I: .ascii "I"
V: .ascii "V"
X: .ascii "X"
L: .ascii "L"
C: .ascii "C"
D: .ascii "D"
M: .ascii "M"
msg: .asciiz "Entrer un nombre de 1 à 3999: "
msg2: .asciiz "Le nombre entré est invalide"

.text
main:	li	$v0,4
	la	$a0,msg 
	syscall             #show message
	
	li	$v0,5
	syscall             #read l'entree
	move $a0,$v0 	    #a0==v0==l'entree	
	jal	romain
	j	done   #0xqw    
	
done:	
	li	$v0,4	
	la	$a0,buf3
	syscall
	li	$v0,4	
	la	$a0,buf2
	syscall
	li	$v0,4	
	la	$a0,buf1
	syscall
	li	$v0,4	
	la	$a0,buffer
	syscall
	
	li	$v0,10
	syscall			#exit

#$a0=nombre de repetitions $a1=adresse du symbole d'encodage
#$a2=l'adresse ou la chaine resultat devra etre placee		
romain:		subi	$sp,$sp,8
		
		sw	$ra,0($sp) 	
		sw	$a0,4($sp)	
		
		beq	$a0,0 invalide  #num==0 invalide
		jal	chiffre
		 
		lw	$a0,4($sp)      #address==0xyu	
		lw	$ra,0($sp)	#$ra== 0xqw
		addi	$sp,$sp,8
		jr	$ra 	#goto 0xqw

			
chiffre:	subi	$sp,$sp,20
		sw	$a0,16($sp)	
		sw	$ra,0($sp)      #ra==0xyu
		ble	$a0,9, rang1
		ble	$a0,99,rang10
		ble	$a0,999,rang100
		ble	$a0,3999,rang1000
		
												
rang1:		
		addi	$t9,$t9,10
		div	$a0,$t9		#num%10
		mfhi	$a0		#a0==num=num%10
		bnez	$a0,processRang1  #$a0!=0 
		j	finish
		
rang10:		li	$a1,10
		lb	$a2,X
		la	$a3,buf1
		move	$t9,$a0  #save original num into $t9
again10:	div	$a0,$a1
		mflo	$a0	#num=num//rang
		blt	$a0,10,processRang10 #if num<10
		#else
		div	$a0,$a1
		mfhi	$a0	#num=num%10
		mul	$a0,$a0,$a1 #num=num*10
		beqz	$a0,clear10 #300,403,209...
		j	again10 # return chiffre(num,10)

rang100:	li	$a1,100
		lb	$a2,C
		la	$a3,buf2
		move	$t9,$a0  #save original num into $t9
again100:	div	$a0,$a1
		mflo	$a0	#num=num//rang
		blt	$a0,10,processRang100
		#else
		li	$t4,10
		div	$a0,$t4
		mfhi	$a0	#num=num%10
		mul	$a0,$a0,$a1 #num=num*100
		beqz	$a0,clear100
		j	again100 # return chiffre(num,10)
		
rang1000:	li	$a1,1000
		lb	$a2,M
		la	$a3,buf3
		move	$t9,$a0
		div	$a0,$a1
		mflo	$a0
		j	processRang1000												
														
less3:		j	repeter													
repeter:	li	$t0,0
		beq	$a1,1,forRang1
		beq	$a1,10,forRang10
		beq	$a1,100,forRang100
		beq	$a1,1000,forRang1000

#-----------------------rang1000-----------------------------------		
processRang1000:	ble	$a0,3,less3

forRang1000:		ble	$a0,3,loop_less3_1000	

loop_less3_1000:  	addi	$t1,$t0,0  
			add	$t1,$a3,$t1 
			sb	$a2,($t1)   
			subi	$a0,$a0,1   
			addi	$t0,$t0,1   
			bnez	$a0,loop_less3_1000
			j	clear1000	
				
clear1000:	li	$t8,0
		li	$t7,0
		li	$t6,0	
		move	$a0,$t9
		li	$t9,0
		j	rang100								
#-------------------------rang100----------------------------------------		
forRang100:	ble	$a0,3,loop_less3_100 #if num<=3 loop
		subi	$a0,$a0,5
		j	loop_6a8_100	#if num[6,8] loop
		
loop_6a8_100:
		addi	$t3,$t3,1
		sb	$a2,($t3)
		subi	$a0,$a0,1
		bnez	$a0,loop_6a8_100
		j	clear100						
		
processRang100:	ble	$a0,3,less3#if 1=<num<=3
		li	$t8,4
		li	$t7,9
		li	$t6,5	
		beq	$a0,$t8,numFourhundred
		beq	$a0,$t6 numFivehundred
		beq	$a0,$t7,numNinehundred
		
		bgt	$a0,5,biggerThan5_100 #if num>5 from 6 to...
		
loop_less3_100:  addi	$t1,$t0,0  #$t1=0,1,2,3... index
		add	$t1,$a3,$t1 #t1<-array[0] + i*sizeof(int)
		sb	$a2,($t1)   #save char into array[0],[1]...
		subi	$a0,$a0,1   #num=num-1
		addi	$t0,$t0,1   #$t0=0,1,2...
		bnez	$a0,loop_less3_100
		j	clear100		
										
Hundreds:	li	$t0,0
		add	$t0,$a3,$t0
		sb	$a2,($t0)
		sb	$t7,1($t0)
		lb	$t0,buf2
		j	clear100

biggerThan5_100:	ble	$a0,8,num6a8_100 #if num>5 and num<=8

num6a8_100:		
		addi	$t3,$a3,0
		lb	$t1,D
		sb	$t1,($t3)	
		j	repeter	
																								
numFourhundred:	lb	$t7,D
		j	Hundreds
			
numFivehundred:
		li	$t0,0
		add	$t0,$a3,$t0
		lb	$t7,D
		sb	$t7,($t0)
		j	clear100
						
numNinehundred:	
		lb	$t7,M
		j	Hundreds	
		
clear100:	li	$t8,0
		li	$t7,0
		li	$t6,0	
		move	$a0,$t9
		li	$t9,0
		j	rang10	
																					
#--------------------------------rang==10-----------------------------				
				
forRang10:	ble	$a0,3,loop_less3_10 #if num<=3 loop
		subi	$a0,$a0,5
		j	loop_6a8_10	#if num[6,8] loop
		
loop_less3_10:  addi	$t1,$t0,0  #$t1=0,1,2,3... index
		add	$t1,$a3,$t1 #t1<-array[0] + i*sizeof(int)
		sb	$a2,($t1)   #save char into array[0],[1]...
		subi	$a0,$a0,1   #num=num-1
		addi	$t0,$t0,1   #$t0=0,1,2...
		bnez	$a0,loop_less3_10
		j	clear10
			
loop_6a8_10:
		addi	$t3,$t3,1
		sb	$a2,($t3)
		subi	$a0,$a0,1
		bnez	$a0,loop_6a8_10
		j	clear10

processRang10:	
		ble	$a0,3,less3#if 1=<num<=3
		li	$t8,4
		li	$t7,9
		li	$t6,5	
		beq	$a0,$t8,numForty
		beq	$a0,$t6 numFifty
		beq	$a0,$t7,numNinety
		
		bgt	$a0,5,biggerThan5_10 #if num>5 from 6 to...
		#j	finish
		
		
biggerThan5_10:	ble	$a0,8,num6a8_10 #if num>5 and num<=8

num6a8_10:		
		addi	$t3,$a3,0
		lb	$t1,L
		sb	$t1,($t3)	
		j	repeter					
Tens:		li	$t0,0
		add	$t0,$a3,$t0
		sb	$a2,($t0)
		sb	$t7,1($t0)
		lb	$t0,buf1
		j	clear10
		
clear10:	li	$t8,0
		li	$t7,0
		li	$t6,0	
		move	$a0,$t9
		li	$t9,0
		j	rang1
	
numForty:	lb	$t7,L
		j	Tens			
numFifty:
		li	$t0,0
		add	$t0,$a3,$t0
		lb	$t7,L
		sb	$t7,($t0)
		j	clear10
						
numNinety:	
		lb	$t7,C
		j	Tens
#------------------------rang==1--------------------------------
forRang1:		ble	$a0,3,loop_less3_1 #if num<=3 loop
			subi	$a0,$a0,5
			j	loop_6a8_1	#if num[6,8] loop
										
processRang1:	li	$a1,1   	 #rang==1
		lb	$a2,I	         #repeat"I"
		la	$a3,buffer       #"" empty now

		ble	$a0,3,less3#if 1=<num<=3
		li	$t8,4
		li	$t7,9
		li	$t6,5
		beq	$a0,$t8,numFour #if num==4 
		beq	$a0,$t7,numNine #if num==9
		beq	$a0,$t6,numFive #if num==5
		bgt	$a0,5,biggerThan5_1 #if num>5 from 6 to...
		j	finish
		
finish:		lw	$ra,0($sp)
		addi	$sp,$sp,20	#clear stack
		jr	$ra      #jump to 0xyu
		
biggerThan5_1:	ble	$a0,8,num6a8_1 #if num>5 and num<=8

num6a8_1:		
		addi	$t3,$a3,0
		lb	$t1,V
		sb	$t1,($t3)
		
		j	repeter	
				
loop_6a8_1:
		addi	$t3,$t3,1
		sb	$a2,($t3)
		subi	$a0,$a0,1
		bnez	$a0,loop_6a8_1
		lw	$ra,0($sp)
		addi	$sp,$sp,20	#clear stack
		jr	$ra      #jump to 0xyu
											
loop_less3_1:	 	
		addi	$t1,$t0,0  #$t1=0,1,2,3... index
		add	$t1,$a3,$t1 #t1<-array[0] + i*sizeof(int)
		sb	$a2,($t1)   #save char into array[0],[1]...
		subi	$a0,$a0,1   #num=num-1
		addi	$t0,$t0,1   #$t0=0,1,2...
		bnez	$a0,loop_less3_1
		
		lw	$ra,0($sp)
		addi	$sp,$sp,20	#clear stack
		jr	$ra      #jump to 0xyu

Ones:		li	$t0,0
		add	$t0,$a3,$t0
		sb	$a2,($t0)
		sb	$t7,1($t0)
		lw	$ra,0($sp)
		addi	$sp,$sp,20	#clear stack
		jr	$ra      #jump to 0xyu		
		
numFour:	
		lb	$t7,V
		j	Ones
		
numFive:	li	$t0,0
		add	$t0,$a3,$t0
		lb	$t7,V
		sb	$t7,($t0)
		lw	$ra,0($sp)
		addi	$sp,$sp,20	#clear stack
		jr	$ra      							
numNine:	
		lb	$t7,X
		j	Ones																																																																																																																																																																																																																															
#------------------------------invalide-----------------------------																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																														
invalide:	li	$v0,4
		la	$a0,msg2
		syscall             #show invalid message
		li	$v0,10
		syscall			#exit
	
	
	
	
	

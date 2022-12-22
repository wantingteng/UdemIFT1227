#Programme utilisant le jeu d'instruction MIPS pour faire la convertion de chiffres arabes vers chiffre romain
#Par François-Xavier Malenfant, matricule #20190905
#28 Novembre 2022
#Travail effectué dans le cadre du cours IFT 1227

#segment de la mémoire contenant les données globales
.data
#tampon résérvé pour une chaîne encodée
	buffer: .space 	30	#36 is the max lenght the result can take
	I: 	.ascii 	"I"	#1
	V: 	.ascii 	"V"	#5
	X: 	.ascii 	"X"	#10
	L: 	.ascii 	"L"	#50
	C: 	.ascii 	"C"	#100
	D: 	.ascii 	"D"	#500
	M: 	.ascii 	"M"	#1000
	prompt: .asciiz "Veuillez entrer un nombre de 1 à 3999: "
	error: 	.asciiz "\nNombre Invalide\n"
#segment de la mémoire contenant le code
.text
main:
	li $v0,4 	#Code pour syscall print string
	la $a0,prompt  	#prompt est le message qui sera print
	syscall		#Faire le syscall

	li $v0,5 	#Code pour syscall get integer
	syscall
	add $s0,$v0,$0	#transfère la valeur reçue dans $s0
	
	li $t1,1
	sgt $t0,$s0,$t1	#Si le input est plus petit que 1 (invalide), $t0 = 0
	beqz $t0,err	#Branche a err si valeur entrée plus petit que 1
	
	li $t1,4000
	slt $t0,$s0,$t1	#Si le input est plus grand que 3999(invalide), $t0 = 0
	beqz $t0,err	#Branche a err si valeur entrée plus grand que 3999
	
	#Si le programme respecte les exceptions, branche à romain. Exceptionellement on ne passe pas le paramètre avec
	#$a0 car le nombre recu est déja dans $s0 et y restera pour toute l'exécution du programme.
	jal romain
		
	#retour de romain; il reste a print le resultat
	la $s2,buffer		#$s2 est ou on est rendu dans le buffer alors qu'on le print
	jal print
	
	li $v0,10 	#terminer le programme
	syscall
	
print:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	
	li $v0,4	#On prépare un syscall print
	la $a0,buffer	#Charger le buffer pour le print
	syscall		#print buffer
	
	lw $ra, 0($sp)	#return to main
	addi $sp,$sp,4
	jr $ra

err:			#Indique que le input est invalide, puis redemande un input
	li $v0,4 	#Code pour syscall print string
	la $a0,error  	#error est le message qui sera print
	syscall		#Faire le syscall
	b main
 
#Fonction repeter: prend un nonmbre de répétitions, une adresse du charactere a repeter, et l'adresse ou l'écrire.
#retourne l'adresse suivant ce qui a été écrit
repeter:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	addi $t1,$a0,0		#$t1 représente le nombre de répétitions à faire
repeterLoop:
	beqz $t1,exitRepeter	#Si il n'y a pas/plus de répétitions à faire, retourner
	
	lb $t0,($a2)		#charge le symbole à écrire dans $t0
	sb $t0,($a3)		#Store le symbole dans le buffer au bon endroit
	
	subi $t1,$t1,1		#On soustrait 1 au nombre de répétitions à faire, on change l'endroit ou on écrit et on recommance.
	addi $a3,$a3,1
	b repeterLoop
exitRepeter:
	addi $v0,$a3,0		#L'adresse de retour contient l'adresse après ce qui à été écrit
	
	lw $ra, 0($sp)		#return to chiffre
	addi $sp,$sp,4
	jr $ra
	
#fonction chiffre
chiffre:
	#Le cas ou $a0 = 0 est handled dans romain
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	slti $t0,$a0,4
	beqz $t0,sup3	#si $a0 n'est pas plus petit que 4, passer au prochain cas
	
	#parametres de repeter: $a0 est déja a la bonne valeur (1-3)
	#$a2 contient l'adresse du symbole
	#$a3 contient l'adresse ou le résultat doit être placé
	
	jal repeter
	addi $s1,$v0,0 	#mettre le return value dans $s1, qui est l'adresse ou il faut écrire
	
	lw $ra, 0($sp)	#return to romain
	addi $sp,$sp,4
	jr $ra
	
sup3:
	bne $a0,4,sup4	#si $a0 n'est pas 4, passer au prochain cas
	
	lb $t0,($a2)	#charge le symbole à écrire dans $t0 (Premier charactère)
	sb $t0,($a3)	#Store le symbole dans le buffer au bon endroit
	addi $a3,$a3,1	#incrémente endroit ou écrire
	
	lb $t0,1($a2)	#charge le symbole à écrire dans $t0 (Deuxièmre charactère)
	sb $t0,($a3)	#Store le symbole dans le buffer au bon endroit
	addi $a3,$a3,1	#incrémente endroit ou écrire
	
	addi $s1,$a3,0 	#sauvegarde l'endroit ou on est rendu dans le buffer dans $s1
	
	lw $ra, 0($sp)	#return to romain
	addi $sp,$sp,4
	jr $ra
sup4:
	slti $t0,$a0,9
	beqz $t0,sup8	#si $a0 n'est pas plus petit que 9, passer au prochain cas
	
	lb $t0,1($a2)	#charge le symbole à écrire dans $t0 (Deuxièmre charactère - 5)
	sb $t0,($a3)	#Store le symbole dans le buffer au bon endroit
	addi $a3,$a3,1	#incrémente endroit ou écrire
	
	subi $a0,$a0,5	#soustraire 5 du chiffre, pour utiliser repeter sur le reste
	
	jal repeter
	
	addi $s1,$a3,0 	#sauvegarde l'endroit ou on est rendu dans le buffer dans $s1
	
	lw $ra, 0($sp)	#return to romain
	addi $sp,$sp,4
	jr $ra
	
sup8:
	lb $t0,($a2)	#charge le symbole à écrire dans $t0 (premier charactère - 1)
	sb $t0,($a3)	#Store le symbole dans le buffer au bon endroit
	addi $a3,$a3,1	#incrémente endroit ou écrire
	
	lb $t0,2($a2)	#charge le symbole à écrire dans $t0 (troisième charactère - 10)
	sb $t0,($a3)	#Store le symbole dans le buffer au bon endroit
	addi $a3,$a3,1	#incrémente endroit ou écrire
	
	addi $s1,$a3,0 	#sauvegarde l'endroit ou on est rendu dans le buffer dans $s1

	lw $ra, 0($sp)	#return to romain
	addi $sp,$sp,4
	jr $ra
	
#fonction romain. $a0 = int à convertir.
romain:
	addi $sp, $sp, -4 	#make space in stack for 1 word
	sw $ra,0($sp)		#Store $ra in stack
	
	la $s1,buffer		#On charge l'adresse de notre buffer dans $s1

	div $t0,$s0,1000	#division entière du nombre recu par 1000, afin de recevoir le premier digit si il existe
	beqz $t0, skip1		#si il n'y a pas de nombre à la position des 1000, pas besoin d'exécuter chiffre dessus
	
	add $a0,$t0,$0		#sinom, set $a0 à la valeur du premier chiffre comme argument pour chiffre:.
	addi $a1,$0,4		#$a1 est le deuxième paramètre de chiffre, le rang
	la $a2,M		#$a2 est l'adresse ou se trouve M
	
	la $a3,($s1)		#$s1 est l'endroit ou on est rendu dans buffer. Incrémenté à chaque fois qu'on écrit dedans
	
	jal chiffre		#on appelle chiffre sur le chiffre trouvé
	
skip1:
	div $t0,$s0,100		#division entière du nombre recu par 100, puis division par 10 et on prend le remainder
	li $t1,10		#Cela nous donne le dernier digit du nombre
	div $t0,$t1
	
	mfhi $t0 		#set $t0 to digit at position 3
	beqz $t0, skip2		#si il n'y a pas de nombre à la position des 100, pas besoin d'exécuter chiffre dessus
	
	add $a0,$t0,$0		#sinom, set $a0 à la valeur du premier chiffre comme argument pour chiffre:.
	addi $a1,$0,4		#$a1 est le deuxième paramètre de chiffre, le rang
	la $a2,C		#$a2 est l'adresse ou se trouve M
	la $a3,($s1)		#$s1 est l'endroit ou on est rendu dans buffer. Incrémenté à chaque fois qu'on écrit dedans
	
	jal chiffre		#on appelle chiffre sur le chiffre trouvé
	
skip2:
	div $t0,$s0,10		#division entière du nombre recu par 10, puis division par 10 et on prend le remainder
	li $t1,10		#Cela nous donne le dernier digit du nombre
	div $t0,$t1
	
	mfhi $t0 		#set $t0 to digit at position 3
	beqz $t0, skip3		#si il n'y a pas de nombre à la position des 100, pas besoin d'exécuter chiffre dessus
	
	add $a0,$t0,$0		#sinom, set $a0 à la valeur du premier chiffre comme argument pour chiffre:.
	addi $a1,$0,4		#$a1 est le deuxième paramètre de chiffre, le rang
	la $a2,X		#$a2 est l'adresse ou se trouve M
	la $a3,($s1)		#$s1 est l'endroit ou on est rendu dans buffer. Incrémenté à chaque fois qu'on écrit dedans
	
	jal chiffre		#on appelle chiffre sur le chiffre trouvé
	
skip3:
	li $t1,10		#pas bedoin de couper la fin du nombre, seulement de prendre le dernier chiffre
	div $s0,$t1		#donc on prend le reste de la divistion par 10
	mfhi $t0 		
	
	beqz $t0,skip4		#si il n'y a pas de nombre à la position des 1, pas besoin d'exécuter chiffre dessus
	
	add $a0,$t0,$0		#sinon, set $a0 à la valeur du dernier chiffre comme argument pour chiffre:.
	addi $a1,$0,4		#$a1 est le deuxième paramètre de chiffre, le rang
	la $a2,I		#$a2 est l'adresse ou se trouve M
	la $a3,($s1)		#$s1 est l'endroit ou on est rendu dans buffer. Incrémenté à chaque fois qu'on écrit dedans
	
	jal chiffre		#on appelle chiffre sur le chiffre trouvé

skip4:

	lw $ra, 0($sp)		#return to main
	addi $sp,$sp,4
	jr $ra
	
	
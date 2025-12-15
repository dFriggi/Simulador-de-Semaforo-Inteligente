.data
    QUEBRA:              .asciiz "\n"
    SIMBOLO_DIVISAO:     .asciiz "/"
    SIMBOLO_IGUAL:       .asciiz " = "
    VIRGULA:             .asciiz ", "
        
    TXT_MENU:            .asciiz "Selecione o processo desejado:\n 1 - Seguir com o processo\n 2 - Mostrar histórico últimos 5 semáforos\n 3 - Mostrar média móvel atual\n 4 - Encerrar\n\n"
    TXT_ADICIONA_CARRO:  .asciiz "Adicione a quantidade de carros lida pelo sensor (simulação): "
    
    TXT_VALOR_VETOR_MEDIA:    .asciiz "Quantidade de carros no vetor: "
    TXT_SOMA_VETOR_MEDIA:     .asciiz "Soma atual: "
    
    TXT_VETOR_CARROS:         .asciiz "Vetor com o histórico dos últimos 5 valores lidos pelo sensor: "

    COR_VERMELHO:          .word 0x00FF0000
    COR_VERMELHO_APAGADO:  .word 0x8B0000
    COR_AMARELO:           .word 0x00FFFF00
    COR_AMARELO_APAGADO:   .word 0xba8e23
    COR_VERDE:             .word 0x0000FF00
    COR_VERDE_APAGADO:     .word 0x556B2F
    COR_BRANCO:            .word 0xFFFFFFFF
    COR_PRETO:             .word 0xFF000000
   
    DISPLAY_ADRESS: .word 0x10008000
   
    VETOR_HISTORICO:       .word 5, 12, 8, 15, 10
    INDICE_VETOR:           .word 0
    
    ESTADO_ATUAL_SEMAFORO: .word 0

    MEDIA_MOVEL:  .word 5

.globl main
.text

main:
    li $t0, 0
    
loop:
    jal resetar_contador
    #setando o semaforo sempre como vermelho no início das iterações
    li $a1, 0
    jal seleciona_cor
    
    li $t2, 2
    li $t3, 3
    li $t4, 4

    li $v0, 4
    la $a0, TXT_MENU
    syscall
    
    li $v0, 5
    syscall
    move $a0, $v0
    
    beq $a0, $t2, mostrar_historico
    beq $a0, $t3, media_atual
    beq $a0, $t4, end 
    
segue_processo:
    li $v0, 4
    la $a0, TXT_ADICIONA_CARRO
    syscall

    li $v0, 5
    syscall
    
    move $a0, $v0 #movendo o retorno da função anterior para usar o $a como parâmetro   
    jal adicionar_carro_historico
    
    move $a0, $v0 #movendo o retorno da função anterior para usar o $a como parâmetro
    jal media_movel

    li $a1, 2
    jal seleciona_cor
    
    move $a0, $v0 #movendo o retorno da função anterior para usar o $a como parâmetro
    jal contador
    
    li $a1, 1
    jal seleciona_cor
    li $a0, 5
    jal contador
    
    j loop

media_atual:
    jal media_movel
    
    j loop

mostrar_historico:
    li $v0, 4
    la $a0, TXT_VETOR_CARROS
    syscall
    
    la $t0, VETOR_HISTORICO
    li $t1, 0

    add $t1, $t1, $t0
    lw $t2, 0($t1) #$t2= vetor_historico[$t1]
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, VIRGULA
    syscall
    
    addi $t1, $t1, 4
    lw $t2, 0($t1)
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, VIRGULA
    syscall
    
    addi $t1, $t1, 4
    lw $t2, 0($t1)
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, VIRGULA
    syscall
    
    addi $t1, $t1, 4
    lw $t2, 0($t1)
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, VIRGULA
    syscall

    addi $t1, $t1, 4
    lw $t2, 0($t1)
    
    li $v0, 1
    move $a0, $t2
    syscall
    
    li $v0, 4
    la $a0, QUEBRA
    syscall

    j loop

adicionar_carro_historico:
    #não é necessário salvar $ra em $sp pois não há uma outra chamada de função que substitua o valor de $ra que aponta para a próxima função media_movel
    la $t0, VETOR_HISTORICO
    lw $t1, INDICE_VETOR   
    
    sll $t2, $t1, 2
    add $t3, $t2, $t0#calcula o endereço a adicionar o valor: base + (índice × 4)
    
    sw $a0, 0($t3) #armazena o valor
    
    addi $t1, $t1, 1
    li $t4, 5
    div $t1, $t4
    mfhi $t1
    sw $t1, INDICE_VETOR
    
    jr $ra
   
media_movel:
    addi $sp, $sp, -12 #aloca espaço em $sp para salvar o $s0, $s1 e $ra
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s1, VETOR_HISTORICO     
    li $s0, 0                  
    li $t0, 0                  
    
loop_soma_media:
    bge $t0, 5, fim_media
    
    sll $t1, $t0, 2             
    add $t2, $s1, $t1 #calculo do endereço
    
    lw $t3, 0($t2) #$t3 = vetor_historico[$t2]
    
    li $v0, 4
    la $a0, TXT_VALOR_VETOR_MEDIA
    syscall
    
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, QUEBRA
    syscall
    
    add $s0, $s0, $t3

    li $v0, 4
    la $a0, TXT_SOMA_VETOR_MEDIA
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, QUEBRA
    syscall
    
    addi $t0, $t0, 1
    j loop_soma_media
    
fim_media:
    li $t5, 5
    div $s0, $t5 #divide a soma dos valores do vetor histórico por 5.
    mflo $t6
          
    li $v0, 1
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, SIMBOLO_DIVISAO
    syscall
    
    li $v0, 1
    move $a0, $t5
    syscall
    
    li $v0, 4
    la $a0, SIMBOLO_IGUAL
    syscall
    
    li $v0, 1
    move $a0, $t6
    syscall
    
    li $v0, 4
    la $a0, QUEBRA
    syscall
           
    move $v0, $t6
    
    #restaura os valores que foram salvos em $sp
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    
    addi $sp, $sp, 12
    
    jr $ra
    
    
contador:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    
    move $s0, $a0
    
loop_contador:
    beqz $s0, end_contador
    
    jal resetar_contador
    
    move $a0, $s0
    jal separa_digitos_dezena
    
    jal separa_digitos_unidade

    li $v0, 12 
    syscall
    
    addi $s0, $s0, -1
    
    j loop_contador

end_contador:
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    
    jr $ra
    
separa_digitos_dezena:
    sw $ra, 4($sp)
    
    li $t0, 0
    li $t1, 1
    li $t2, 2
    li $t3, 3
    li $t4, 4
    li $t5, 5
    li $t6, 6
    li $t7, 7
    li $t8, 8
    li $t9, 9
        
    li $s2, 10
    div $a0, $s2
    mfhi $a3
    mflo $s4
   
    beq $s4, $t0, um_zero
    beq $s4, $t1, um_um
    beq $s4, $t2, um_dois
    beq $s4, $t3, um_tres
    beq $s4, $t4, um_quatro
    beq $s4, $t5, um_cinco
    beq $s4, $t6, um_seis
    beq $s4, $t7, um_sete
    beq $s4, $t8, um_oito
    beq $s4, $t9, um_nove     

separa_digitos_unidade:
    sw $ra, 0($sp)
    
    li $t0, 0
    li $t1, 1
    li $t2, 2
    li $t3, 3
    li $t4, 4
    li $t5, 5
    li $t6, 6
    li $t7, 7
    li $t8, 8
    li $t9, 9

    li $s2, 10
    div $a0, $s2
    mfhi $s3
    mflo $s4
   
    beq $s3, $t0, dois_zero
    beq $s3, $t1, dois_um
    beq $s3, $t2, dois_dois
    beq $s3, $t3, dois_tres
    beq $s3, $t4, dois_quatro
    beq $s3, $t5, dois_cinco
    beq $s3, $t6, dois_seis
    beq $s3, $t7, dois_sete
    beq $s3, $t8, dois_oito
    beq $s3, $t9, dois_nove 
    
resetar_contador:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_PRETO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 220($t0)
sw $t4, 224($t0)
sw $t4, 228($t0)
sw $t4, 344($t0)
sw $t4, 348($t0)
sw $t4, 352($t0)
sw $t4, 356($t0)
sw $t4, 472($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 484($t0)
sw $t4, 600($t0)
sw $t4, 604($t0)
sw $t4, 608($t0)
sw $t4, 612($t0)
sw $t4, 728($t0)
sw $t4, 732($t0)
sw $t4, 736($t0)
sw $t4, 740($t0)
sw $t4, 856($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)
sw $t4, 868($t0)

sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 240($t0)
sw $t4, 244($t0)
sw $t4, 248($t0)
sw $t4, 364($t0)
sw $t4, 368($t0)
sw $t4, 372($t0)
sw $t4, 376($t0)
sw $t4, 492($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 504($t0)
sw $t4, 620($t0)
sw $t4, 624($t0)
sw $t4, 628($t0)
sw $t4, 632($t0)
sw $t4, 748($t0)
sw $t4, 752($t0)
sw $t4, 756($t0)
sw $t4, 760($t0)
sw $t4, 876($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)
sw $t4, 888($t0)

    jr $ra
    
seleciona_cor:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp) 
    
    li $t0, 1
    li $t1, 2
    move $s0, $a1
    
    beqz $s0, vermelho
    beq $s0, $t0, amarelo
    beq $s0, $t1, verde
    
vermelho:
    lw $t1, COR_VERMELHO
    lw $t2, COR_AMARELO_APAGADO
    lw $t3, COR_VERDE_APAGADO
    
    jal semaforo
    
amarelo:
    lw $t1, COR_VERMELHO_APAGADO
    lw $t2, COR_AMARELO
    lw $t3, COR_VERDE_APAGADO
    
    jal semaforo    
    
verde:
    lw $t1, COR_VERMELHO_APAGADO
    lw $t2, COR_AMARELO_APAGADO
    lw $t3, COR_VERDE
    
    jal semaforo    
    
semaforo:
la $t0, DISPLAY_ADRESS
lw $t0, 0($t0)
    
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 12($t0)
sw $t1, 16($t0)
sw $t1, 20($t0)
sw $t1, 24($t0)
sw $t1, 128($t0)
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 144($t0)
sw $t1, 148($t0)
sw $t1, 152($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 268($t0)
sw $t1, 272($t0)
sw $t1, 276($t0)
sw $t1, 280($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 392($t0)
sw $t1, 396($t0)
sw $t1, 400($t0)
sw $t1, 404($t0)
sw $t1, 408($t0)
sw $t1, 512($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)
sw $t1, 524($t0)
sw $t1, 528($t0)
sw $t1, 532($t0)
sw $t1, 536($t0)
sw $t1, 640($t0)
sw $t1, 644($t0)
sw $t1, 648($t0)
sw $t1, 652($t0)
sw $t1, 656($t0)
sw $t1, 660($t0)
sw $t1, 664($t0)
sw $t1, 768($t0)
sw $t1, 772($t0)
sw $t1, 776($t0)
sw $t1, 780($t0)
sw $t1, 784($t0)
sw $t1, 788($t0)
sw $t1, 792($t0)

sw $t2, 28($t0)
sw $t2, 32($t0)
sw $t2, 36($t0)
sw $t2, 40($t0)
sw $t2, 44($t0)
sw $t2, 48($t0)
sw $t2, 52($t0)
sw $t2, 156($t0)
sw $t2, 160($t0)
sw $t2, 164($t0)
sw $t2, 168($t0)
sw $t2, 172($t0)
sw $t2, 176($t0)
sw $t2, 180($t0)
sw $t2, 284($t0)
sw $t2, 288($t0)
sw $t2, 292($t0)
sw $t2, 296($t0)
sw $t2, 300($t0)
sw $t2, 304($t0)
sw $t2, 308($t0)
sw $t2, 412($t0)
sw $t2, 416($t0)
sw $t2, 420($t0)
sw $t2, 424($t0)
sw $t2, 428($t0)
sw $t2, 432($t0)
sw $t2, 436($t0)
sw $t2, 540($t0)
sw $t2, 544($t0)
sw $t2, 548($t0)
sw $t2, 552($t0)
sw $t2, 556($t0)
sw $t2, 560($t0)
sw $t2, 564($t0)
sw $t2, 668($t0)
sw $t2, 672($t0)
sw $t2, 676($t0)
sw $t2, 680($t0)
sw $t2, 684($t0)
sw $t2, 688($t0)
sw $t2, 692($t0)
sw $t2, 796($t0)
sw $t2, 800($t0)
sw $t2, 804($t0)
sw $t2, 808($t0)
sw $t2, 812($t0)
sw $t2, 816($t0)
sw $t2, 820($t0)

sw $t3, 56($t0)
sw $t3, 60($t0)
sw $t3, 64($t0)
sw $t3, 68($t0)
sw $t3, 72($t0)
sw $t3, 76($t0)
sw $t3, 80($t0)
sw $t3, 184($t0)
sw $t3, 188($t0)
sw $t3, 192($t0)
sw $t3, 196($t0)
sw $t3, 200($t0)
sw $t3, 204($t0)
sw $t3, 208($t0)
sw $t3, 312($t0)
sw $t3, 316($t0)
sw $t3, 320($t0)
sw $t3, 324($t0)
sw $t3, 328($t0)
sw $t3, 332($t0)
sw $t3, 336($t0)
sw $t3, 440($t0)
sw $t3, 444($t0)
sw $t3, 448($t0)
sw $t3, 452($t0)
sw $t3, 456($t0)
sw $t3, 460($t0)
sw $t3, 464($t0)
sw $t3, 568($t0)
sw $t3, 572($t0)
sw $t3, 576($t0)
sw $t3, 580($t0)
sw $t3, 584($t0)
sw $t3, 588($t0)
sw $t3, 592($t0)
sw $t3, 696($t0)
sw $t3, 700($t0)
sw $t3, 704($t0)
sw $t3, 708($t0)
sw $t3, 712($t0)
sw $t3, 716($t0)
sw $t3, 720($t0)
sw $t3, 824($t0)
sw $t3, 828($t0)
sw $t3, 832($t0)
sw $t3, 836($t0)
sw $t3, 840($t0)
sw $t3, 844($t0)
sw $t3, 848($t0)

lw $s0, 4($sp)
lw $ra, 0($sp)
addi $sp, $sp, 8

jr $ra

um_zero:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 344($t0)
sw $t4, 356($t0)
sw $t4, 472($t0)
sw $t4, 484($t0)
sw $t4, 600($t0)
sw $t4, 612($t0)
sw $t4, 728($t0)
sw $t4, 740($t0)
sw $t4, 856($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)
sw $t4, 868($t0)

    j fim_separa_dezena
    
um_um:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 96($t0)
sw $t4, 220($t0)
sw $t4, 224($t0)
sw $t4, 352($t0)
sw $t4, 480($t0)
sw $t4, 608($t0)
sw $t4, 736($t0)
sw $t4, 864($t0)

    j fim_separa_dezena

um_dois:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 356($t0)
sw $t4, 480($t0)
sw $t4, 604($t0)
sw $t4, 728($t0)
sw $t4, 856($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)
sw $t4, 868($t0)

    j fim_separa_dezena
    
um_tres:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 356($t0)
sw $t4, 480($t0)
sw $t4, 476($t0)
sw $t4, 612($t0)
sw $t4, 740($t0)
sw $t4, 728($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)

    j fim_separa_dezena
    
um_quatro:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 344($t0)
sw $t4, 356($t0)
sw $t4, 472($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 484($t0)
sw $t4, 612($t0)
sw $t4, 740($t0)
sw $t4, 868($t0)

    j fim_separa_dezena
    
um_cinco:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 344($t0)
sw $t4, 472($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 484($t0)
sw $t4, 612($t0)
sw $t4, 728($t0)
sw $t4, 740($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)

    j fim_separa_dezena

um_seis:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 344($t0)
sw $t4, 472($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 484($t0)
sw $t4, 600($t0)
sw $t4, 612($t0)
sw $t4, 728($t0)
sw $t4, 740($t0)
sw $t4, 856($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)
sw $t4, 868($t0)

    j fim_separa_dezena

um_sete:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 228($t0)
sw $t4, 356($t0)
sw $t4, 480($t0)
sw $t4, 608($t0)
sw $t4, 736($t0)
sw $t4, 864($t0)

    j fim_separa_dezena

um_oito:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 344($t0)
sw $t4, 356($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 600($t0)
sw $t4, 612($t0)
sw $t4, 728($t0)
sw $t4, 740($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)

    j fim_separa_dezena

um_nove:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 88($t0)
sw $t4, 92($t0)
sw $t4, 96($t0)
sw $t4, 100($t0)
sw $t4, 216($t0)
sw $t4, 228($t0)
sw $t4, 344($t0)
sw $t4, 356($t0)
sw $t4, 472($t0)
sw $t4, 476($t0)
sw $t4, 480($t0)
sw $t4, 484($t0)
sw $t4, 612($t0)
sw $t4, 740($t0)
sw $t4, 856($t0)
sw $t4, 860($t0)
sw $t4, 864($t0)
sw $t4, 868($t0)

    j fim_separa_dezena

dois_zero:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 364($t0)
sw $t4, 376($t0)
sw $t4, 492($t0)
sw $t4, 504($t0)
sw $t4, 620($t0)
sw $t4, 632($t0)
sw $t4, 748($t0)
sw $t4, 760($t0)
sw $t4, 876($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)
sw $t4, 888($t0)

    j fim_separa_unidade
    
dois_um:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 116($t0)
sw $t4, 240($t0)
sw $t4, 244($t0)
sw $t4, 372($t0)
sw $t4, 500($t0)
sw $t4, 628($t0)
sw $t4, 756($t0)
sw $t4, 884($t0)

    j fim_separa_unidade
    
dois_dois:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 376($t0)
sw $t4, 500($t0)
sw $t4, 624($t0)
sw $t4, 748($t0)
sw $t4, 876($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)
sw $t4, 888($t0)

    j fim_separa_unidade

dois_tres:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 376($t0)
sw $t4, 500($t0)
sw $t4, 496($t0)
sw $t4, 632($t0)
sw $t4, 760($t0)
sw $t4, 748($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)

    j fim_separa_unidade

dois_quatro:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 364($t0)
sw $t4, 376($t0)
sw $t4, 492($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 504($t0)
sw $t4, 632($t0)
sw $t4, 760($t0)
sw $t4, 888($t0)

    j fim_separa_unidade

dois_cinco:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 364($t0)
sw $t4, 492($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 504($t0)
sw $t4, 632($t0)
sw $t4, 748($t0)
sw $t4, 760($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)

    j fim_separa_unidade

dois_seis:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 364($t0)
sw $t4, 492($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 504($t0)
sw $t4, 620($t0)
sw $t4, 632($t0)
sw $t4, 748($t0)
sw $t4, 760($t0)
sw $t4, 876($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)
sw $t4, 888($t0)

    j fim_separa_unidade

dois_sete:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 248($t0)
sw $t4, 376($t0)
sw $t4, 500($t0)
sw $t4, 628($t0)
sw $t4, 756($t0)
sw $t4, 884($t0)

    j fim_separa_unidade
    
dois_oito:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 364($t0)
sw $t4, 376($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 620($t0)
sw $t4, 632($t0)
sw $t4, 748($t0)
sw $t4, 760($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)

    j fim_separa_unidade
    
dois_nove:
    la $t0, DISPLAY_ADRESS
    lw $t0, 0($t0)
    lw $t4, COR_BRANCO
    
sw $t4, 108($t0)
sw $t4, 112($t0)
sw $t4, 116($t0)
sw $t4, 120($t0)
sw $t4, 236($t0)
sw $t4, 248($t0)
sw $t4, 364($t0)
sw $t4, 376($t0)
sw $t4, 492($t0)
sw $t4, 496($t0)
sw $t4, 500($t0)
sw $t4, 504($t0)
sw $t4, 632($t0)
sw $t4, 760($t0)
sw $t4, 876($t0)
sw $t4, 880($t0)
sw $t4, 884($t0)
sw $t4, 888($t0)

    j fim_separa_unidade

fim_separa_dezena:
    lw $ra, 4($sp)
    jr $ra
    
fim_separa_unidade:
    lw $ra, 0($sp)
    jr $ra

end:
li $v0, 10
syscall

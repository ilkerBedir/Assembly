SSEG SEGMENT PARA STACK 'STACK';exe program? için stack segment olu?turma
     DW 32 DUP (?)
SSEG ENDS

DSEG SEGMENT PARA 'DATA';exe program? için data segment olusturma
  CR equ 0DH ; enter tan?mlama
  LF equ 0AH 
  MSG1 DB 'ELEMAN SAYISINI VERINIZ = ',0 ;boyut için gereken mesaj
  HATA DB  CR,LF,'HATALI ELEMAN GIRDINIZ LUTFEN TEKRAR GIRINIZ',CR,LF,0;Hata mesaj?
  MSG2 DB CR,LF,'DIZININ ELEMANLARINI GIRINIZ',0;eleman alma mesaj?
  msg3 db cr,lf,'eleman = ',0;eleman mesaj?
  MSG4 DB CR,LF,'CIKTI KUMESI  ',0;ç?kt? mesaj?
  MSG5 DB CR,LF, 'VERILEN KENARLAR UCGEN OLUSTURMAMAKTADIR',0;ç?kt? mesaj?
  MSG6 DB CR,LF,'BOYUT 3 DEN KUCUK OLAMAZ TEKRAR GIRINIZ',CR,LF,0
  BOYUT DW ?;boyut tan?mlama
  uzunluk dw 3000
  k1 dw ?
  k2 dw ?
  k3 dw ?
  dizi dw 100 dup(0);input dizi
 
DSEG ENDS

CSEG SEGMENT PARA 'CODE' ;code segment olusturma
     ASSUME CS:CSEG,DS:DSEG,SS:SSEG ;
ANA  PROC FAR ; main
     PUSH DS
     XOR AX,AX
     PUSH AX
     MOV AX,DSEG
     MOV DS,AX
     MOV AX,OFFSET MSG1
     CALL PUT_STR
     CALL GETN
     CMP AX,3
     JNB OK
    TKR:
     MOV AX,OFFSET MSG6
     CALL PUT_STR
     CALL GETN
     CMP AX,3
     JB TKR
     OK:
     MOV BOYUT,ax
     MOV AX,OFFSET MSG2
     call PUT_STR
     MOV CX,BOYUT
     XOR SI,SI  
     L1:
      MOV AX,OFFSET msg3
      call PUT_STR
      CALL GETN 
      MOV dizi[si],ax
      add si,2      
     LOOP L1
      mov cx,boyut
     dec cx
     xor ax,ax
     L2:
     PUSH CX
     xor Si,Si
     xor bx,bx
     L3:
     MOV AX,DIZI[SI]
     CMP AX,DIZI[SI+2]
     JNA D1
     XCHG AX,DIZI[SI+2]
     MOV DIZI[SI],AX
     mov bx,1
     D1:
     ADD SI,2  
     LOOP L3
     POP CX
     cmp bx,0
     jz cikis
     jmp dvm
     cikis:
     mov cx,1
     dvm:
     loop L2
     XOR SI,SI
     XOR DI,DI
     XOR AX,AX
     MOV CX,BOYUT
     SUB CX,2  
     W1:
     MOV AX,DIZI[SI]
     PUSH CX
     PUSH SI     
     W2:
     MOV BX,DIZI[SI+2]
     MOV DX,DIZI[SI+4]
     PUSH AX
     ADD AX,BX
     CMP AX,DX
     JNA DGL
     SUB AX,BX
     CMP AX,BX
     JA BYK
     JMP KCK
     BYK:
     SUB AX,BX
     JMP DVM1
     KCK:
     PUSH BX
     SUB BX,AX
     MOV AX,BX
     POP BX
     DVM1:
     CMP AX,DX
     JA DGL
     POP AX
     PUSH AX
     ADD AX,BX
     ADD AX,DX
     CMP AX,UZUNLUK
     JB UCGN
     JMP DGL
     UCGN:
     MOV UZUNLUK,AX
     POP AX
     PUSH AX
     MOV K1,AX
     MOV K2,BX
     MOV K3,DX
     DGL:
     ADD SI,2
     POP AX
     LOOP W2
     POP SI
     ADD SI,2
     POP CX
     LOOP W1
     MOV AX,UZUNLUK
     CMP AX,3000
     JE CIKIS3
     CIKIS2:
     MOV AX,OFFSET MSG4
     call PUT_STR  
     MOV AX,K1
     call PUTN
     MOV AX,OFFSET MSG4
     call PUT_STR
     MOV AX,K2
     call PUTN
     MOV AX,OFFSET MSG4
     call PUT_STR
     MOV AX,K3
     call PUTN
     jmp tamam
     CIKIS3:
     MOV AX,OFFSET MSG5
     call PUT_STR
tamam:     
    RETF
ANA ENDP


GETC PROC NEAR 
     MOV  AH,1H 
     INT  21H
     RET
GETC ENDP
PUTN PROC NEAR
     PUSH CX
     PUSH DX
     XOR DX,DX
     PUSH DX
     MOV CX,10
CALC_DIGITS:
     DIV CX
     ADD DX,'0'
     PUSH DX
     XOR DX,DX
     CMP AX,0
     JNE CALC_DIGITS
DISP_LOOP:
     POP AX
     CMP AX,0
     JE END_DISP_LOOP
     CALL PUTC
     JMP DISP_LOOP
END_DISP_LOOP:
    POP DX
    POP CX
    RET
PUTN ENDP
           
GETN PROC NEAR
     PUSH BX
     PUSH CX
     PUSH DX
GETN_START:
     MOV DX,1
     XOR BX,BX
     XOR CX,CX
NEW:
     CALL GETC
     CMP AL,CR
     JE  FIN_READ
     CMP AL,'-'
     JE ERROR
CTRL_NUM:
     CMP AL,'0'
     JB ERROR
     CMP AL,'9'
     JA  ERROR
     SUB AL,'0'
     MOV BL,AL
     MOV AX,10
     MUL CX
     MOV CX,AX
     ADD CX,bX
     JMP NEW
ERROR: 
     MOV AX,OFFSET HATA
     CALL PUT_STR
     JMP GETN_START
FIN_READ:
     MOV AX,CX
     CMP AX,999
     JA ERROR
     CMP AX,0
     JE ERROR
FIN_GETN:
     POP DX
     POP CX
     POP DX
     RET 
GETN ENDP               
     
PUT_STR PROC NEAR 
     PUSH BX
     MOV BX,AX
     MOV AL,BYTE PTR [BX]
   PUT_LOOP:
     CMP AL,0
     JE PUT_FIN
     CALL PUTC
     INC BX
     MOV AL,BYTE PTR [BX]
     JMP PUT_LOOP
   PUT_FIN:
     POP BX
     RET
   PUT_STR ENDP
PUTC proc NEAR
    push ax
    push dx
    mov dl,al
    mov ah,2
    int 21h
    pop dx
    pop ax
    ret
putc endp 

     
CSEG ENDS
     END ANA 
myss	SEGMENT	PARA STACK 'yigin'
		DW 20 DUP(?)
myss	ENDS
myds	SEGMENT PARA 'veri'
CR		EQU 13
LF		EQU 10
MSG1	DB 'Dizinin eleman sayisini giriniz: ',0
MSG2	DB CR,LF,'Dizinin elemanlarini giriniz: ',0
MSG3 	DB CR,LF,0
MSG4 	DB CR,LF, 'Kenarlar: ',0
MSG5	DB CR,LF,'Ucgen olusturabilecek eleman yok',0
HATA 	DB CR,LF,'Dikkat! sayi girmediniz tekrar giris yapiniz: ',0
dizi	DW 100 DUP(?)
n		DW 	?
kenar1	DW	0
kenar2	DW	?
kenar3	DW	?
toplam	DW	1000
myds	ENDS
mycs	SEGMENT PARA 'kod'
		ASSUME SS:myss,DS:myds,CS:mycs
ANA		PROC FAR
		PUSH DS
		XOR AX,AX
		PUSH AX
		MOV AX,myds
		MOV DS,AX
		
		MOV AX,OFFSET MSG1						
		CALL PUT_STR
		CALL GETN								;Kullanıcıdan dizi boyutunu aldım.
		MOV n,AX								;Girilen n sayisini, n değişkenine attım.
		SHL	AX,1								;Bu iki satırda dizi word tanımlı olduğu ve 0'dan başladığı...
		SUB AX,2								;...için son indisi 2*n-2 olacaktır.
		PUSH AX									;Bu sayıyı daha sonra kullanmak için stack'e attım.
		
		MOV AX,OFFSET MSG2						
		CALL PUT_STR
		MOV CX,n								;n tane eleman girmek için CX'e n sayisini attım.
		XOR SI,SI								;Başlangıç 0 olacağı için SI'yı sıfırladım.
get:	CALL GETN
		MOV dizi[SI],AX							;Girilen sayıyı dizinin SI. indisine koydum.
		ADD SI,2								;Word tanımlı olan dizinin sonraki elemanına erişmek için...
												;...SI'yı 2 arttırdım.
		LOOP get								;n eleman almak için GETN ile başlayan bir loop oluşturdum.
		
		POP AX									;Yukarıda bahsettiğim son indisi burada n'ye atadım.
		MOV n,AX

		XOR SI,SI								;Dizinin ilk elemanını tutmak üzere SI'yı sıfırladım.
L1:		MOV DI,SI								;Her döngü başında DI SI'nın sonrasından başlayarak diziyi geziyor.
L2:		ADD DI,2								;Başta SI'ya eşit olan DI, SI'nın bir sonrasından başlıyor.
		MOV BX,DI                               ;BX de DI'nın sonrasından başlayarak ayrıca diziyi geziyor...
L3:		ADD BX,2								;... Böylece bütün olası üçgenler kontrol ediliyor.
		MOV DX,dizi[BX]							;Üçgen oluşturma kontrolü.
		ADD DX,dizi[DI]							;[BX] ve [DI] kenarlarının toplamı...
		CMP DX,dizi[SI]							;...[SI]'dan küçükse üçgen oluşturmaz.
		JBE gec									;Eğer küçükse döngünün sonraki basamağına geçilir.
		
		MOV DX,dizi[DI]							;Yukarıdaki kontrol [BX] kenarı için yapılır.
		ADD DX,dizi[SI]
		CMP DX,dizi[BX]
		JBE gec
		
		MOV DX,dizi[SI]							;Yukarıdaki kontrol [DI] kenarı için yapılır.
		ADD DX,dizi[BX]
		CMP DX,dizi[DI]
		JBE gec
												;Eğer kenarlar kontrollerden geçmişse devam edilir.
		MOV AX,dizi[BX]							;Burada kenarlar AX'te toplanır.
		ADD AX,dizi[DI]							
		ADD AX,dizi[SI]
		CMP AX,toplam							;AX toplamdan küçük mü diye kontrol edilir.
		JAE gec									;Değilse döngünün sonraki basamağına geçilir.
		
		MOV toplam,AX							;Eğer AX küçükse yeni toplama AX atanır.
		MOV AX,dizi[BX]							;Böylece en küçük çevre toplamda saklanmış olur.
		MOV kenar1,AX							;En küçük çevreyi oluşturan kenarlar da kenar1,2,3'te saklanır.
		MOV AX,dizi[DI]
		MOV kenar2,AX
		MOV AX,dizi[SI]
		MOV kenar3,AX
		
gec:	CMP BX,n								;BX n. indise kadar gezecektir.
		JNE L3
		
		MOV AX,n								
		DEC AX
		DEC AX
		CMP DI,AX								;DI BX'in bir eksiğine yani n-1. indise kadar gezecektir.
		JNE L2
		
		MOV AX,n
		DEC AX
		DEC AX
		ADD SI,2
		CMP SI,AX								;SI DI'nın bir eksiğine yani n-2. indise kadar gezecektir.
		JNE	L1
		
		MOV AX,0								;kenar1'in ilk değeri 0'dı.
		CMP kenar1,AX							;Yani eğer hiçbir üçgen oluşturulamadıysa hala 0 olacaktır.
		JNE devam								;kenar1 0 mı diye kontrol edilir.
	
		MOV AX,OFFSET MSG5						;0'sa hiç üçgen oluşmamıştır.
		CALL PUT_STR							;O zaman ekrana ilgili mesaj yazar.
		JMP son									;Kodun sonuna atlanır.
devam:	MOV AX,OFFSET MSG4
		CALL PUT_STR
		MOV AX,kenar1							;Kenarlar ekrana yazılmak için AX'e atanır.
		CALL PUTN								;AX ekrana yazılır.
		MOV AX,OFFSET MSG3						;Boşluk bırakmak için kullandım.
		CALL PUT_STR
		MOV AX,kenar2
		CALL PUTN
		MOV AX,OFFSET MSG3
		CALL PUT_STR
		MOV AX,kenar3
		CALL PUTN
		MOV AX,OFFSET MSG3
		CALL PUT_STR
son:		
		RETF
ANA		ENDP		
GETC	PROC NEAR
		MOV AH,1h
		INT	21h
		RET
GETC	ENDP
PUTC	PROC NEAR
		PUSH AX
		PUSH DX
		MOV DL,AL
		MOV AH,2
		INT 21h
		POP DX
		POP AX
		RET
PUTC	ENDP
GETN	PROC NEAR
		PUSH BX
		PUSH CX
		PUSH DX
GETN_START:
		MOV DX,1
		XOR BX,BX
		XOR CX,CX
NEW:	CALL GETC
		CMP AL,CR
		JE FIN_READ
		CMP AL,'-'
		JNE CTRL_NUM
NEGATIVE:
		MOV DX,-1
		JMP NEW
CTRL_NUM:
		CMP AL,'0'
		JB error
		CMP AL,'9'
		JA error
		SUB AL,'0'
		MOV BL,AL
		MOV AX,10
		PUSH DX
		MUL CX
		POP DX
		MOV CX,AX
		ADD CX,BX
		JMP NEW
error:	MOV AX,OFFSET HATA
		CALL PUT_STR
		JMP	GETN_START
FIN_READ:
		MOV AX,CX
		CMP DX,1
		JE FIN_GETN
		NEG AX
FIN_GETN:
		POP DX
		POP CX
		POP DX
		RET
GETN	ENDP
PUTN	PROC NEAR
		PUSH CX
		PUSH DX
		XOR DX,DX
		PUSH DX
		MOV CX,10
		CMP AX,0
		JGE	CALC_DIGITS
		NEG AX
		PUSH AX
		MOV AL,'-'
		CALL PUTC
		POP AX
CALC_DIGITS:
		DIV CX
		ADD DX,'0'
		PUSH DX
		XOR DX,DX
		CMP AX,0
		JNE CALC_DIGITS
DISP_LOOP:
		POP AX
		CMP	AX,0
		JE END_DISP_LOOP
		CALL PUTC
		JMP DISP_LOOP
END_DISP_LOOP:
		POP DX
		POP CX
		RET
PUTN 	ENDP
PUT_STR	PROC NEAR
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


mycs	ENDS
		END ANA
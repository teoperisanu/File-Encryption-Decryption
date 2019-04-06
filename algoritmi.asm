.code

;Functia cripteaza continutul unui vector; fiecare caracter va survenii urmatoarele modificari:
;	*complementul fata de 2
;	*rotirea la dreapta cu o cheie data
;[EBP+8] - adresa de inceput al vectorului care contine caracterele
;[EBP+12] - lungimea utilizata a vectorului = numarul de caractere din vector
;[EBP+16] - cheia de criptare intre 0-7
criptare_1 PROC
		push EBP
		mov EBP, ESP
		
		mov ECX, [EBP+12]; numarul de caractere din vector
		cmp ECX, 0; daca ECX e 0 atunci vectorul e gol si nu avem ce cripta
		jna criptare_final; sari la final daca vectorul e gol
		
		cld; directia de parcurgere a vectorului: de la stanga la dreapta (crescator)
		mov ESI, [EBP+8]; in ESI punem adresa de inceput a vectorului; folosim registrul ESI pentru scoaterea caracterelor
		mov EDI, ESI; punem in EDI adresa de inceput a vectorului; folosim registrul EDI pentru repunerea in vector a caracterelor modifica
		
	Modifica_c:
		lodsb; citim caracterele, in AL va fi pus caracterul, ESI va fi incrementat cu 1 (ne deplasam in vector)
		xor AL,0FFh; complement fata de 1
		add AL,1; complement fata de 2
		push ECX; salvam valoare lui ECX pentru a nu altera bucla
		mov ECX,[EBP+16]; in ECX punem cheia de criptare
		ROR AL,CL; rotire cu cheie data
		stosb; rescriem pe aceasi pozitie caracterele, caractelui din registrul AL va fi pus din nou in vector, EDI va fi incrementat cu 1 (ne deplasam in vector)
		pop ECX; refacem valoarea lui ECX
	loop Modifica_c
		mov ECX, 0; ECX = 0
		mov [EDI], ECX; ne asiguram ca sirul de caractere se termina cu terminatorul 0
		
	criptare_final:
		mov ESP, EBP
		pop EBP
		ret 12
criptare_1 ENDP


;Functia decripteaza continutul unui vector; fiecare caracter va survenii urmatoarele modificari:
;	*rotirea la stanga cu o cheie data
;	*complementul fata de 2
;[EBP+8] - adresa de inceput al vectorului ce contine caracterele
;[EBP+12] - lungimea utilizata a vectorului = numarul de caractere
;[EBP+16] - cheia de decriptare intre 0-7
decriptare_1 PROC
		push EBP
		mov EBP, ESP
		
		mov ECX, [EBP+12]; punem in ECX numarul de caractere
		cmp ECX, 0; daca ECX e 0 atunci vectorul e gol si nu avem ce decripta
		jna decriptare_final; sari la final daca vectorul e gol
		
		cld; directia de parcurgere a vectorului: de la stanga la dreapta
		mov ESI, [EBP+8]; in ESI punem adresa de incepu a vectorului; folosim registrul ESI pentru scoaterea datelor
		mov EDI, ESI; punem in EDI adresa de inceput a vectorului; folosim registrul EDI pentru repunerea in vector a datelor modifica
		
	Modifica_d:
		lodsb; incarcam caracterele rand pe rand in registrul AL, ESI va fi incrementat cu 1 (ne deplasam in vector)
		push ECX; salvam valoarea din ECX
		mov ECX,[EBP+16]; punem in ECX cheia de criptare
		ROL AL,CL; rotire cu cheie data
		sub AL,1; revenim la complementul fata de 1
		xor AL,0FFh; revenim la valoarea initiala
		stosb; repunem in vector caracterul din registrul AL; incrementam EDI (ne deplasam in vector)
		pop ECX; refacem valoarea lui ECX
	loop Modifica_d
		
	decriptare_final:
		mov ESP, EBP
		pop EBP
		ret 12
decriptare_1 ENDP


;Functia cripteaza continutul unui vector; fiecare bloc de 8 caractere va survenii urmatoarele modificari:
;	*complementul fata de 1
;	*xor cu o cheie data
;[EBP+8] - adresa de inceput al vectorului ce contine caracterele
;[EBP+12] - lungimea utilizata a vectorului = numarul de caractere
;[EBP+16] - cheia de criptare pe 64 de biti
criptare_2 PROC
		push EBP
		mov EBP,ESP
	
		mov ECX, [EBP+12]; punem in ECX numarul de caractere
		cmp ECX, 0; daca ECX e 0 vectorul e gol
		jna criptare2_final; sarim peste criptare
		sar ECX, 3; ECX = ECX/8
		inc ECX; ECX = ECX+1
		
		cld; directia de parcurgere a vectorului: de la stanga la dreapta
		mov ESI, [EBP+8]; punem in ESI adresa de inceput a vectorului; folosim registrul ESI pentru scoaterea datelor
		mov EDI, ESI; punem in EDI adresa de inceput a vectorului; folosim registrul EDI pentru repunerea in vector a datelor modifica
		
	Modifica_c2:
		lodsd; incarcam prima jumatate a blocului in registrul EAX: 4 octeti; ESI se incrementeaza cu 4
		xor EAX, 0FFFFFFFFh; complement fata de 1
		xor EAX, [EBP+16]; xor cu prima jumatate din cheia data
		stosd; repunem din registrul EAX prima jumatatea modificata pe aceeasi pozitie; EDI se incrementeaza cu 4
		
		lodsd; incarcam cea de a doua jumatate a blocului in EAX; ESI se incrementeaza cu 4
		xor EAX, 0FFFFFFFFh; complement fata de 1
		xor EAX, [EBP+20]; xor cu a doua jumate din cheia data
		stosd; repunem pe acceasi pozitie, din registrul EAX, cei 4 octeti modificati; EDI se incrementeaza cu 4
	loop Modifica_c2
		
		mov ECX, 0; ECX = 0
		mov [EDI], ECX; ne asiguram ca vectorul sa se termine cu 0
	
	criptare2_final:
		mov ESP, EBP
		pop EBP
		ret 16
criptare_2 ENDP


;Functia decripteaza continutul unui vector; fiecare bloc de 8 caractere va survenii urmatoarele modificari:
;	*xor cu o cheie data
;	*complementul fata de 1
;[EBP+8] - adresa de inceput al vectorului ce contine caracterele
;[EBP+12] - lungimea utilizata a vectorului = numarul de caractere din vector
;[EBP+16] - cheia de decriptare pe 64 de biti
decriptare_2 PROC
		push EBP
		mov EBP,ESP
	
		mov ECX, [EBP+12]; punem in ECX numarul de caractere
		cmp ECX, 0; daca ECX e 0 atunci vectorul e gol, nu avem ce decripta
		jna criptare2_final; daca ECX <= 0 se sare la final fara sa se mai decripreze
		sar ECX, 3; ECX = ECX/8
		inc ECX; ECX = ECX+1
		
		cld; directia de parcurgere a vectorului: de la dreapta la stanga
		mov ESI, [EBP+8]; in ESI incarcam adresa de inceput a vectorului; folosim registrul ESI pentru scoaterea datelor
		mov EDI, ESI; in EDI incarcam adresa de inceput a vectorului; folosim registrul EDI pentru repunerea in vector a datelor modifica
		
	Modifica_d2:
		lodsd; incarcam prima jumatate a blocului: primii 4 octeti vor fi pusi in registrul EAX; ESI se incrementaza cu 4
		xor EAX, [EBP+16]; xor cu prima jumate din cheia dat
		xor EAX, 0FFFFFFFFh; complement fata de 1
		stosd; repunem din registrul EAX, pe acceasi pozitie, caractele modifica; EDI se incrementeaza cu 4
		
		lodsd; incarcam a doua jumatate (de 4 octeti) in EAX; ESI se incrementeaza cu 4
		xor EAX, [EBP+20]; xor cu a doua jumate din cheia dat
		xor EAX, 0FFFFFFFFh; complement fata de 1
		stosd; repunem din registrul EAX, pe acceasi pozitie, caractele modifica din a doua jumatate a blocului; EDI se incrementeaza cu 4
	loop Modifica_d2
		
		mov ECX, 0; ECX = 0
		mov [EDI], ECX; ne asiguram ca sirul se termina cu 0
	
	criptare2_final:
		mov ESP, EBP
		pop EBP
		ret 16
decriptare_2 ENDP



extern printf: proc
extern scanf: proc
extern exit: proc


.data

menu DB "Optiuni:", 10, 13, "1.Algoritmul 1", 10, 13, "2.Algoritmul 2", 10, 13, "3.Printare fisier", 10, 13,"4.Iesire" , 10, 13, "Optiune: ", 0
msg_error_option DB "Optiune invalida", 10, 13, 10, 13, 0
msg_file_path DB "Introduceti calea absoluta catre fisier de citire: ", 0
msg_file_path2 DB "Introduceti calea absoluta catre fisier de scriere: ", 0
msg_operation DB "Introduceti operatia (criptare/decriptare): ", 0 
msg_key_1 DB "Introduceti cheia de criptare(intre 0 si 7): ", 0
msg_key_2 DB "Introduceti cheia de criptare: ", 0
msg_header DB 10, 13, "CONTINUTUL FISIERULUI:", 10, 13, 0 
new_line DB 10, 13, 0

string_format DB "%s", 0
int_format DB "%d", 0

criptare DB "criptare", 0
decriptare DB "decriptare", 0

key1 DD 0
key2 DQ 0

op DB 10 DUP(?), 0

.code

;Functia printeaza menium principal si citeste optiunea
meniu PROC
		push EBP
		mov EBP, ESP
		
	afisare_meniu:
		push offset menu; meniul
		call printf; printare meniu
		add ESP, 4
	
	citire_optiune:
		push offset op; adresa variabilei unde vom stoca optiunea
		push offset string_format; format strind %s
		call scanf; citire optiune
		add ESP, 8
		
		
		mov AX, word ptr op; ne intereasa doar jumatatea low a variabilei optiune
		
		;Validam optiunea citita:
		cmp AH, 0; daca AH nu e 0 atunci evident s-a citit o valoarea mai mare de un octet
		jne eroare_optiune; atunci se va sari la un mesaj de eroare
		;verificam pe rand daca ce am citit este agal cu caracterele 1, 2, 3 sau 4, altfel trebuie citit din nou
		cmp AL, '1'
		je final_meniu
		cmp AL, '2'
		je final_meniu
		cmp AL, '3'
		je final_meniu
		cmp AL, '4'
		je final_meniu
		
	eroare_optiune:
		push offset msg_error_option; mesaj de eroare
		call printf; printam eroare - optiunea nu exista
		add ESP, 4
		jmp afisare_meniu
		
		
	final_meniu:
		mov ESP, EBP
		pop EBP
		ret
meniu ENDP



;Functia citeste calea catre un fisier pentru citire
;[EBP+8] - adresa vectorului unde va fi salvata calea
citireCale PROC
		;functia citeste calea absoluta catre un fisier
		push EBP
		mov EBP, ESP
		
		push offset msg_file_path; mesaj sugestiv
		call printf ;afisam un mesaj pentru a introduce calea absoluta catre fisier
		add ESP, 4
		
	citire_cale:
		push [EBP+8]; adresa vectorului unde vom salva calea catre fisier
		push offset string_format; format string %s
		call scanf ;citim calea in vectorul dat ca parametru
		add ESP, 8
		
		mov ESP, EBP
		pop EBP
		ret 4
citireCale ENDP



;Functia citeste calea catre un fisier pentru scriere
;[EBP+8] - adresa vectorului unde va fi salvata calea
citireCale2 PROC
		;functia citeste calea absoluta catre un fisier
		push EBP
		mov EBP, ESP
		
		push offset msg_file_path2; mesaj sugestiv
		call printf ;afisam un mesaj pentru a introduce calea absoluta catre fisier
		add ESP, 4
		
	citire_cale:
		push [EBP+8]; adresa vectorului unde vom salva calea catre fisier
		push offset string_format; format string %s
		call scanf ;citim calea
		add ESP, 8
		
		mov ESP, EBP
		pop EBP
		ret 4
citireCale2 ENDP



;Functia citeste operatia de criptare sau decriptare
;returneaza in EAX: 0 daca s-a ales criptare, 1 daca s-a ales decriptare
citireOperatie PROC
		;functia citeste operatie: criptare/decriptare 
		push EBP
		mov EBP, ESP
		
	citire_operatie:
		push offset msg_operation; mesaj sugestiv
		call printf ;afisam un mesaj pentru introducerea operatiei
		add ESP, 4
		
		push offset op; adresa variabilei unde vom salva optiunea
		push offset string_format; format string %s
		call scanf ;citim operatia
		add ESP, 8
		
		lea ESI, op; punem in ESI adresa de inceput a variabilei op
		lea EDI, criptare; punem in EDI adresa de inceput variabilei criptare
		cld; setam directia de parcurgere: de la stanga la dreapta (crescator)
		mov ecx, 8; ECX = 8, numarul de litere din cuvantul "criptare"
		
	verificare_criptare:
		cmpsb ;verificam daca valoarea din variabila op este egala cu stringul "criptare", comparand rand pe rand fieacare caracter pana la final; ESI si EDI se incrementeaza cu 1
		jne decriptare_citire; daca nu sunt egale incercam sa comparam valoarea din variabila cu stringul "decriptare"
	loop verificare_criptare; repetam de 8 ori
		mov EAX, 0; daca programul a ajuns aici inseamna ca valoarea din variabila este "criptare", atunci punem in EAX = 0
		jmp final_citire; sarim la final
		
	decriptare_citire:
		lea ESI, op; punem in ESI adresa de inceput a variabilei op
		lea EDI, decriptare; punem in EDI adresa de inceput variabilei criptare
		cld; directia de parcurgere: stanga -> dreapta
		mov ECX, 10; ECX = 10, numarul de litere din cuvantul "decriptare"
	Verificare_decript:
		cmpsb ;verificam daca valoarea din variabila op este agala cu "descriptare", comparand rand pe rand fieacare caractel pana la final; ESI si EDI se incrementeaza cu 1
		jne citire_operatie; daca vreun caracter din varaibala op nu e egal cu cel de pe aceeasi pozitie din "decriptare" atunci citim din nou operatia
	loop Verificare_decript; repetam de 10 ori
		mov EAX, 1; daca programul ajunge pana aici atunci op = "decriptare" si atunci setam EAX cu 1
		jmp final_citire; sari la final
		
	final_citire:	
		mov ESP, EBP
		pop EBP
		ret
citireOperatie ENDP


;Functia citeste cheia pentru criptare/decriptare pentru algoritmul 1
;[EBP+8] - adresa variabilei in care vom salva cheia
citireCheie1 PROC
		;functia citeste o cheie de criptare intre 0  si 7
		push EBP
		mov EBP, ESP
		
	citire_cheie1:	
		push offset msg_key_1; mesaj sugestiv
		call printf ;afisam un mesaj
		add ESP, 4
		
		push offset key1; adresa variabilei in care vom salva cheia
		push offset int_format; format intreg %d
		call scanf ;citim cheia
		add ESP, 8
		
		mov EAX, key1; punem in EAX cheia
		cmp EAX, 0 ;verificam: cheia < 0
		jl citire_cheie1; daca cheia < 0 citim din nou
		
		cmp EAX, 7 ;verifacam: cheia > 7 
		jg citire_cheie1; daca cheia > 7 citim din nou
		
		mov [[EBP+8]], EAX; punem in interiorul variabilei valoarea cheii
		
		push offset new_line; adresa unei vector care contine o linei noua
		call printf; afisam o linie noua, pentru claritarea meniului
		add ESP, 4
		
		mov ESP, EBP
		pop EBP
		ret 4
citireCheie1 ENDP


;Functia citeste cheie de criptare/decriptare pentru algoritmul 2
;[EBP+8] - adresa variabilei in care salvam prima jumatate a cheii
;[EBP+12] - adresa variabilei in care salvam a doua jumatate a cheii
citireCheie2 PROC
		;functia citeste o cheie de criptare intre 0  si 7
		push EBP
		mov EBP, ESP
		
	citire_cheie2:	
		push offset msg_key_2; mesaj sugestic
		call printf ;afisam un mesaj
		add ESP, 4
		
		push offset key2; adresa unei variabile pe 64 biti = 8 octeti
		push offset int_format; format intreg %d
		call scanf ;citim cheia
		add ESP, 8
		
		mov EAX, dword ptr key2; punem in EAX primul dublucuvant, primii 4 octeti
		mov [[EBP+8]], EAX; punem in interiorul primei variabile, prima jumatare a cheii
		mov EAX, dword ptr key2+4; punem in EAX al doilei dublucuvant, ceilaltii 4 octeti
		mov [[EBP+12]], EAX; punem in interiorul celei de a doua variabile, cea de a doua jumatate a cheii
		
		push offset new_line; adresa unui vector ce contine o linie noua
		call printf; afisam o linie noua, pentru claritatea meniului
		add ESP, 4
		
		mov ESP, EBP
		pop EBP
		ret 8
citireCheie2 ENDP


;Functia afiseaza la iesirea standar continutul unui vectorul
;[EBP+8] - adresa de inceput a vectorului
afisareFisier PROC
		push EBP
		mov EBP, ESP
		
		push [EBP+8]; adresa de inceput a vectorului
		push offset string_format; format string %s
		call printf; printam tot continutul vectorului
		add ESP, 8
		
		mov ESP, EBP
		pop EBP
		ret 4
afisareFisier ENDP


;Functia afiseaza un antet prestabilit, informativ, pentru printarea fisierelor
afisareAntetFisier PROC
		push EBP
		mov EBP, ESP

		push offset msg_header; mesajul "CONTINUTUL FISIERULUI:"
		call printf; printam mesaj
		add ESP, 4

		mov ESP, EBP
		pop EBP
		ret

afisareAntetFisier ENDP


;Functia afiseaza doua linii goale
afisareLinieDubla PROC
		push EBP
		mov EBP, ESP

		push offset new_line; adresa unui vector ce contine o linie goala
		call printf; printarea primei linii
		add ESP, 4
		
		push offset new_line; adresa unui vector ce contine o linie goala
		call printf; afisarea celei de a doua
		add ESP, 4

		mov ESP, EBP
		pop EBP
		ret
afisareLinieDubla ENDP
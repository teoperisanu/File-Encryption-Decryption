
extern printf: proc
extern fopen: proc
extern fclose: proc
extern fread: proc
extern fwrite: proc
extern rename: proc
extern remove: proc


.data
;modurile de deschidere ale unui fisier:
mode_read DB "r", 0 ; citire
mode_write DB "w", 0 ; scriere

new DB "_nou.txt", 0

open_error db "Fisierul nu a putut fi deschis.",10,13,0; mesaj de eroare

 
.code

;Functia deschide un fisier pentru citire
;[EBP+8] - adresa unui vector unde avem salvata calea catre fisier
;[EBP+12] - adresa variabilei unde salvam pointerul catre fisier
deschideFisierCitire PROC
		push EBP
		mov EBP, ESP
		
		deschidere:
		push offset mode_read; mod citire: "r"
		push [EBP+8]; calea catre fisier
		call fopen; deschidem fisierul; in EAX se salveaza pointerul catre fisier
		add ESP, 8
		
		mov ESI, [EBP+12]; in ESI vom avea adresa variabilei in care vom salva pointerul la fisier
		mov [ESI], EAX; punem pointerul in variabila
		cmp EAX, 0; daca EAX este 0, atunci a aparut o eroare la deschiderea fisierului
		je eroare_deschidere; sari la mesaj de eroare
		jmp final_deschidere; sari la final
		
	eroare_deschidere:
		push offset open_error; mesaj de eroare
		call printf; afisam mesajul de eroare
		add ESP, 4
		mov EAX, 0; ne asigaram ca in EAX se pastreaza 0 = EROARE
		
	final_deschidere:	
		mov ESP, EBP
		pop EBP
		ret 8
deschideFisierCitire ENDP


;Functia citeste din fisier
;[EBP+8] - adresa vectorului unde vom salva caracterele citite
;[EBP+12] - adresa variabilei - pointer la fisier (valoare va fi returnata de functie)
citireFisier PROC
		push EBP
		mov EBP, ESP

	citire:
		push [EBP+12]; stream - pointer la fisier
		push 100; numarul de caractere pe care sa le citim
		push 1; lungimea unui caractere = 1 octet
		push [EBP+8]; adresa vectorului in care vom salvam caracterele citite
		call fread; citim, in EAX se va returna numarul de caractere citite
		add ESP, 16
	
	final_citire:
		mov ESP, EBP
		pop EBP
		ret 8
citireFisier ENDP


;Functia deschide un fisier pentru scriere; daca fisierul nu exista, acesta va fi creat
;[EBP+8] - adresa vectorului unde avem salvata calea catre fisier
;[EBP+12] - adresa variabilei in care vom salva pointer catre fisier (valoarea va fi returnata de functie)
deschideFisierScriere PROC
		push EBP
		mov EBP, ESP
		
	creare_fisier:
		push offset mode_write; mod scriere: "w"
		push [EBP+8]; adresa vectorului unde avem salvata calea catre fisier
		call fopen; cream un fisier pentru scriere, in EAX se salveaza pointerul catre fisier
		add ESP, 8
		mov ESI, [EBP+12]; in ESI punem adresa variabilei in care vom salva pointerul
		mov [ESI], EAX; punem in variabila valoarea pointerului
		
		mov ESP, EBP
		pop EBP
		ret 8
deschideFisierScriere ENDP


;Functia scrie intr-un fisier
;[EBP+8] - adresa vectorului de unde vom lua caracterele pe care le vom scrie in fisier
;[EBP+12] - numarul de caractere pe care ce vor fi scrise in fisier
;[EBP+16] - adresa vectorului in care avem salvata calea catre fisierul
scriereFisier PROC
		push EBP
		mov EBP, ESP
		
	scriere:
		push [EBP+16]; stream - pointer la fisier
		push [EBP+12]; numarul de caractere pe care sa le scriem in fisier
		push 1; lungimea unui caractere = 1 octet
		push [EBP+8]; adresa vectorului de unde luam continutul pe care il scriem in fisier
		call fwrite; scriem in fisier
		add ESP, 16
		
	final_scriere:
		mov ESP, EBP
		pop EBP
		ret 12
scriereFisier ENDP


;Functia inchide 2 fisiere date ca parametrii
;[EBP+8] - adresa variabilei in care se afla pointerul la primul fisier
;[EBP+12] - adresa variabilei in care se afla pointerul celui de al doilea fisier
inchideFisiere PROC
		push EBP
		mov EBP, ESP
		
		push [EBP+8]; pointerul la primul fisier
		call fclose; inchiderea primului fisier
		add ESP, 4
		
		push [EBP+12]; pointerul la al doilea fisier
		call fclose; inchiderea celui de al doilea
		add ESP, 4

		mov ESP, EBP
		pop EBP
		ret 8
inchideFisiere ENDP
.386
.model flat, stdcall

include citire_scriere_fisier.asm
include algoritmi.asm
include UI.asm

includelib msvcrt.lib
extern exit: proc

public start

.data
key_1 DD 0 ; cheia de criptare pentru algoritmul 1
key2_1 DD 0 ; prima jumatate a cheii de criptare pentru algoritmul 2
key2_2 DD 0 ; a doua jumatate a cheii de criptare pentru algoritmul 2
pointer_read DD 0 ; pointerul catre fisierul din care vom citi
pointer_write DD 0 ; pointerul catre fisierul in care vom scrie
len DD 0 ; numarul de caractere citite
options DD 0 ; optiunea: 0 - criptare / 1 - decriptare
alg DB 0 ;algoritmul: 1 sau 2

file_path_r DB 100 DUP(?), 0 ; vector in care vom salva calea catre fisierul din care vom citi
file_path_w DB 100 DUP(?), 0 ; vectorul in care vom salva calea catre fisierul in care vom scrie
buffer DB 100 DUP(?), 0 ; vectorul in care vom salva caracterele citite



.code


;Functia principala a programului
start:
Main:
		call meniu; afisam meniu si citim optiunea, returneaza in AL optiunea
		
		mov alg, AL; punem in variabila alg optiunea 1/2/3/4
		
		cmp AL, '3'; Optiunea 3 = printare fisier
		je Printare_fisier; daca s-a ales optiunea 3 se sare la eticheta pentru printarea unui fisier 
		cmp AL, '4'; Optiunea 4 = Iesirea din program
		je Sfarsitul_programului; daca s-a ales optiunea 4 se sfarseste programul
		
	reciteste:
		push offset file_path_r; adresa unui vector gol in care vom salva calea catre fisierul din care vom citi
		call citireCale; citim calea catre un fisier
		
		push offset pointer_read; adresa unei variabile gole in care vom salva pointerul catre fisierul din care vom citi
		push offset file_path_r; adresa vectorului care contine calea catre fisierul din care vom citi
		call deschideFisierCitire; deschidem fisierul
		cmp EAX, 0; daca EAX == 0, atunci a aparut o eroare la deschidere (fisierul nu exista) si vom citi din nou calea
		je reciteste; citim pana putem deschide un fisier
	
		;in caz ca dorim sa inlocuim fisierul
		;push offset file_path_r
		;push offset file_path_w
		;call scrieCale; cream o noua cale pentru fisierul in care vom scrie
	
		push offset file_path_w; adresa unui vector gol in care vom salva calea catre fisierul in care vom scrie
		call citireCale2; citim calea catre fisierul pentru scriere
	
		push offset pointer_write; adresa unei variabile goale in care vom salva pointerul catre fisierul in care vom scrie
		push offset file_path_w; adresa de inceput a vectorului in care se afla calea catre fisierul de scriere
		call deschideFisierScriere; deschidem fisierul in care vom scrie, daca acesta nu exista, acesta va fi creat
		
	afisari:
		call citireOperatie; citim operatia: criptare/decriptare, functia va returna in EAX: 0 pentru criptare sau 1 pentru decriptare
		mov options, EAX; punem in variabila optiune: 0 sau 1 pentru criptare sau decriptare
		
		;Pregatire pentru citirea cheii
		mov Al, alg; repunem in AL algoritmul: 1 sau 2
		cmp AL, '1'; 1. Algoritm 1
		jne citire_cheie_2; daca in AL nu e valoare 1 atunci sigur e 2 si sarim direct la algoritmul 2
		
	citire_cheie_1:
		push offset key_1; adresa variabilei goale in care vom salva cheia de criptare pentru primul algoritm
		call citireCheie1; citim cheia pentru primul algoritm
		jmp Prelucrare; sarim direct la criptare/decriptarea continutului
	citire_cheie_2:
		push offset key2_1; adresa unei variabile goale pe 4 octeti in care vom salva prima jumatate din cheia de criptare pentru algoritmul 2
		push offset key2_2; adresa unei variabile goale pe 4 octeti in care vom salva a doua jumatate din cheia de criptare pentru algoritmul 2
		call citireCheie2; citim cheia pentru al doilea algoritm
	
	Prelucrare:
	
		push pointer_read; valoarea pointerului catre fiserul de citire
		push offset buffer; adresa vectorului in care vom salva caracterele citite
		call citireFisier; citim din fisier maxim 100 de caractere; functia returneaza in EAX numarul de caractere citite
		mov len, EAX; mutam in variabila len numarul de caractere citite
		
		;Pregatire pentru criptarea/decriptarea fisierului 
		mov AL, alg; punem in AL algoritmul citit: 1 sau 2
		cmp AL, '1'; daca in AL e 1 atunci s-a aleas primul algoritm
		jne Algoritm_2; altfel s-a ales al doilea algorit si sarim la el
		
	Algoritm_1:
		;parametrii pentru criptare/decriptare:
		push key_1; valoarea cheii de criptare pentru algoritmul 1
		push len; numarul de caractere citite, ce trebuie criptare
		push offset buffer; adresa vectorului in care au fost salvate caracterele citite
		
		mov EAX, options; mutam in EAX optiunea: 0 pentru criptare, 1 pentru decriptare
		cmp EAX, 0; 0 - criptare, 1 - decriptare
		jne Decriptare_alg1; daca in EAX nu e 0 atunci sigur e 1 si sarim direct la decriptare
		
	Criptare_alg1:
		call criptare_1; primul algoritm de criptare
		jmp Scriere; sari direct la scrierea in fisier
	Decriptare_alg1:
		call decriptare_1; primul algoritm de decriptare
		
		jmp Scriere; sari direct la scrierea in fisier
	Algoritm_2:
		push key2_2; a doua jumatare a cheii de criptare pentru algoritmul 2
		push key2_1; prima jumatare a cheii de criptare pentru algoritmul 2
		push len; numarul de caractere citite din fisier
		push offset buffer; adresa vectorului unde au fost salvate caracterele citite
		
		mov EAX, options; mutam in EAX valoarea din variabila options, care poate fii 0 pentru criptare sau 1 pentru decriptare
		cmp EAX, 0; 0 - criptare, 1 - decriptare
		jne Decriptare_alg2; daca in EAX nu e0 atunci sigur e 1 si sarim direct la decriptare
		
	Criptare_alg2:
		call criptare_2; al doilea algoritm de criptare
		jmp Scriere; sari direct la scrierea in fisier
	Decriptare_alg2:
		call decriptare_2; al doilea algoritm de decriptare
		
		
	Scriere:
	
		push pointer_write; valoarea pointerului catre fisierul in care vom scrie
		push len; numarul de caractere citite -> numarul de caractere ce trebuie scrire
		push offset buffer; adresa vectorului din care luam caracterele
		call scriereFisier; scriem in fisier
		
		mov EAX, len; mutam in EAX numarul de caractere citite/scrire
		cmp EAX, 100; verificam daca mai avem de citit: daca am citit 100 de caractere probabil mai avem de citit, daca am citit mai putin de 100 am terminat de citit
		je Prelucrare; daca am citit 100 de caractere sarim din nou la citirea din fisier + criptare/decriptare + scriere in fisier
	
	Inlocuire:
	
		push pointer_read; valoarea pointerului cater fisierul din care am citit
		push pointer_write; valoarea pointerului catre fisierul in care am scris
		call inchideFisiere; inchidem amandoua fisierele
		
		;push offset file_path_r
		;push offset file_path_w
		;call inlocuireFisier; inlocuim fisierele

		jmp Main; sarim direct la Main, continuam executia programului de la inceput
		
Printare_fisier:	
		
		push offset file_path_r; adresa unui vector gol in care vom salva calea catre un fisier
		call citireCale; citim calea cater fisierul pe care il vom deschide, citi apoi afisa
		
		push offset pointer_read; adresa unei variabile goale in care vom salve pointerul catre fisierul din care vom citi
		push offset file_path_r; adresa catre vectorul in care avem calea catre fisierul din care vom citi
		call deschideFisierCitire; deschidem fisierul
		cmp EAX, 0; daca in EAX e 0 atunci fisierul nu exista si atunci citim din nou calea
		je Printare_fisier
		
		call afisareAntetFisier; afisam antetul: "CONTINUTUL FISIERULUI: "
	
	citire_printare:
		push pointer_read; valoarea pointerului catre fisierul din care vom citi
		push offset buffer; adresa unui vector gol in care vom salva caracterele citite
		call citireFisier; citim din fisier
		mov len, EAX; mutam in varaibila len numarul de caractere citite
		
		push offset buffer; adresa vectorului in care avem salvate caracterele citite
		call afisareFisier; afisam fisierul (afisam continurul vectorului)
		
		mov EAX, len; punem in EAX numarul de caractere citite
		cmp EAX, 100; verificam daca mai avem de citit: daca am citit 100 de caractere probabil mai avem de citit, daca am citit mai putin de 100 am terminat de citit
		je citire_printare; daca am citit 100 de caractere sarim din nou la citirea din fisier + printarea pe ecran
		
		push pointer_read; valoarea pointerului fisierului din care am citit
		call fclose; inchidem fisierul
		add ESP, 4

		call afisareLinieDubla; afisam o linie dubla cu scop estetic
		jmp Main; sarim direct la Main, continuam executia programului de la inceput
		
Sfarsitul_programului:
		push 0
		call exit; finalul programului
end start

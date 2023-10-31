; 
; TCH017 - Projet no1 - D�codeur de float IEEE754
;
; Auteur     : Francis Bourdeau et Iannick Gagnon
; Fichier    : chargeur_donnees.pep
; Version    : A2023
; Desription : Ce programme charge des donn?es en m?moires afin qu'un d?codeur IEEE754 
;              simple pr�cision en fasse la lecture et l'affichage.
;
; Voici la structure de la m�moire : 
;
;        0x1000  1   bit indiquant si la m?moire a ?t? initialis? (bit = 1), ou non (bit = 0).
;        0x1002  2   bytes indiquant le nombre de donn?es enregistr? dans la m?moire.
;        0x1004  1er float IEEE754 ?crit sur 4 bytes.
;        0x1008  2e  float IEEE754 ?crit sur 4 bytes.
;        0x100C  3e  float IEEE754 ?crit sur 4 bytes.
;        0x1010  3e  float IEEE754 ?crit sur 4 bytes.
;
; ****************************************************************************************************
; D?BUT DU CHARGEUR DE DONN?ES (NE PAS TOUCHER ? CETTE PARTIE)
; ****************************************************************************************************
;
; Stocker l'indicateur que les donn?es ont ?t? charg?es
;
LDA 0x001,i
STA 0x1000,d 
;
; Stocker le nombre de donn?es ? lire
;
LDA 0x05,i
STA 0x1002,d 
;       
; Chiffre 1 = 123.75             -> 0x42F78000
;
LDA 0x42F7,i
STA 0x1004,d
LDA 0x8000,i
STA 0x1006,d
;
; Chiffre 2 =  -15.0             -> 0xC1700000
;
LDA 0xC170,i
STA 0x1008,d
LDA 0x0000,i
STA 0x100A,d
;
; Chiffre 3 = 3.328125           -> 0x40550000
;
LDA 0x4055,i
STA 0x100C,d
LDA 0x0000,i
STA 0x100E,d
;
; Chiffre 4 = 9999.25            -> 0x461C3D00
;
LDA 0x461C,i
STA 0x1010,d
LDA 0x3D00,i
STA 0x1012,d
;  
; Chiffre 5 =  -2.3837890625     -> 0xC0189000
;
LDA 0xC018,i
STA 0x1014,d
LDA 0x9000,i
STA 0x1016,d
;
; ****************************************************************************************************
; FIN DU CHARGEUR DE DONN?ES
; ****************************************************************************************************
;
; ****************************************************************************************************
; D?BUT DU PROGRAMME PRINCIPAL
; ****************************************************************************************************

;Valider le chargement
LDA              0x1000, d

IF:              CPA 0X001,i
                 BREQ VALIDE

                 STRO no_valid,d
                 BR FIN

VALIDE:          STRO valid,d


;D�terminer le nombre de valeurs stock�es
LDA              0x1002,d 
STA              nb_val,d
STRO             msgnbval,d
DECO             nb_val,d
CHARO            '\n',i
CHARO            '\n',i


;Boucle principale
FOR:             LDA iter,d
                 CPA nb_val,d 
                 BRGT ENDFOR ;Si l'it�ration est �gale � nb_val, on arr�te

                 ;Afficher chaque adresse
                 STRO msgadd1,d
                 DECO iter,d 
                 STRO msgadd2,d
                 DECO adresse,d
                 CHARO '\n',i

                 ;Afficher 1ere partie de chaque chiffre
                 STRO msgpar1,d
                 DECO adresse,n
                 CHARO '\n',i

                 ;Extraire signe                
                 LDBYTEA adresse,n
                 ASRA ;Faire 7 d�calages pour avoir dernier bit
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 STA signe,d ;On la stocke, pour l'afficher apr�s la 2e partie du chiffre


                 ;Extraire exposant
                 LDA adresse,n ;Prendre les bits de la 1ere partie
                 ANDA masque,d ;Et binaire pour avoir juste les bits de l'exposant
                 ASRA ;Faire 7 d�calages pour avoir la valeur de l'exposant
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 STA expos,d ;On le stocke, on va l'afficher apr�s le signe plus loin

                 ;Calculer la puissance
                 LDA expos,d
                 SUBA BIAIS,i
                 STA puiss,d

                 ; Calculer la partie enti�re
                 ;Aller � l'adresse du 2e octet
                 LDA adresse,d
                 ADDA 1,i
                 STA adresse,d            
                 
                 LDA adresse,n    ;Saisir le 2e octet de la 1ere partie + 1er octet de la 2e partie
                 ASLA             ;Le 1er chiffre du 2e octet fait partie de l'exposant, donc on l'enl�ve
                 STA bytes23,d

                 ;Boucle extraire bits
                 FORINT:          LDA     iter_int,d
                                  CPA     puiss,d     ;On arr�te de boucler quand on a tous les bits
                                  BREQ    ENDFINT
                                  
                                  LDA     iter_int,d
                                  ADDA    1,i         ;it�rer
                                  STA     iter_int,d

                                  LDA     bytes23,d   ;Charger les bytes 2 et 3 du chiffre
                                  ASLA
                                  STA     bytes23,d
                                  BRC     ADD1        ;s'il y a une retenue, �a veut dire qu'on a un bit = 1

                                  LDA     entier,d
                                  ASLA                ;D�caler les autres bits vers la gauche (si le bit = 0)
                                  STA     entier,d

                                  BR      FORINT      ;On recommence la boucle

                 ADD1:            LDA     entier,d
                                  ASLA                ;D�caler les bits vers la gauche
                                  ADDA    1,d         ;Ajouter bit = 1
                                  STA     entier,d

                                  BR      FORINT
                                  
                 ENDFINT:         LDA     0,i
                                  STA     iter_int,d      ;Remettre it�ration � 0 pour les prochaines boucles
                                  LDA     0,i
                                  STA     bytes23,d       ;Remettre � 0 pour r�utiliser pour partie d�cimale
                          

                 ;     
                 ;  D�BUT EXTRACTION PARTIE D�CIMALE
                 ;
               
                 ;Trouver nombre de bits pour la d�cimale dans la 1ere partie
                 LDA 16,i
                 SUBA 1,i
                 SUBA 8,i
                 SUBA puiss,d
                 STA nbbits1,d
                                                                                                                                        

                 ;V�rifier si on a des bits dans la 1ere partie
                 IFBIT1:          LDA     nbbits1,d
                                  CPA     0,i
                                  BRGT    FORMASK     ;Si on a des bits dans la 1ere partie, on va faire le masque
                                  
                                  ;Sinon, on a pas de bits, donc aller direct � la partie 2
                                  LDA     adresse,d
                                  ADDA    1,i
                                  STA     adresse,d  ;On change l'adresse pour aller au mot 2

                                  LDA adresse,n    ;Saisir le 2e mot                         
                                  STA bytes34,d    ;Mettre dans une nouvelle variable

                                  BR      FORINT2    ;On va � la partie 2 directement

                 ;Cr�er masque pour isoler bits partie 1:
                 FORMASK:         LDA     itermask,d
                                  CPA     nbbits1,d
                                  BREQ    ENDFORMK    ;Si on a fini le masque pour le nb de bits

                                  ADDA    1,i
                                  STA     itermask,d  ;it�rer

                                  LDBYTEA maskpt1,d 
                                  ASLA                ;D�caler les valeurs du masque vers la gauche
                                  ADDA    1,i
                                  STBYTEA maskpt1,d

                                  BR      FORMASK

                 ENDFORMK:        NOP     0,i

                 ;Appliquer masque pour avoir bits de la partie 1
                 LDBYTEA          adresse,n   ;Adresse byte 2 partie 1
                 ANDA             maskpt1,d
                 STA              decimale,d  ;stocker les bits car ils sont les premiers de la partie d�cimale
                 
                 ;Vu que nous avons d�j� certains bits de nos 10 bits de la partie enti�re, on incr�mente l'it�ration
                 LDA              iter_dec,d
                 ADDA             nbbits1,d
                 STA              iter_dec,d

                 ;On peut d�j� changer l'adresse pour prendre le mot de la partie 2
                 LDA              adresse,d
                 ADDA             1,i
                 STA              adresse,d  

                 LDA adresse,n    ;Saisir le 2e mot                         
                 STA bytes34,d    ;Mettre dans une nouvelle variable
                 
                 BR FORPART2      ;Pas besoin de supprimer d'entier, on passe direct � la part2


                 ;Supprimer les bits qui font partie de l'entier
                 FORINT2:         LDA     iterint2,d 
                                  CPA     nbbits1,d 
                                  BREQ    FORPART2    ;Si c'est �gal, on a supprim� tous les bits de l'entier

                                  SUBA    1,i         ;Vu que nbbits1 va �tre n�gatif, on d�cr�mente dans la boucle
                                  STA     iterint2,d    

                                  LDA     bytes34,d   ;Prendre le mot
                                  ASLA                ;D�calage � gauche pour supprimer valeur
                                  STA     bytes34,d   

                                  BR      FORINT2      ;On recommence la boucle

                 ;trouver les bits de la d�cimale dans la partie 2
                 FORPART2:        LDA     iter_dec,d 
                                  CPA     10,d        ;Si on a it�r� 10, on a toute la partie d�cimale
                                  BREQ    ENDFORP2    ;Si on les a tous extrait, on a fini d'extraire la decimale

                                  ADDA    1,i         ;It�rer
                                  STA     iter_dec,d

                                  LDA     bytes34,d   ;Aller � l'adresse qui est toujours �gale au byte 2 de part 1
                                  ASLA
                                  STA     bytes23,d
                                  BRC     ADD1_DEC    ;S'il y a une retenue, le bit est activ� donc on l'ajoute 

                                  ;Sinon, �a veut dire que le bit est un 0, donc on d�cale sans rien ajouter
                                  LDA     decimale,d
                                  ASLA                ;D�caler les autres bits vers la gauche (si le bit = 0)
                                  STA     decimale,d

                                  BR      FORPART2      ;On recommence la boucle

                 ADD1_DEC:        LDA     decimale,d
                                  ASLA                ;D�caler les bits vers la gauche
                                  ADDA    1,d         ;Ajouter bit = 1
                                  STA     decimale,d

                                  BR      FORPART2

                 ENDFORP2:        LDA     0,i
                                  STA     iter_dec,d

                 ;     
                 ;  D�BUT CALCUL PARTIE D�CIMALE
                 ;
               
                 FORDECI:         LDA     iter_dec,d
                                  CPA     10,d
                                  BREQ    ENDFORDC    ;finir boucle

                                  ADDA    1,i
                                  STA     iter_dec,d  ;It�rer

                                  LDA     decimale,d
                                  ASLA
                                  BRC     DECOUI      ;�a veut dire qu'il y a un bit actif

                                  ;sinon on fait juste multiplier numer et denom par 2
                                  LDA     numer,d
                                  ASLA                ;multiplie par 2
                                  STA     numer,d 

                                  LDA     denom,d
                                  ASLA                ;multiplie par 2
                                  STA     denom,d 

                                  BR      FORDECI
                 
                 DECOUI:          LDA     numer,d
                                  ASLA                ;multiplie par 2
                                  ADDA    1,i
                                  STA     numer,d    

                                  LDA     denom,d
                                  ASLA                ;multiplie par 2
                                  STA     denom,d 

                                  BR      FORDECI  

                                  

                 ENDFORDC:        LDA     0,i                             

     
                 ;Afficher la 2e partie de chaque chiffre
                 STRO msgpar2,d
                 DECO adresse,n
                 CHARO '\n',i

                 ;Afficher le signe
                 STRO msgsigne,d
                 DECO signe,d
                 CHARO '\n',i

                 ;Afficher l'exposant
                 STRO msgexpos,d
                 DECO expos,d
                 CHARO '\n',i

                 ;Afficher la puissance
                 STRO msgpuiss,d
                 DECO puiss,d
                 CHARO '\n',i

                 ;Afficher la partie enti�re
                 STRO msgint,d
                 DECO entier,d
                 CHARO '\n',i

                 ;Afficher num�rateur
                 STRO msgnumer,d
                 DECO numer,d
                 CHARO '\n',i

                 ;Afficher d�nominateur
                 STRO msgdenom,d
                 DECO denom,d
                 CHARO '\n',i
                 CHARO '\n',i

                 ;Remettre entier = 1 (bit activ�) pour les prochaines boucles
                 LDA     1,i
                 STA     entier,d

                 ;Tout remettre � zero
                 LDA     0,i
                 STA     decimale,d
                 STA     nbbits1,d         
                 STA     maskpt1,d         
                 STA     itermask,d        
                 STA     iter_dec,d        
                 STA     iterint2,d
                 STA     bytes34,d
                 STA     numer,d
                 LDA     1,i
                 STA     denom,d

                 ;Incr�mentation des valeurs iter et adresse
                 LDA iter,d
                 ADDA 1,i
                 STA iter,d

                 LDA adresse,d
                 ADDA mot,d ;On saute de nouveau de 1 mot pour aller au prochain chiffre
                 STA adresse,d

                 BR FOR

ENDFOR:          BR FIN 

FIN:     STOP

;
;Variables et constantes
;
;T�che 1.1
valid:           .ASCII "Les donn�es ont �t� charg�es avec succ�s!\n\x00"
no_valid:        .ASCII "ERREUR : Les donn�es n'ont pas �t� charg�es!\x00"

;T�che 1.2
nb_val:          .WORD 0
msgnbval:        .ASCII "Nombre de valeurs charg�es : \x00"

;T�che 1.3
iter:            .WORD 1
adresse:         .WORD 0x1004
mot:             .WORD 2 ;On saute de 1 mot
msgadd1:         .ASCII "Chiffre \x00"
msgadd2:         .ASCII " @ \x00"

;T�che 1.4
partie1:         .WORD 0
partie2:         .WORD 0
msgpar1:         .ASCII "    Partie 1       : \x00"
msgpar2:         .ASCII "    Partie 2       : \x00"

;T�che 2.1
signe:           .WORD 0
temp:            .WORD 0
msgsigne:        .ASCII "    Signe          : \x00"

;T�che 2.2
iter_exp:        .WORD 1
expos:           .WORD 0
masque:          .WORD 0x7F80 ;Correspond � 0 11111111 00000000 
msgexpos:        .ASCII "    Exposant       : \x00"

;T�che 2.3
BIAIS:           .EQUATE 127
puiss:           .WORD 0
msgpuiss:        .ASCII "    Puissance      : \x00" 

;T�che 3.1
entier:          .WORD 1     ;Bit activ� de la mantisse
iter_int:        .WORD 0
bytes23:         .WORD 0
msgint:          .ASCII "    Partie enti�re : \x00"

;T�che 4.1
numer:           .WORD 0
denom:           .WORD 1
decimale:        .WORD 0
nbbits1:         .WORD 0
maskpt1:         .BYTE 0
itermask:        .WORD 0
iter_dec:        .WORD 0
iterint2:        .WORD 0
bytes34:         .WORD 0
msgnumer:        .ASCII "    Num�rateur     : \x00"
msgdenom:        .ASCII "    D�nominateur   : \x00"



.END


; ****************************************************************************************************
; FIN DU PROGRAMME PRINCIPAL
; ****************************************************************************************************
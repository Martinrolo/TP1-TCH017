; 
; TCH017 - Projet no1 - Décodeur de float IEEE754
;
; Auteur     : Francis Bourdeau et Iannick Gagnon
; Fichier    : chargeur_donnees.pep
; Version    : A2023
; Desription : Ce programme charge des donn?es en m?moires afin qu'un d?codeur IEEE754 
;              simple précision en fasse la lecture et l'affichage.
;
; Voici la structure de la mémoire : 
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


;Déterminer le nombre de valeurs stockées
LDA              0x1002,d 
STA              nb_val,d
STRO             msgnbval,d
DECO             nb_val,d
CHARO            '\n',i
CHARO            '\n',i


;Boucle principale
FOR:             LDA iter,d
                 CPA nb_val,d 
                 BRGT ENDFOR ;Si l'itération est égale à nb_val, on arrête

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
                 ASRA ;Faire 7 décalages pour avoir dernier bit
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 STA signe,d ;On la stocke, pour l'afficher après la 2e partie du chiffre


                 ;Extraire exposant
                 LDA adresse,n ;Prendre les bits de la 1ere partie
                 ANDA masque,d ;Et binaire pour avoir juste les bits de l'exposant
                 ASRA ;Faire 7 décalages pour avoir la valeur de l'exposant
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 ASRA
                 STA expos,d ;On le stocke, on va l'afficher après le signe plus loin

                 ;Calculer la puissance
                 LDA expos,d
                 SUBA BIAIS,i
                 STA puiss,d

                 ; Calculer la partie entière
                 ;Aller à l'adresse du 2e octet
                 LDA adresse,d
                 ADDA 1,i
                 STA adresse,d            
                 
                 LDA adresse,n    ;Saisir le 2e octet de la 1ere partie + 1er octet de la 2e partie
                 ASLA             ;Le 1er chiffre du 2e octet fait partie de l'exposant, donc on l'enlève
                 STA bytes23,d

                 ;Boucle extraire bits
                 FORINT:          LDA     iter_int,d
                                  CPA     puiss,d     ;On arrête de boucler quand on a tous les bits
                                  BREQ    ENDFINT
                                  
                                  LDA     iter_int,d
                                  ADDA    1,i         ;itérer
                                  STA     iter_int,d

                                  LDA     bytes23,d   ;Charger les bytes 2 et 3 du chiffre
                                  ASLA
                                  STA     bytes23,d
                                  BRC     ADD1        ;s'il y a une retenue, ça veut dire qu'on a un bit = 1

                                  LDA     entier,d
                                  ASLA                ;Décaler les autres bits vers la gauche (si le bit = 0)
                                  STA     entier,d

                                  BR      FORINT      ;On recommence la boucle

                 ADD1:            LDA     entier,d
                                  ASLA                ;Décaler les bits vers la gauche
                                  ADDA    1,d         ;Ajouter bit = 1
                                  STA     entier,d

                                  BR      FORINT
                                  
                 ENDFINT:         LDA     0,i
                                  STA     iter_int,d      ;Remettre itération à 0 pour les prochaines boucles
                               
                                  
                 ;Trouver nombre de bits pour la décimale dans la 1ere partie
                 LDA 16,i
                 SUBA 1,i
                 SUBA 8,i
                 SUBA puiss,d
                 STA nbbits1,d


                 ;Boucle calcul
                 FORDEC:          LDA     iter_dec,d
                                  CPA     10,i        ;Si on a 10 chiffres de la mantisse, on arrête
                                  BREQ    ENDFDEC
                                  
                                  LDA     iter_dec,d
                                  ADDA    1,d         ;itérer
                                  STA     iter_dec,d
                                  
                                  ;Choisir l'adresse
                                  LDA nbbits1,d
                                  BRLT


                 ENDFDEC:         

                 
         

     
                 ;Afficher la 2e partie de chaque chiffre
                 LDA adresse,d
                 ADDA 1,d ;Incrémenter adresse de 1 mot (+2 octets) pour avoir la 2e partie
                 STA adresse,d

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

                 ;Afficher la partie entière
                 STRO msgint,d
                 DECO entier,d
                 CHARO '\n',i
                 CHARO '\n',i

                 ;Remettre entier = 1 (bit activé) pour les prochaines boucles
                 LDA     1,i
                 STA     entier,d

                 ;Incrémentation des valeurs iter et adresse
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
;Tâche 1.1
valid:           .ASCII "Les données ont été chargées avec succès!\n\x00"
no_valid:        .ASCII "ERREUR : Les données n'ont pas été chargées!\x00"

;Tâche 1.2
nb_val:          .WORD 0
msgnbval:        .ASCII "Nombre de valeurs chargées : \x00"

;Tâche 1.3
iter:            .WORD 1
adresse:         .WORD 0x1004
mot:             .WORD 2 ;On saute de 1 mot
msgadd1:         .ASCII "Chiffre \x00"
msgadd2:         .ASCII " @ \x00"

;Tâche 1.4
partie1:         .WORD 0
partie2:         .WORD 0
msgpar1:         .ASCII "    Partie 1       : \x00"
msgpar2:         .ASCII "    Partie 2       : \x00"

;Tâche 2.1
signe:           .WORD 0
temp:            .WORD 0
msgsigne:        .ASCII "    Signe          : \x00"

;Tâche 2.2
iter_exp:        .WORD 1
expos:           .WORD 0
masque:          .WORD 0x7F80 ;Correspond à 0 11111111 00000000 
msgexpos:        .ASCII "    Exposant       : \x00"

;Tâche 2.3
BIAIS:           .EQUATE 127
puiss:           .WORD 0
msgpuiss:        .ASCII "    Puissance      : \x00" 

;Tâche 3.1
entier:          .WORD 1     ;Bit activé de la mantisse
iter_int:        .WORD 0
bytes23:         .WORD 0
msgint:          .ASCII "    Partie entière : \x00"

;Tâche 4.1
numer:           .WORD 0
denom:           .WORD 0
iter_dec:        .WORD 0
nbbits1:         .WORD 0



.END


; ****************************************************************************************************
; FIN DU PROGRAMME PRINCIPAL
; ****************************************************************************************************
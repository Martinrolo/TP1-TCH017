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

; ?CRIVEZ VOTRE SOLUTION ICI

; ****************************************************************************************************
; FIN DU PROGRAMME PRINCIPAL
; ****************************************************************************************************
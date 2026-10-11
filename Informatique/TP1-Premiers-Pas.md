---
title: "Synthèse TP1 — Premiers pas en assembleur 68000"
matiere: "Informatique"
date: "2026-10-11"
tags: [fiche, revision, informatique, assembleur, 68000, tp, epita]
source: "David Bouchet – Architecture des ordinateurs – EPITA – S3 (TP1)"
---

# 🛠️ TP1 — Premiers Pas en Assembleur 68000

> **Matière :** Informatique (Architecture des ordinateurs EPITA S3)  
> **Auteur du cours :** David Bouchet  
> **Fichiers sources :** `TP_01.pdf` & `TP_01_Corrige.pdf`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Structure minimale d'un programme exécutable :**
   - Le vecteur de reset initial à l'adresse `$4` contient l'adresse du point d'entrée (`Main`).
   - Le code utilisateur commence classiquement à `$500`.
   - Fin d'exécution contrôlée via l'instruction `illegal`.
2. **Fonctionnement précis des Flags (CCR) lors d'une addition :**
   - **$Z$ (Zero) :** vaut $1$ si le résultat tronqué à la taille de l'opération est $0$.
   - **$N$ (Negative) :** recopie du bit de poids fort (MSB) du résultat tronqué.
   - **$C$ (Carry) :** retenue non signée (dépassement hors de la taille de calcul).
   - **$V$ (Overflow) :** débordement arithmétique signé ($\text{Pos} + \text{Pos} = \text{Nég}$ ou $\text{Nég} + \text{Nég} = \text{Pos}$).
   - **$X$ (eXtend) :** recopie du flag $C$ sur les opérations arithmétiques pour le chaînage multi-précision.
3. **Calcul multi-précision (128 bits) :**
   - La première addition de poids faible utilise `ADD.L` (génère la retenue dans $X$ et $C$).
   - Les blocs suivants utilisent obligatoirement `ADDX.L` (qui ajoute $X$).
4. **Manipulation de bits par rotations :**
   - `ROL` / `ROR` : rotations circulaires sur la taille spécifiée (`.B`, `.W`, `.L`).
   - `SWAP` : échange direct des deux mots de 16 bits de poids fort et de poids faible d'un registre de donnée (taille 32 bits fixe).

---

## 🏗️ 1. Structure de base d'un programme 68000

```asm
                org     $4              ; Vecteur n°1 (PC initial au Reset)
Vector_001      dc.l    Main            ; Contient l'adresse de départ

                org     $500            ; Début de la mémoire programme utile
Main:
                ; ... Instructions ...
                illegal                 ; Arrêt / Exception pour le débogueur
```

> [!note]
> - `ORG` est une directive d'assemblage (indique où implanter le binaire).
> - `DC.L` réserve 32 bits et y place la valeur de l'étiquette `Main`.
> - Un registre non modifié conserve ses octets de poids fort lors d'un calcul en `.B` ou `.W`.

---

## 🧠 2. Analyse détaillée des Flags CCR (Étape 5)

Règles de détermination manuelle sur une opération $A + B$ de taille $T$ :

| Opération | Résultat mathématique | Troncature (Taille) | N | Z | V | C | Justification |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **8 bits** : `$B4 + $4C` | `$0100` | `$00` | `0` | `1` | `0` | `1` | Résultat nul $\to Z=1$. Retenue sortante $\to C=1$. Signes initiaux différents (nég + pos) $\to V=0$. |
| **16 bits** : `$B4 + $4C` | `$0100` | `$0100` | `0` | `0` | `0` | `0` | `$00B4 + $004C = $0100$. Tient sur 16 bits, pas de retenue, non nul. |
| **16 bits** : `$4AC9 + $D841` | `$1230A` | `$230A` | `0` | `0` | `0` | `1` | Retenue générée $\to C=1$. Positif + Négatif $\to V=0$. Bit 15 nul $\to N=0$. |
| **32 bits** : `$FFFFFFFF + $15` | `$100000014` | `$00000014` | `0` | `0` | `0` | `1` | Retenue générée $\to C=1$. Pas d'overflow signé $\to V=0$. |

> [!important]
> **Formule du flag V (Overflow signé) :**
> Si $A$ et $B$ ont le même bit de signe mais que le résultat a un bit de signe opposé, alors $V = 1$. Sinon $V = 0$.

---

## ⚡ 3. Addition Multi-Précision 128 bits (Étape 6)

Soient deux nombres de 128 bits :
- Premier nombre : `D3:D2:D1:D0` (`D0` = 32 bits de poids faible)
- Deuxième nombre : `D7:D6:D5:D4` (`D4` = 32 bits de poids faible)

```asm
; Addition multi-précision :
add.l   d4,d0       ; D4 + D0 -> D0  (génère C0 -> X)
addx.l  d5,d1       ; D5 + D1 + X -> D1 (génère C1 -> X)
addx.l  d6,d2       ; D6 + D2 + X -> D2 (génère C2 -> X)
addx.l  d7,d3       ; D7 + D3 + X -> D3 (génère C3 -> X)
```

> [!warning]
> Ne jamais utiliser d'instruction intercalée modifiant le flag $X$ entre deux `ADDX` (ex: `MOVE` ne touche pas à $X$, mais des opérations arithmétiques ou de test peuvent le perturber).

---

## 🔄 4. Manipulation de registres par ROL / ROR / SWAP (Étape 7)

Initialisation : `D1 = $76543210` (un quartet par chiffre).

### Cas 1 : Obtenir `$76543120` (inversion des quartets 1 et 2)
```asm
ror.w   #4,d1       ; D1 = $7654 0321  (rotation du mot bas)
ror.b   #4,d1       ; D1 = $7654 0312  (rotation de l'octet bas)
rol.w   #4,d1       ; D1 = $7654 3120  (recalage du mot bas)
```

### Cas 2 : Obtenir `$54231067`
```asm
ror.l   #8,d1       ; D1 = $1076 5432
ror.b   #4,d1       ; D1 = $1076 5423
swap    d1          ; D1 = $5423 1076
ror.b   #4,d1       ; D1 = $5423 1067
```

---

## ❓ Questions pièges & Révision TP1

1. **Pourquoi l'adresse du vecteur de reset est-elle en `$4` et pas `$0` ?**
   - À l'adresse `$0`, le 68000 lit sur 32 bits le pointeur initial de pile superviseur (`SSP`). C'est à l'adresse `$4` qu'il lit le compteur de programme initial (`PC`).
2. **Que deviennent les 24 bits de poids fort de `D0` après un `ADD.B #1, D0` ?**
   - Ils restent strictement intacts et inchangés !
3. **Quelle est la différence entre `ADD` et `ADDX` ?**
   - `ADD` calcule $\text{Src} + \text{Dst}$. `ADDX` calcule $\text{Src} + \text{Dst} + X$.

---
*Fiche suivante : [[TP2-Modes-Adressage]]*  
*Index général : [[Informatique/README]]*

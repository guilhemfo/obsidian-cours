---
title: "Synthèse TP2 — Les modes d'adressage du 68000"
matiere: "Informatique"
date: "2026-10-11"
tags: [fiche, revision, informatique, assembleur, 68000, tp, adressage, epita]
source: "David Bouchet – Architecture des ordinateurs – EPITA – S3 (TP2)"
---

# 🎯 TP2 — Les Modes d'Adressage du 68000

> **Matière :** Informatique (Architecture des ordinateurs EPITA S3)  
> **Auteur du cours :** David Bouchet  
> **Fichiers sources :** `TP_02.pdf` & `TP_02_Corrige.pdf`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Calcul de l'Adresse Effective ($\langle ea \rangle$) :**
   - **Indirect simple :** `(An)` $\implies \langle ea \rangle = An$.
   - **Post-incrémenté :** `(An)+` $\implies \langle ea \rangle = An$, puis $An \leftarrow An + \text{taille}$ ($1, 2$ ou $4$).
   - **Pré-décrémenté :** `-(An)` $\implies An \leftarrow An - \text{taille}$, puis $\langle ea \rangle = An$.
   - **Indirect avec déplacement :** `d16(An)` $\implies \langle ea \rangle = An + d16$ ($d16 \in [-32768, 32767]$ signé).
   - **Indirect avec déplacement et index :** `d8(An, Xn)` $\implies \langle ea \rangle = An + d8 + Xn$ ($d8 \in [-128, 127]$ signé, index sur 16 ou 32 bits signé).
2. **Erreur d'adresse impaire (Address Error) :**
   - Les accès en mot (`.W`) et en mot long (`.L`) doivent **impérativement se faire à une adresse paire**.
   - Seuls les accès octet (`.B`) sont permis à une adresse impaire.
   - Cette erreur se produit **au moment de l'exécution** (erreur dynamique), elle n'est pas détectée lors de l'assemblage !
3. **Validité des instructions :**
   - Une donnée immédiate (`#<data>`) ne peut **jamais** être une destination.
   - `An` ne peut pas être destination d'un simple `MOVE` (utiliser `MOVEA` ou `LEA`).
   - `An` n'accepte pas l'extension `.B` (uniquement `.W` ou `.L`).
4. **Décomposition des modes d'adressage :** Tout mode complexe peut être décomposé en opérations élémentaires (`ADDA`, `SUBA`, `(An)`).

---

## 🔍 1. Les 4 causes d'invalidité d'une instruction (Étape 2)

| Cause | Explication | Exemple invalide |
| :--- | :--- | :--- |
| **Mode inexistant** | Syntaxe non reconnue | `MOVE.W D0, +(A1)` (la post-décrémentation n'existe pas) |
| **Dépassement de capacité** | Déplacement ou immédiat hors bornes | `MOVE.B $90(A1, D0.W), D2` ($d8 = \$90 = 144 > 127$) |
| **Mode interdit pour l'instruction** | L'opérande viole les restrictions du processeur | `MOVE.W D0, #12` (destination immédiate interdite) |
| **Extension de taille interdite** | Taille non supportée pour cette opération | `ADDA.B D0, A1` (les registres d'adresse n'acceptent que `.W` ou `.L`) |

---

## 🧮 2. Calculs d'adresses effectives & Cas pièges (Étape 4)

Soit l'état initial des registres :
- `A0 = $00005000`
- `A1 = $00005008`
- `A2 = $00005010`
- `D0 = $00000005`
- `D1 = $FFFFFFE0` (représente $-32$ en complément à deux)
- `D2 = $00000025`

### Instruction 1 : `MOVE.W 4(A1), -(A2)`
- **Source :** `4(A1)` $\implies \langle ea \rangle = A1 + 4 = \$5008 + 4 = \mathbf{\$500C}$.
- **Destination :** `-(A2)` $\implies A2$ pré-décrémenté de $2$ octets (taille `.W`) $\implies \langle ea \rangle = \$5010 - 2 = \mathbf{\$500E}$.

### Instruction 2 : `MOVE.L (A0)+, $22(A1, D1.L)`
- **Source :** `(A0)+` $\implies \langle ea \rangle = A0 = \mathbf{\$5000}$ (puis $A0$ devient $\$5004$).
- **Destination :** `d8(A1, D1.L)` :
  - $D1.L = \$FFFFFFE0 = -32 = -\$20$.
  - $\langle ea \rangle = A1 + \$22 + D1.L = \$5008 + \$22 - \$20 = \$5008 + 2 = \mathbf{\$500A}$.

### Instruction 3 : `MOVE.L $11(A1, D0.W), -$1A(A0, D2.L)`
- **Source :** $\langle ea \rangle = A1 + \$11 + D0.W = \$5008 + \$11 + 5 = \$5008 + \$16 = \mathbf{\$501E}$.
- **Destination :** $\langle ea \rangle = A0 - \$1A + D2.L = \$5000 - \$1A + \$25 = \$5000 + \$0B = \mathbf{\$500B}$.

> [!danger]
> **Erreur Fatale d'exécution :**  
> L'adresse de destination calculée est **`$500B`** (impaire), alors que l'opération se fait en mot long **`.L`**. Le 68000 déclenche une exception **Address Error** qui stoppe le programme.

---

## 🧩 3. Décomposition des modes d'adressage complexes (Étape 6)

Comprendre la décomposition interne permet d'assimiler ce que fait le processeur en cycle d'horloge :

### Post-incrémentation : `MOVE.B #$51, (A0)+`
```asm
; Équivaut à :
move.b  #$51,(a0)       ; Accès mémoire
adda.l  #1,a0           ; Incrémentation du pointeur après accès
```

### Pré-décrémentation : `MOVE.W #$4A6B, -(A2)`
```asm
; Équivaut à :
suba.l  #2,a2           ; Décrémentation du pointeur AVANT accès (.W = 2 octets)
move.w  #$4A6B,(a2)     ; Accès mémoire
```

### Déplacement : `MOVE.B #$FF, $10(A3)`
```asm
; Équivaut à :
adda.w  #$10,a3         ; Calcul temporaire du décalage
move.b  #$FF,(a3)       ; Écriture
suba.l  #$10,a3         ; Restauration du registre A3
```

### Déplacement et Index : `MOVE.W #$2233, -1(A4, D1.L)`
```asm
; Équivaut à :
suba.w  #1,a4           ; Prise en compte de d8
adda.l  d1,a4           ; Prise en compte de l'index
move.w  #$2233,(a4)     ; Écriture
suba.l  d1,a4           ; Restauration
adda.w  #1,a4           ; Restauration
```

---

## ⚡ 4. ADD vs ADDA vs ADDI vs ADDQ (Étape 5)

| Mnémonique | Rôle & Restrictions | Drapeaux (CCR) |
| :--- | :--- | :--- |
| **`ADD`** | Addition classique. Exige qu'au moins un des opérandes soit un registre de donnée ($Dn$). | Modifie tous les flags ($N, Z, V, C, X$). |
| **`ADDA`** | Addition avec un **registre d'adresse en destination** (`An`). Tailles : `.W` ou `.L` uniquement. | **Ne modifie AUCUN flag** ! |
| **`ADDI`** | Addition immédiate avec mémoire ou registre (`#data, <ea>`). | Modifie tous les flags. |
| **`ADDQ`** | Addition rapide d'une valeur immédiate entre $1$ et $8$ (`#1` à `#8`). Optimisé en taille machine. | Modifie tous les flags (sauf si destination est $An$). |

---

## ❓ Questions de Révision TP2

1. **Pourquoi `MOVE.W (A0), A1` est-elle interdite ?**
   - Parce que la destination est un registre d'adresse. Il faut écrire `MOVEA.W (A0), A1`.
2. **Que vaut le registre $A0$ après `MOVE.L (A0)+, D0` si $A0$ valait initialement `$1000` ?**
   - $A0 = \$1004$ (l'instruction est en mot long `.L`, donc incrémentation de 4).
3. **Quelle instruction génère une erreur d'adresse impaire ?**
   - Tout accès mémoire en `.W` ou `.L` dont l'adresse se termine par un bit 0 à 1 (adresse impaire, ex: `$2001`, `$500B`).

---
*Fiche précédente : [[TP1-Premiers-Pas]]* | *Fiche suivante : [[TP3-Branchements-Boucles]]*  
*Index général : [[Informatique/README]]*

---
title: "Initiation à l'Assembleur 68000"
matiere: "Informatique"
date: "2026-10-11"
tags: [fiche, revision, informatique, assembleur, 68000, architecture, EPITA]
source: "David Bouchet – Architecture des ordinateurs – EPITA – S3"
---

# 💻 Initiation à l'Assembleur 68000

> **Matière :** Informatique (Architecture des ordinateurs) | **Date :** 11/10/2026  
> **Cours :** David Bouchet – EPITA S3

---

## 🎯 Points Clés

- Le **langage machine** = seul langage exécutable par un microprocesseur (codes binaires)
- Le **langage assembleur** = représentation humaine du langage machine (mnémoniques ↔ binaire)
- Le **programme assembleur** = traduit l'assembleur en code machine (= compilation)
- Le **68000** possède un bus d'adresse de **24 bits** (16 Mio adressables) et un bus de données de **16 bits**
- Une instruction est codée sur **minimum 2 octets** (1 mot 16 bits), **maximum 10 octets** (5 mots 16 bits)

---

## 📖 Résumé du Cours

### I. Structure d'un code source

Une instruction assembleur est composée de **4 champs** :

| Champ | Rôle | Exemple |
|-------|------|---------|
| **Étiquette** | Alias d'une adresse (commence en colonne 1) | `START`, `LOOP` |
| **Mnémonique** | Nom de l'instruction ou directive (+ extension `.B`/`.W`/`.L`) | `MOVE.B`, `BNE` |
| **Opérande** | Source et/ou destination (`source, destination`) | `D0,D1` |
| **Commentaire** | Débute par `;`, ignoré à l'assemblage | `; D0 → D1` |

> [!note]
> Extensions de taille : `.B` = 8 bits (Byte) | `.W` = 16 bits (Word) | `.L` = 32 bits (Long)

---

### II. Architecture du 68000

#### Registres

| Type | Registres | Taille | Usage |
|------|-----------|--------|-------|
| **Données** | D0 – D7 | 32 bits | Manipulation de données (accès .B/.W/.L) |
| **Adresses** | A0 – A6 | 32 bits | Stockage d'adresses (accès .W/.L) |
| **Pointeur de pile** | A7 (SSP/USP) | 32 bits | Sommet de pile (double selon le mode) |
| **Compteur programme** | PC | 32 bits | Adresse prochaine instruction (auto) |
| **Registre d'état** | SR / CCR | 16 bits / 8 bits | Flags d'état |

#### Flags du registre CCR (bits de poids faible du SR)

| Flag | Nom | Signification |
|------|-----|--------------|
| **C** | Carry | Retenue (dépassement non signé) |
| **V** | Overflow | Dépassement signé |
| **Z** | Zero | Résultat nul |
| **N** | Negative | Résultat négatif (bit de signe) |
| **X** | Extend | Identique à C pour la plupart des instructions |

> [!important]
> **Modes de fonctionnement :**
> - **Mode Superviseur** : accès complet, toutes les instructions, utilisé par l'OS
> - **Mode Utilisateur** : instructions privilégiées interdites, utilisé par les applications

---

### III. Directives d'assemblage

> [!note]
> Les directives **ne génèrent pas de code machine** — elles donnent des instructions à l'assembleur.

| Directive | Rôle | Exemple |
|-----------|------|---------|
| `ORG <adresse>` | Définit l'adresse de chargement en mémoire | `ORG $2000` |
| `EQU <valeur>` | Attribue une valeur à une étiquette (constante) | `START EQU $1000` |
| `DC.B/W/L` | Définit des constantes en mémoire | `DC.B 10,$7A,"Hello"` |
| `DS.B/W/L <n>` | Réserve n emplacements mémoire | `DS.W 3` (= 6 octets) |

---

### IV. Modes d'adressage

#### Modes sans emplacement mémoire

| Mode | Syntaxe | Adresse effective | Exemple |
|------|---------|-------------------|---------|
| Direct registre de données | `Dn` | Registre Dn | `MOVE.B D0,D1` |
| Direct registre d'adresse | `An` | Registre An | `MOVE.W A0,D0` |
| Immédiat | `#<data>` | N/A (dans l'instruction) | `MOVE.L #$100A,D0` |

#### Modes avec emplacement mémoire

| Mode | Syntaxe | Calcul de l'adresse effective |
|------|---------|-------------------------------|
| Indirect | `(An)` | `ea = An` |
| Indirect + post-incrément | `(An)+` | `ea = An` ; puis `An += 1/2/4` |
| Indirect + pré-décrément | `-(An)` | `An -= 1/2/4` ; puis `ea = An` |
| Indirect + déplacement | `d16(An)` | `ea = An + d16` (d16 sur 16 bits signés) |
| Indirect + déplacement + index | `d8(An,Xn)` | `ea = An + d8 + Xn` (d8 sur 8 bits signés) |
| Relatif PC + déplacement | `<ea>(PC)` | `ea = PC + d16` |
| Absolu long | `$adresse` ou `(xxx).L` | Adresse sur 32 bits |
| Absolu court | `(xxx).W` | Adresse sur 16 bits (plus rapide) |

> [!tip]
> `(An)+` et `-(An)` sont parfaits pour parcourir des tableaux. Le sens de la variation dépend de l'extension (`.B` = ±1, `.W` = ±2, `.L` = ±4).

---

### V. Branchements

#### Branchements inconditionnels
- `BRA <etiquette>` — saut inconditionnel relatif
- `JMP <ea>` — saut inconditionnel absolu

#### Branchements conditionnels

| Instruction | Condition |
|-------------|-----------|
| `BEQ` | Z = 1 (égal) |
| `BNE` | Z = 0 (non égal) |
| `BCC` / `BCS` | C = 0 / C = 1 |
| `BPL` / `BMI` | N = 0 / N = 1 |
| `BVC` / `BVS` | V = 0 / V = 1 |
| `BGT`, `BGE`, `BLT`, `BLE` | Comparaisons **signées** |
| `BHI`, `BHS`, `BLO`, `BLS` | Comparaisons **non signées** |

#### Boucle avec DBRA
```asm
MOVEQ #9,D0      ; D0 = compteur (10 itérations)
LOOP  ...        ; corps de la boucle
      DBRA D0,LOOP  ; D0-- ; si D0 ≠ -1 → LOOP
```
> `DBRA` = décrément et branchement si ≠ -1 (≡ `for i from N downto 0`)

---

### VI. La Pile

- Zone mémoire **LIFO** (Last In First Out)
- **A7** = pointeur de pile (SSP en mode superviseur, USP en mode utilisateur)
- Seuls des **mots (16 bits)** et **mots longs (32 bits)** peuvent être empilés (jamais d'octets)

```
Empiler  : -(A7)   → A7 décrémenté PUIS écriture
Dépiler  : (A7)+   → lecture PUIS A7 incrémenté
```

#### MOVEM — transfert multiple de registres
```asm
MOVEM.L D1-D3/A4/A5,-(A7)   ; Empile A5, A4, D3, D2, D1 (ordre inversé)
MOVEM.L (A7)+,D1-D3/A4/A5   ; Dépile D1, D2, D3, A4, A5 (ordre classique)
```

---

### VII. Sous-programmes

| Instruction | Rôle |
|-------------|------|
| `JSR <ea>` | Empile l'adresse de retour + saut au sous-programme |
| `BSR <etiquette>` | Idem JSR (relative) |
| `RTS` | Dépile l'adresse de retour + saut (retour) |

> [!important]
> `JSR`/`BSR` empile automatiquement **l'adresse de l'instruction suivante** sur 32 bits.  
> `RTS` la dépile et la charge dans le PC.

---

### VIII. Principales instructions

#### Mouvements de données
| Instruction | Opération |
|-------------|-----------|
| `MOVE` | source → destination |
| `MOVEA` | source → registre d'adresse |
| `MOVEQ` | donnée immédiate 8 bits → Dn (étendue signe sur 32 bits) |
| `MOVEM` | liste de registres ↔ mémoire |
| `LEA` | adresse effective → registre d'adresse |

#### Arithmétique
| Opération | Instructions |
|-----------|-------------|
| Addition | `ADD`, `ADDA`, `ADDI`, `ADDQ`, `ADDX` |
| Soustraction | `SUB`, `SUBA`, `SUBI`, `SUBQ`, `SUBX` |
| Multiplication | `MULS` (signée), `MULU` (non signée) |
| Division | `DIVS` (signée), `DIVU` (non signée) → quotient (bits 0-15), reste (bits 16-31) |
| Divers | `CLR` (mise à 0), `EXT` (extension de signe), `NEG` (négation) |

#### Logique & Bits
| Catégorie | Instructions |
|-----------|-------------|
| Logique | `AND`, `ANDI`, `OR`, `ORI`, `EOR`, `EORI`, `NOT` |
| Décalages | `ASL/ASR` (arithmétique), `LSL/LSR` (logique), `ROL/ROR` (rotation), `ROXL/ROXR` (rotation avec X) |
| Manipulation de bits | `BTST`, `BCLR`, `BSET`, `BCHG` |

#### Tests & Comparaisons
| Instruction | Opération | Résultat |
|-------------|-----------|---------|
| `TST` | teste l'opérande | N, Z mis à jour |
| `CMP` | Dst - Src | N, Z, V, C mis à jour (Dst inchangé) |
| `CMPA` | comparaison avec registre d'adresse | — |
| `CMPI` | comparaison avec immédiat | — |

---

## 🧠 À Retenir Absolument

> [!important]
> **Règle d'or** : Dans `MOVE source, destination` → **gauche = source, droite = destination**
>
> **Accès mémoire** : les mots (16 bits) et mots longs (32 bits) doivent être à des **adresses paires**
>
> **`(An)+` vs `-(An)`** :
> - `(An)+` : accède PUIS incrémente (post)
> - `-(An)` : décrémente PUIS accède (pré)
>
> **Pile** : grandit vers les adresses **décroissantes** (empiler = décrémenter A7)

---

## 📝 Exemples Clés

```asm
; Modes d'adressage
MOVE.L #$AABBCCDD,D1    ; Immédiat : D1 = $AABBCCDD
MOVE.W (A0),D2          ; Indirect : D2.W = mem[A0]
MOVE.B (A1)+,D0         ; Post-inc : D0.B = mem[A1] ; A1++
MOVE.W -(A2),D0         ; Pré-dec  : A2 -= 2 ; D0.W = mem[A2]
MOVE.B -5(A1),D0        ; Déplacement : D0.B = mem[A1 - 5]
MOVE.B 2(A1,D3.W),D0    ; Idx+Dépl : D0.B = mem[A1 + D3.W + 2]

; Boucle classique
      MOVEQ #4,D0        ; 5 itérations (4..0)
LOOP  ADD.L D1,D2
      DBRA D0,LOOP

; Sous-programme
      JSR MonRoutine     ; empile PC+n, saute à MonRoutine
      ...
MonRoutine
      MOVEM.L D1-D3,-(A7)  ; sauvegarde registres
      ...
      MOVEM.L (A7)+,D1-D3  ; restaure registres
      RTS                   ; retour
```

---

## ❓ Questions de Révision

1. Quelle est la différence entre une **instruction** et une **directive d'assemblage** ?
2. Donner la valeur de D1 après `MOVE.W D0,D1` si D0 = `$11223344` et D1 = `$AABBCCDD`.
3. Qu'est-ce que l'**adresse effective** ? Donner 3 exemples de modes d'adressage différents.
4. Expliquer la différence entre `(A0)+` et `-(A0)`.
5. Que fait `DBRA D0,LOOP` exactement ? Combien d'itérations si D0 = 4 au départ ?
6. Comment `JSR` et `RTS` utilisent-ils la pile ?
7. Quel flag vérifier pour savoir si une addition de deux entiers **signés** a débordé ?
8. Quelle est la différence entre `MULS` et `MULU` ? Où trouve-t-on quotient et reste après `DIVS` ?
9. En quoi `MOVEM.L D0-D3,-(A7)` diffère-t-il de `MOVEM.L D0-D3,(A7)` ?
10. Pourquoi les accès mémoire en `.W` et `.L` exigent-ils des **adresses paires** ?

---

## 🔗 Liens

- [[Bienvenue]]
- [[Informatique/README]]

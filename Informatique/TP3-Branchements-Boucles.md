---
title: "Synthèse TP3 — Branchements, Tests et Boucles"
matiere: "Informatique"
date: "2026-10-11"
tags: [fiche, revision, informatique, assembleur, 68000, tp, boucles, chaines, epita]
source: "David Bouchet – Architecture des ordinateurs – EPITA – S3 (TP3)"
---

# 🔁 TP3 — Branchements, Tests et Algorithmes Classiques

> **Matière :** Informatique (Architecture des ordinateurs EPITA S3)  
> **Auteur du cours :** David Bouchet  
> **Fichiers sources :** `TP_03.pdf` & `TP_03_Corrige.pdf`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Mécanisme des instructions de test :**
   - **`TST <ea>`** : compare implicitement l'opérande à zéro. Met à jour $N$ et $Z$ ($V=0, C=0$).
   - **`MOVE` vers un registre** : **met également à jour les flags $N$ et $Z$** comme un `TST` ! Inutile de faire un `TST` juste après un `MOVE`.
   - **`CMP Src, Dst`** : effectue l'opération fictive $\text{Dst} - \text{Src}$ sans modifier la destination. Met à jour $N, Z, V, C$.
2. **Sauts conditionnels signés vs non signés :**
   - **Comparaisons signées :** `BGT` ($>$), `BGE` ($\ge$), `BLT` ($<$), `BLE` ($\le$).
   - **Comparaisons non signées :** `BHI` ($>$), `BHS` ($\ge$), `BLO` ($<$), `BLS` ($\le$).
   - **Tests de base :** `BEQ` ($Z=1$), `BNE` ($Z=0$), `BMI` ($N=1$), `BPL` ($N=0$).
3. **Fonctionnement exact de `DBRA Dn, Label` (ou `DBF`) :**
   - Décrémente d'abord le mot de 16 bits de poids faible : $Dn.W \leftarrow Dn.W - 1$.
   - Si $Dn.W \neq -1$ (soit $Dn.W \neq \$FFFF$), saute à `Label`.
   - Si $Dn.W = -1$, la boucle se termine et passe à l'instruction suivante.
   - **Conséquence directe :** Si $Dn$ est initialisé à $N$, la boucle s'exécute **$N+1$ fois** !
4. **Algorithmes standards sur les chaînes de caractères (ASCIIZ terminées par 0) :**
   - Parcours par pointeur auto-incrémenté : `move.b (a0)+, d1`.
   - Test de terminaison immédiat via `BEQ`.

---

## 🔄 1. Analyse des 4 types de boucles (Étape 1)

### Boucle 1 : Décrémentation avec contrôle de sous-taille
```asm
loop1   addq.l  #1,d1
        subq.w  #1,d0           ; Seul le mot D0.W est décrémenté !
        bne     loop1
```
- Initialisation : `D0 = $80000007` $\implies D0.W = 7$.
- Seul $D0.W$ est affecté par `SUBQ.W`. Les bits de poids fort `$8000` ne bougent pas.
- La boucle tourne $7$ fois $\implies \mathbf{D1 = 7}$.

### Boucle 2 : Décrémentation par pas de 2 sur octet
```asm
loop2   addq.l  #1,d2
        subq.b  #2,d0           ; Décrémentation de 2 sur D0.B
        bne     loop2
```
- Initialisation : `D0 = $00FE2310` $\implies D0.B = \$10 = 16$.
- Le compteur fait $16 \to 14 \to \dots \to 0$ (par pas de 2) $\implies$ $8$ itérations $\implies \mathbf{D2 = 8}$.

### Boucle 3 : La boucle `DBRA` (Attention au piège classique)
```asm
        clr.l   d3
        moveq.l #125,d0
loop3   addq.l  #1,d3
        dbra    d0,loop3
```
- $D0.W$ part de $125$ et boucle tant que $D0.W \neq -1$.
- Nombre d'itérations = $125 - (-1) = \mathbf{126}$ itérations $\implies \mathbf{D3 = 126}$.

### Boucle 4 : Boucle avec `CMP` en fin de boucle
```asm
        clr.l   d4
        moveq.l #10,d0
loop4   addq.l  #1,d4
        addq.l  #1,d0
        cmpi.l  #30,d0
        bne     loop4
```
- $D0$ varie de $10$ à $30$ $\implies 20$ itérations $\implies \mathbf{D4 = 20}$.

---

## 🌲 2. Traduction de conditions `IF / ELSE IF / ELSE` (Étape 2)

Analyse du graphe conditionnel basé sur `VALUE` dans `D1.B` :
```text
Si D1.B == 0:
    D0 = 200
Sinon:
    Si D1.B < 0:
        D0 = 800
    Sinon:
        Si D1.B < $61 (97 en décimal):
            D0 = 600
        Sinon:
            D0 = 400
```

Résultats d'exécution :
- `VALUE = 18` $\implies 18 \neq 0$, positif, $18 < 97 \implies \mathbf{D0 = 600}$.
- `VALUE = -5` $\implies$ négatif $\implies \mathbf{D0 = 800}$.
- `VALUE = 0` $\implies$ nul $\implies \mathbf{D0 = 200}$.
- `VALUE = 96` $\implies 96 < 97 \implies \mathbf{D0 = 600}$.

---

## 💻 3. Algorithmes Types à connaître par cœur pour les partiels

### 1. Valeur Absolue (`Abs`) — Étape 3
```asm
; Entrée : D0.L (entier signé)
; Sortie : D0.L = |D0.L|
Abs:
        tst.l   d0              ; Test du signe (met à jour N)
        bpl     quit            ; Si N=0 (positif ou nul), on saute
        neg.l   d0              ; Si N=1 (négatif) : 0 - D0 -> D0
quit:
        illegal
```

### 2. Longueur d'une chaîne (`StrLen`) — Étape 4
```asm
; Entrée : A0 pointe sur la chaîne terminée par 0
; Sortie : D0.L = longueur
StrLen:
        clr.l   d0              ; Compteur = 0
loop:
        tst.b   (a0)+           ; Test du caractère ET avance du pointeur
        beq     quit            ; Caractère nul ? Fin de chaîne
        addq.l  #1,d0           ; Sinon compteur++
        bra     loop
quit:
        illegal
```

### 3. Compter les occurrences d'un caractère (ex: Espaces) — Étape 5
```asm
; Entrée : A0 pointe sur la chaîne terminée par 0
; Sortie : D0.L = nombre d'espaces
SpaceCount:
        clr.l   d0
loop:
        move.b  (a0)+,d1        ; Charge le caractère (met aussi à jour Z !)
        beq     quit            ; Fin si fin de chaîne (d1 == 0)
        cmp.b   #' ',d1         ; Comparer au caractère espace
        bne     loop            ; Différent ? Caractère suivant
        addq.l  #1,d0           ; Égal ? Incrémente le compteur
        bra     loop
quit:
        illegal
```

### 4. Filtrer un intervalle (ex: Compter les lettres minuscules `'a'` à `'z'`) — Étape 6
```asm
; Entrée : A0 pointe sur la chaîne
; Sortie : D0.L = nombre de minuscules
LowerCount:
        clr.l   d0
loop:
        move.b  (a0)+,d1
        beq     quit            ; Fin de chaîne
        cmp.b   #'a',d1
        blo     loop            ; Si ASCII < 'a' (non signé), pas une minuscule
        cmp.b   #'z',d1
        bhi     loop            ; Si ASCII > 'z' (non signé), pas une minuscule
        addq.l  #1,d0           ; Dans ['a', 'z'] -> compteur++
        bra     loop
quit:
        illegal
```

> [!important]
> Pour tester des codes de caractères ASCII, on utilise toujours des comparaisons **non signées** (`BLO` et `BHI`), car un caractère est une valeur comprise entre $0$ et $255$.

---

## ❓ Questions de Révision TP3

1. **Pourquoi utilise-t-on `BLO` / `BHI` pour comparer des caractères ASCII et non `BLT` / `BGT` ?**
   - Les codes ASCII sont considérés comme des entiers non signés ($0$ à $255$). Un caractère $\ge 128$ serait vu comme négatif en comparaison signée !
2. **Si `D0.W = 0`, combien de fois s'exécute une boucle avec `DBRA D0, loop` ?**
   - Exactement $1$ fois : $D0.W$ passe de $0$ à $-1$, ce qui termine la boucle au premier passage.
3. **Pourquoi l'instruction `TST.B D1` est-elle redondante juste après `MOVE.B (A0)+, D1` ?**
   - L'instruction `MOVE` configure déjà les flags $Z$ et $N$ en fonction de la valeur transférée dans $D1$.

---
*Fiche précédente : [[TP2-Modes-Adressage]]*  
*Index général : [[Informatique/README]]*

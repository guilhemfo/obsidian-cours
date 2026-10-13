---
title: "Synthèse Arbres Binaires & Arbres de Recherche (AR2)"
matiere: "Algorithmique"
date: "2026-10-11"
tags: [fiche, revision, algorithmique, arbres, abr, avl, b-trees, epita, s3]
source: "EPITA S3 FISE 2030 – algo-Arbres (Moodle mod_page 107754)"
---

# 🌲 Arbres Binaires de Recherche & Équilibrage (AR2)

> **Matière :** Algorithmique S3 (EPITA Promo 2030)  
> **Module :** `[algo] Arbres et Recherches 2`  
> **Fichiers sources Moodle :** `arbres_recherche_fiche.txt`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Définition d'un Arbre Binaire de Recherche (ABR / BST) :**
   - Pour tout nœud $x$, toutes les clés du sous-arbre gauche sont $\le \text{clé}(x)$.
   - Toutes les clés du sous-arbre droit sont $\ge \text{clé}(x)$.
   - **Parcours infixe (Gauche $\to$ Racine $\to$ Droite) :** Visite les clés par **ordre strictement croissant** en temps $\Theta(n)$.
2. **Complexités de l'ABR :**
   - **Cas moyen (arbre bien équilibré) :** Recherche, insertion, suppression en $\mathcal{O}(\log n)$.
   - **Pire cas (arbre dégénéré / filiforme) :** Recherche, insertion en $\mathcal{O}(n)$ (équivalent à une liste simplement chaînée).
3. **Arbres Équilibrés (AVL) :**
   - Facteur d'équilibre $h(Droit) - h(Gauche) \in \{-1, 0, 1\}$.
   - Rééquilibrage par **rotations simples** (gauche-gauche ou droite-droite) ou **doubles rotations** (gauche-droite ou droite-gauche) en temps $\mathcal{O}(1)$.
   - Hauteur garantie $h \le 1.44 \log_2(n)$. Toutes les opérations restent en $\mathcal{O}(\log n)$ dans le pire des cas.
4. **Suppression d'un nœud dans un ABR :**
   - Nœud feuille : suppression directe.
   - Nœud avec 1 seul enfant : le parent du nœud pointe directement sur son unique enfant.
   - Nœud avec 2 enfants : remplacer la clé par son **successeur infixe** (le minimum du sous-arbre droit) ou son prédécesseur (le maximum du sous-arbre gauche), puis supprimer ce successeur.

---

## 🏗️ 1. Structure de données & Parcours en C

```c
typedef struct s_node {
    int key;
    struct s_node *left;
    struct s_node *right;
} t_node;

// Parcours Infixe (trié croissant)
void inorder_print(t_node *root) {
    if (root != NULL) {
        inorder_print(root->left);
        printf("%d ", root->key);
        inorder_print(root->right);
    }
}
```

---

## 🔄 2. Les Rotations AVL

Soit un déséquilibre provoqué par une insertion :

| Type de déséquilibre | Description | Correction appliquée |
| :--- | :--- | :--- |
| **Gauche-Gauche (LL)** | Sous-arbre gauche trop lourd, insertion dans son sous-arbre gauche | **Rotation droite simple** autour de la racine |
| **Droite-Droite (RR)** | Sous-arbre droit trop lourd, insertion dans son sous-arbre droit | **Rotation gauche simple** autour de la racine |
| **Gauche-Droite (LR)** | Sous-arbre gauche trop lourd, insertion dans son sous-arbre droit | **Rotation gauche** sur l'enfant gauche, puis **rotation droite** sur la racine |
| **Droite-Gauche (RL)** | Sous-arbre droit trop lourd, insertion dans son sous-arbre gauche | **Rotation droite** sur l'enfant droit, puis **rotation gauche** sur la racine |

---

## ❓ Questions de Révision

1. **Quel est le parcours d'un ABR qui permet de restaurer la liste des éléments triés ?**
   - Le parcours infixe (In-Order Traversal).
2. **Quelle est la hauteur maximale d'un ABR à $n$ nœuds ?**
   - $n$ (dans le cas d'un arbre peigne / dégénéré).
3. **Pourquoi un AVL est-il plus performant qu'un ABR simple pour des insertions ordonnées ?**
   - Insérer des éléments déjà triés dans un ABR simple produit une liste dégénérée de hauteur $n$ ($\mathcal{O}(n)$ par recherche). L'AVL force des rotations et maintient une hauteur en $\mathcal{O}(\log n)$.

---
*Index général : [[Algorithmique/README]]* | *Accueil : [[Bienvenue]]*

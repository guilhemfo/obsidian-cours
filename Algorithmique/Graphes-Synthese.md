---
title: "Synthèse Graphes — Définitions, Représentations, Parcours & Connexité"
matiere: "Algorithmique"
date: "2026-10-11"
tags: [fiche, revision, algorithmique, graphes, dfs, bfs, connexite, epita, s3]
source: "EPITA S3 FISE 2030 – algo-Graphs (Krisboul / Moodle)"
---

# 🕸️ Théorie des Graphes : Synthèse Complète

> **Matière :** Algorithmique S3 (EPITA Promo 2030)  
> **Module :** `[algo] Graphs`  
> **Fichiers sources Moodle :** `graphes_description.pdf`, `graphes_representation.pdf`, `graphes_parcours.pdf`, `graphes_connexite.pdf`, `exemples_impl_c.txt`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Définition formelle :**
   - Graphe $G = \langle S, A \rangle$ ou $\langle S, A, C \rangle$ (si valué avec fonction de coût $C : A \to \mathbb{R}$).
   - $|S| = n$ est **l'ordre** du graphe ; $|A| = m$ est la **taille** du graphe.
   - Non orienté : $A$ contient des **arêtes** (paires $\{x, y\}$). Degré d'un sommet $d(x)$.
   - Orienté : $A$ contient des **arcs** (couples $(x, y)$ avec $x \to y$). Degré sortant $d^+(x)$ et entrant $d^-(x)$.
   - **Formule d'Euler / Lemme des poignées de mains :** $\sum_{x \in S} d(x) = 2m$.
2. **Représentations mémoires (Complexités d'espace et temps) :**
   - **Matrice d'adjacence ($n \times n$) :** Espace $\Theta(n^2)$. Test d'adjacence $(x, y) \in A$ en $\Theta(1)$. Liste des voisins en $\Theta(n)$.
   - **Listes d'adjacence ($n$ listes chaînées) :** Espace $\Theta(n + m)$. Test d'adjacence en $\mathcal{O}(d(x))$. Voisins de $x$ en $\Theta(d(x))$. Idéal pour graphes creux ($m \ll n^2$).
   - **Matrice d'incidence ($n \times m$) :** Espace $\Theta(n \times m)$. Utilisée en théorie algébrique des graphes.
   - **Tableaux d'arêtes / arcs :** Tableau de taille $m$, compact, utile pour Kruskal ou Bellman-Ford.
3. **Parcours fondamentaux :**
   - **DFS (Profondeur - Pile / Récursivité) :** Explore au plus loin avant de rebrousser chemin. Utilisé pour : détection de cycles, tri topologique, composantes fortement connexes.
   - **BFS (Largeur - File FIFO) :** Explore par cercles concentriques (niveaux). Calcule le **plus court chemin en nombre d'arêtes** dans un graphe non pondéré.
   - **Complexité des deux parcours :** $\mathcal{O}(n + m)$ avec listes d'adjacence ; $\mathcal{O}(n^2)$ avec matrice d'adjacence.
4. **Connexité :**
   - **Graphe non orienté connexe :** Pour toute paire $\{x, y\}$, il existe une chaîne entre $x$ et $y$.
   - **Composante connexe (CC) :** Sous-graphe connexe maximal.
   - **Cas statique :** Calculable en $\mathcal{O}(n + m)$ par DFS/BFS (numérotation des composantes).
   - **Cas évolutif (ajouts d'arêtes) :** Structure de données **Disjoint-Set (Union-Find)** avec compression de chemin et union par rang en temps quasi-linéaire $\mathcal{O}(m \cdot \alpha(n))$.

---

## 📐 1. Vocabulaire & Propriétés Fondamentales

| Terme | Définition formelle | Remarque / Propriété |
| :--- | :--- | :--- |
| **Ordre $n$** | Nombre total de sommets $|S|$ | $|S| = n$ |
| **Taille $m$** | Nombre total d'arêtes ou d'arcs $|A|$ | $|A| = m \le n(n-1)/2$ (non orienté simple) |
| **Graphe simple** | Sans boucle ($x \to x$) ni arêtes multiples | Hypothèse standard du cours |
| **Graphe complet $K_n$** | Tout sommet est relié à tous les autres | Nombre d'arêtes : $m = \frac{n(n-1)}{2}$ |
| **Degré $d(x)$** | Nombre de voisins du sommet $x$ | $\sum_{x \in S} d(x) = 2m$ (donc somme toujours paire) |
| **Chaîne / Chemin** | Suite de sommets reliés consécutivement | Chaîne (non orienté), Chemin (orienté) |
| **Cycle / Circuit** | Chaîne/Chemin fermé où les arêtes/arcs sont distincts | Cycle (non orienté), Circuit (orienté) |
| **Arbre** | Graphe connexe et sans cycle (acyclique) | Propriété clé : $m = n - 1$ |
| **Forêt** | Graphe sans cycle ($k$ arbres) | Propriété : $m = n - k$ |

---

## 🗄️ 2. Représentations en Mémoire & Implémentation C

### Tableau comparatif des structures

| Opération | Matrice d'adjacence | Listes d'adjacence | Tableau de liaisons |
| :--- | :---: | :---: | :---: |
| **Espace mémoire** | $\Theta(n^2)$ | $\Theta(n + m)$ | $\Theta(m)$ |
| **Tester si $(x, y) \in A$** | $\mathcal{O}(1)$ | $\mathcal{O}(d(x))$ | $\mathcal{O}(m)$ |
| **Lister les successeurs de $x$** | $\Theta(n)$ | $\Theta(d(x))$ | $\Theta(m)$ |
| **Ajouter une arête** | $\mathcal{O}(1)$ | $\mathcal{O}(1)$ (en tête) | $\mathcal{O}(1)$ |
| **Supprimer une arête** | $\mathcal{O}(1)$ | $\mathcal{O}(d(x))$ | $\mathcal{O}(m)$ |

### Implémentation en C (Listes d'adjacence)
```c
// Définition d'une arête dans une liste chaînée
typedef struct s_edge {
    int dest;              // Sommet d'arrivée
    double weight;         // Coût éventuel
    struct s_edge *next;   // Arête suivante
} t_edge;

// Définition du graphe
typedef struct s_graph {
    int order;             // Nombre de sommets n
    int is_directed;       // 1 si orienté, 0 sinon
    t_edge **adj;          // Tableau de pointeurs (adj[u] = tête de liste)
} t_graph;
```

---

## 🚶 3. Algorithmes de Parcours

### Parcours en Profondeur (DFS - Depth First Search)
Principe : Visiter récursivement le premier voisin non encore visité (utilise une pile d'exécution).

```text
Algorithme DFS(G, u, visite):
    visite[u] = VRAI
    Traiter(u)
    Pour chaque voisin v de u dans G:
        Si NON visite[v] alors:
            DFS(G, v, visite)

Algorithme DFS_Complet(G):
    Pour u = 1 à n: visite[u] = FAUX
    Pour u = 1 à n:
        Si NON visite[u] alors:
            DFS(G, u, visite)
```

### Parcours en Largeur (BFS - Breadth First Search)
Principe : Utilise une file FIFO pour visiter les sommets par ordre de distance croissante depuis la racine.

```text
Algorithme BFS(G, s):
    Pour u = 1 à n: visite[u] = FAUX, dist[u] = +infini
    File F = CreerFile()
    visite[s] = VRAI
    dist[s] = 0
    Enfiler(F, s)
    
    Tant que F n'est pas vide:
        u = Defiler(F)
        Traiter(u)
        Pour chaque voisin v de u:
            Si NON visite[v] alors:
                visite[v] = VRAI
                dist[v] = dist[u] + 1
                Enfiler(F, v)
```

> [!important]
> **Propriété du BFS :** Le tableau `dist[v]` renvoie la distance minimale (nombre minimal d'arêtes) entre la source $s$ et le sommet $v$.

---

## 🔗 4. Connexité des Graphes Non Orientés

### 1. Cas Statique (Graphe figé)
On cherche la partition de $S$ en composantes connexes $S = C_1 \cup C_2 \cup \dots \cup C_k$.
- **Algorithme :** On parcourt les sommets de $1$ à $n$. Dès qu'un sommet $u$ n'est pas numéroté, on lance un DFS/BFS qui attribue le numéro de composante courante à tous les sommets atteints.
- **Complexité :** $\mathcal{O}(n + m)$ en temps et $\mathcal{O}(n)$ en espace.

### 2. Cas Évolutif (Ajouts dynamiques d'arêtes - Union-Find)
Lorsqu'on ajoute des arêtes une à une, relancer un DFS à chaque étape coûterait $\mathcal{O}(m \times (n+m))$, ce qui est inefficace.
On utilise la structure **Union-Find** :
- `Find(x)` : Détermine le représentant de la composante contenant $x$ (avec **compression de chemin** : chaque nœud pointe directement sur la racine).
- `Union(x, y)` : Fusionne les deux composantes (avec **union par rang / taille** : l'arbre le plus petit est rattaché sous la racine du plus grand).
- **Théorème de Tarjan :** Pour $m$ opérations, le coût amorti par opération est $\mathcal{O}(\alpha(n))$ (où $\alpha$ est la fonction réciproque d'Ackermann, $\alpha(n) \le 4$ dans tout l'univers réel).

```c
int find(int parent[], int x) {
    if (parent[x] != x)
        parent[x] = find(parent, parent[x]); // Compression de chemin
    return parent[x];
}

void union_sets(int parent[], int rank[], int x, int y) {
    int root_x = find(parent, x);
    int root_y = find(parent, y);
    if (root_x != root_y) {
        if (rank[root_x] < rank[root_y])
            parent[root_x] = root_y;
        else if (rank[root_x] > rank[root_y])
            parent[root_y] = root_x;
        else {
            parent[root_y] = root_x;
            rank[root_x]++;
        }
    }
}
```

---

## ❓ Questions d'Examen & Pièges Récurrents

1. **Un graphe non orienté de 10 sommets peut-il avoir pour degrés $\{3, 3, 3, 2, 2, 2, 1, 1, 1, 1\}$ ?**
   - Non ! La somme des degrés vaut $3 \times 3 + 3 \times 2 + 4 \times 1 = 9 + 6 + 4 = 19$, qui est un nombre **impair**. D'après le lemme des poignées de mains, $\sum d(x) = 2m$, donc la somme est obligatoirement paire.
2. **Quelle est la condition nécessaire et suffisante pour qu'un graphe connexe soit un arbre ?**
   - Qu'il possède exactement $m = n - 1$ arêtes (ou de façon équivalente : être connexe et sans cycle).
3. **Quand préférer une matrice d'adjacence aux listes d'adjacence ?**
   - Lorsque le graphe est très dense ($m \approx n^2$) ou lorsqu'on effectue intensivement des tests d'adjacence $(u, v) \in A$ en temps $\mathcal{O}(1)$ ou des produits matriciels (calcul de chemins de longueur $k$ via $M^k$).

---
*Index général : [[Algorithmique/README]]* | *Accueil : [[Bienvenue]]*

---
title: "Probabilités & Séries Entières"
matiere: Maths
date: 2026-10-11
tags:
  - maths
  - probabilités
  - séries-entières
  - S3
  - EPITA
  - révision
---

# 📊 Probabilités & Séries Entières — EPITA S3

> [!important] Points Clés
> - Une **série entière** $\sum a_n x^n$ converge sur $]-R, R[$ où $R$ est le **rayon de convergence**
> - Toute fonction DSE est $C^\infty$, et les coefficients sont **uniques** : $a_n = \frac{f^{(n)}(0)}{n!}$
> - La **fonction génératrice** $G_X(t) = E(t^X)$ est une série entière qui encode toute la loi de $X$
> - $E(X) = G'_X(1)$ et $\text{Var}(X) = G''_X(1) + G'_X(1) - (G'_X(1))^2$

---

## I — Séries Entières

### 1.1 Définition

Une **série entière** est une série de fonctions de la forme :

$$\sum_{n=0}^{+\infty} a_n x^n$$

où les $a_n \in \mathbb{R}$ (ou $\mathbb{C}$) sont les **coefficients** et $x$ la variable.

- Elle converge **toujours** en $x = 0$ (somme $= a_0$).
- Son **domaine de convergence** $D_f$ est l'ensemble des $x$ pour lesquels elle converge absolument.
- Si elle converge pour d'autres valeurs de $x$, on définit :

$$f(x) = \sum_{n=0}^{+\infty} a_n x^n, \quad x \in D_f$$

---

### 1.2 Rayon de convergence $R$

> [!important] Théorème fondamental
> Il existe un unique $R \in [0, +\infty]$ tel que :
> - La série **converge absolument** pour $|x| < R$
> - La série **diverge** pour $|x| > R$
> - En $x = \pm R$ : **à étudier au cas par cas**

**Calcul du rayon de convergence :**

| Méthode | Formule |
|--------|---------|
| Règle de d'Alembert (quotient) | $R = \lim_{n \to \infty} \left\|\frac{a_n}{a_{n+1}}\right\|$ |
| Règle de Hadamard (racine) | $\frac{1}{R} = \limsup_{n \to \infty} \|a_n\|^{1/n}$ |
| Par comparaison | Comparaison à une série de référence connue |

**Propriétés sur $]-R, R[$ (si $R > 0$) :**

- $f$ est **continue** sur $]-R, R[$
- $f$ est **dérivable terme à terme** : $f'(x) = \sum_{n=1}^{+\infty} n\, a_n\, x^{n-1}$ (même rayon $R$)
- $f$ est **intégrable terme à terme** : $\int_0^x f(t)\,dt = \sum_{n=0}^{+\infty} \frac{a_n}{n+1} x^{n+1}$ (même rayon $R$)
- $f$ est $C^\infty$ sur $]-R, R[$

---

### 1.3 Développements en Séries Entières (DSE)

**Définition :** $f$ est **développable en série entière** (DSE) au voisinage de $0$ s'il existe une série entière $\sum a_n x^n$ de rayon $R > 0$ telle que :

$$f(x) = \sum_{n=0}^{+\infty} a_n x^n, \quad \forall x \in ]-R, R[$$

> [!note] Unicité des coefficients
> Si $f$ est DSE, alors $f$ est $C^\infty$ et les coefficients sont **uniquement déterminés** par :
> $$a_n = \frac{f^{(n)}(0)}{n!}$$
> C'est le **développement de Taylor-MacLaurin** de $f$.

---

### 1.4 Séries de référence à connaître par cœur

| Fonction | Développement en série entière | Rayon $R$ |
|----------|-------------------------------|-----------|
| $e^x$ | $\displaystyle\sum_{n=0}^{+\infty} \frac{x^n}{n!} = 1 + x + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots$ | $+\infty$ |
| $\ln(1+x)$ | $\displaystyle\sum_{n=1}^{+\infty} \frac{(-1)^{n-1} x^n}{n} = x - \frac{x^2}{2} + \frac{x^3}{3} - \cdots$ | $1$ |
| $(1+x)^\alpha$ | $\displaystyle\sum_{n=0}^{+\infty} \binom{\alpha}{n} x^n$ avec $\binom{\alpha}{n} = \frac{\alpha(\alpha-1)\cdots(\alpha-n+1)}{n!}$ | $+\infty$ si $\alpha \in \mathbb{N}$, sinon $1$ |
| $\dfrac{1}{1+x}$ | $\displaystyle\sum_{n=0}^{+\infty} (-1)^n x^n = 1 - x + x^2 - x^3 + \cdots$ | $1$ |
| $\dfrac{1}{1-x}$ | $\displaystyle\sum_{n=0}^{+\infty} x^n = 1 + x + x^2 + x^3 + \cdots$ | $1$ |
| $\sin(x)$ | $\displaystyle\sum_{n=0}^{+\infty} \frac{(-1)^n x^{2n+1}}{(2n+1)!} = x - \frac{x^3}{6} + \frac{x^5}{120} - \cdots$ | $+\infty$ |
| $\cos(x)$ | $\displaystyle\sum_{n=0}^{+\infty} \frac{(-1)^n x^{2n}}{(2n)!} = 1 - \frac{x^2}{2} + \frac{x^4}{24} - \cdots$ | $+\infty$ |
| $\arctan(x)$ | $\displaystyle\sum_{n=0}^{+\infty} \frac{(-1)^n x^{2n+1}}{2n+1} = x - \frac{x^3}{3} + \frac{x^5}{5} - \cdots$ | $1$ |

> [!tip] Astuce pour les DSE
> Pour trouver le DSE d'une fonction complexe :
> 1. **Décomposer** en éléments simples (fractions partielles, etc.)
> 2. **Intégrer ou dériver** un DSE connu
> 3. **Substituer** $x \leftarrow g(x)$ dans un DSE connu
> 4. **Multiplier** deux DSE connus (produit de Cauchy)

---

## II — Variables Aléatoires Entières Infinies

### 2.1 Définition

**Variable aléatoire entière :** $X$ est une variable aléatoire discrète infinie si :

$$X(\Omega) = \{x_0, x_1, x_2, \ldots\}$$

est un ensemble infini dénombrable indexable par $\mathbb{N}$.

Dans le cadre S3 : on considère $X$ à valeurs dans $\mathbb{N}$ (ou $\mathbb{N}^*$).

**Loi de $X$ :** donnée par $P(X = n)$ pour tout $n \in X(\Omega)$, avec la condition de normalisation :

$$\sum_{n \in X(\Omega)} P(X = n) = 1$$

---

### 2.2 Loi Géométrique

**Définition :** $X \sim \mathcal{G}(p)$ avec $p \in ]0, 1[$ et $q = 1 - p$.

$$X(\Omega) = \mathbb{N}^*, \quad P(X = n) = q^{n-1} \cdot p, \quad n \geq 1$$

**Interprétation :** $X$ est le **nombre d'essais nécessaires pour obtenir le 1er succès** dans une suite d'épreuves de Bernoulli indépendantes, chacune de probabilité de succès $p$.

> [!note] Absence de mémoire
> La loi géométrique est l'unique loi discrète ayant la propriété d'**absence de mémoire** :
> $$P(X > m + n \mid X > m) = P(X > n)$$

---

### 2.3 Espérance et Variance

#### Définitions

$$E(X) = \sum_{n \in X(\Omega)} n \cdot P(X = n)$$

*(série numérique, peut ne pas converger — dans ce cas $E(X)$ n'existe pas)*

$$\text{Var}(X) = E\left[(X - E(X))^2\right] = \sum_{n} (n - E(X))^2 \cdot P(X = n)$$

$$\sigma(X) = \sqrt{\text{Var}(X)} \quad \text{(écart-type)}$$

#### Propriétés fondamentales

| Propriété | Formule |
|-----------|---------|
| Linéarité de l'espérance | $E(aX + b) = a\,E(X) + b$ |
| Additivité (toujours) | $E(X + Y) = E(X) + E(Y)$ |
| Variance d'une translatée | $\text{Var}(aX + b) = a^2\,\text{Var}(X)$ |
| Variance si indépendantes | $\text{Var}(X + Y) = \text{Var}(X) + \text{Var}(Y)$ |
| Formule de König-Huygens | $\text{Var}(X) = E(X^2) - (E(X))^2$ |

---

### 2.4 Fonction Génératrice $G_X$

> [!important] Définition centrale
> La **fonction génératrice** de $X$ est :
> $$G_X(t) = E(t^X) = \sum_{n=0}^{+\infty} t^n \cdot P(X = n)$$
> C'est une **série entière en $t$** !

**Propriétés clés :**

- Le rayon de convergence est $\geq 1$
- $G_X$ est $C^\infty$ sur $]-1, 1[$
- $G_X(1) = 1$ (normalisation)
- $G_X(0) = P(X = 0)$
- $G_X^{(n)}(0) = n! \cdot P(X = n)$ (lecture des probabilités !)

**Indépendance et produit :**

$$X, Y \text{ indépendantes} \implies G_{X+Y}(t) = G_X(t) \cdot G_Y(t)$$

#### Théorème : Calcul de $E(X)$ et $\text{Var}(X)$ via $G_X$

> [!important] Formules à connaître (si $R > 1$)
> $$\boxed{E(X) = G'_X(1)}$$
> $$\boxed{\text{Var}(X) = G''_X(1) + G'_X(1) - \left(G'_X(1)\right)^2}$$
>
> **Démonstration (idée) :**
> - $G'_X(t) = \sum_{n=1}^{+\infty} n\, t^{n-1} P(X=n)$, donc $G'_X(1) = \sum n\, P(X=n) = E(X)$
> - $G''_X(t) = \sum_{n=2}^{+\infty} n(n-1)\, t^{n-2} P(X=n)$, donc $G''_X(1) = E(X(X-1)) = E(X^2) - E(X)$
> - D'où : $\text{Var}(X) = E(X^2) - (E(X))^2 = G''_X(1) + G'_X(1) - (G'_X(1))^2$

---

## III — Lois Usuelles

### Tableau comparatif : Loi Géométrique vs Loi de Poisson

| Caractéristique | Loi Géométrique $\mathcal{G}(p)$ | Loi de Poisson $\mathcal{P}(\lambda)$ |
|----------------|----------------------------------|---------------------------------------|
| **Paramètre** | $p \in ]0,1[$, $q = 1-p$ | $\lambda > 0$ |
| **Support** | $X(\Omega) = \mathbb{N}^* = \{1, 2, 3, \ldots\}$ | $X(\Omega) = \mathbb{N} = \{0, 1, 2, \ldots\}$ |
| **Loi** | $P(X=n) = q^{n-1} p$ | $P(X=n) = e^{-\lambda} \dfrac{\lambda^n}{n!}$ |
| **Fonction génératrice** | $G_X(t) = \dfrac{pt}{1-qt}$ | $G_X(t) = e^{\lambda(t-1)}$ |
| **Espérance** | $E(X) = \dfrac{1}{p}$ | $E(X) = \lambda$ |
| **Variance** | $\text{Var}(X) = \dfrac{q}{p^2} = \dfrac{1-p}{p^2}$ | $\text{Var}(X) = \lambda$ |
| **Écart-type** | $\sigma(X) = \dfrac{\sqrt{q}}{p}$ | $\sigma(X) = \sqrt{\lambda}$ |
| **Interprétation** | Nbre d'essais jusqu'au 1er succès | Nbre d'événements rares dans un intervalle |
| **Stabilité** | $\mathcal{G}(p) + \mathcal{G}(p) \neq \mathcal{G}$ | $\mathcal{P}(\lambda) + \mathcal{P}(\mu) = \mathcal{P}(\lambda+\mu)$ |

> [!note] Stabilité de la loi de Poisson
> Si $X \sim \mathcal{P}(\lambda)$ et $Y \sim \mathcal{P}(\mu)$ **indépendantes**, alors :
> $$X + Y \sim \mathcal{P}(\lambda + \mu)$$
> **Preuve :** $G_{X+Y}(t) = G_X(t) \cdot G_Y(t) = e^{\lambda(t-1)} \cdot e^{\mu(t-1)} = e^{(\lambda+\mu)(t-1)}$

---

## 📌 À retenir absolument

> [!important] Les 3 règles d'or des séries entières
> 1. **Dérivation et intégration terme à terme** conservent le rayon $R$
> 2. Les coefficients d'un DSE sont **uniques** : $a_n = \dfrac{f^{(n)}(0)}{n!}$
> 3. En $\pm R$, la convergence est **à étudier séparément** (critère d'Abel, Leibniz, etc.)

> [!important] Les 3 règles d'or des variables aléatoires
> 1. $G_X(t) = E(t^X)$ est une **série entière** de rayon $\geq 1$
> 2. $G_{X+Y} = G_X \cdot G_Y$ si et seulement si $X, Y$ sont **indépendantes**
> 3. Pour Poisson : $E(X) = \text{Var}(X) = \lambda$ (égalité remarquable !)

> [!caution] Pièges courants à l'examen
> - Oublier d'étudier la convergence en $\pm R$
> - Confondre $X(\Omega) = \mathbb{N}$ (inclut $0$) et $X(\Omega) = \mathbb{N}^*$ (exclut $0$) selon la loi
> - Appliquer la formule de Var via $G_X$ sans vérifier que $R > 1$
> - Oublier le facteur $e^{-\lambda}$ dans $P(X=n)$ pour Poisson

---

## 🔧 Méthode : Calculer $E(X)$ et $\text{Var}(X)$ via $G_X$

**Étape 1 — Identifier la loi et écrire $G_X(t)$**

$$G_X(t) = \sum_{n=0}^{+\infty} P(X=n) \cdot t^n$$

Reconnaître si c'est un DSE connu (géométrique, exponentielle, etc.)

**Étape 2 — Calculer $G'_X(t)$**

Dériver terme à terme ou utiliser la forme fermée.

**Étape 3 — Évaluer en $t = 1$**

$$E(X) = G'_X(1)$$

> [!tip] Attention à la continuité
> Si $G'_X$ n'est pas définie en $1$ (bord du domaine), prendre la **limite à gauche** : $G'_X(1^-)$

**Étape 4 — Calculer $G''_X(t)$ et évaluer en $t = 1$**

$$\text{Var}(X) = G''_X(1) + G'_X(1) - \left(G'_X(1)\right)^2$$

**Étape 5 — Vérification** : $\text{Var}(X) \geq 0$ et $G_X(1) = 1$

---

## 📐 Exemples Clés

### Exemple 1 : DSE de $\frac{1}{1-2x}$

On reconnaît $\frac{1}{1-u}$ avec $u = 2x$ :

$$\frac{1}{1-2x} = \sum_{n=0}^{+\infty} (2x)^n = \sum_{n=0}^{+\infty} 2^n x^n, \quad |2x| < 1 \iff |x| < \frac{1}{2}$$

Rayon : $R = \dfrac{1}{2}$, coefficients : $a_n = 2^n$

---

### Exemple 2 : DSE de $\ln(1-x)$

En partant de $\frac{1}{1-x} = \sum x^n$, on intègre terme à terme :

$$-\ln(1-x) = \int_0^x \frac{1}{1-t}\,dt = \sum_{n=0}^{+\infty} \frac{x^{n+1}}{n+1} = \sum_{n=1}^{+\infty} \frac{x^n}{n}$$

Donc $\ln(1-x) = -\sum_{n=1}^{+\infty} \dfrac{x^n}{n}$, pour $|x| < 1$.

---

### Exemple 3 : Loi géométrique — calcul via $G_X$

$X \sim \mathcal{G}(p)$, $q = 1-p$.

$$G_X(t) = \sum_{n=1}^{+\infty} q^{n-1} p \cdot t^n = pt \sum_{n=1}^{+\infty} (qt)^{n-1} = \frac{pt}{1-qt}, \quad |qt| < 1$$

Dérivée : $G'_X(t) = \dfrac{p(1-qt) + pqt}{(1-qt)^2} = \dfrac{p}{(1-qt)^2}$

$$E(X) = G'_X(1) = \frac{p}{(1-q)^2} = \frac{p}{p^2} = \frac{1}{p}$$

Deuxième dérivée : $G''_X(t) = \dfrac{2pq}{(1-qt)^3}$, donc $G''_X(1) = \dfrac{2q}{p^2}$

$$\text{Var}(X) = \frac{2q}{p^2} + \frac{1}{p} - \frac{1}{p^2} = \frac{2q + p - 1}{p^2} = \frac{2q - q}{p^2} = \frac{q}{p^2}$$

---

### Exemple 4 : Loi de Poisson — calcul via $G_X$

$X \sim \mathcal{P}(\lambda)$.

$$G_X(t) = \sum_{n=0}^{+\infty} e^{-\lambda} \frac{\lambda^n}{n!} t^n = e^{-\lambda} \sum_{n=0}^{+\infty} \frac{(\lambda t)^n}{n!} = e^{-\lambda} e^{\lambda t} = e^{\lambda(t-1)}$$

$G'_X(t) = \lambda e^{\lambda(t-1)}$, donc $E(X) = G'_X(1) = \lambda$

$G''_X(t) = \lambda^2 e^{\lambda(t-1)}$, donc $G''_X(1) = \lambda^2$

$$\text{Var}(X) = \lambda^2 + \lambda - \lambda^2 = \lambda$$

---

### Exemple 5 : Somme de variables indépendantes

Si $X_1, X_2, \ldots, X_k$ sont **indépendantes** avec $X_i \sim \mathcal{P}(\lambda_i)$, alors :

$$G_{X_1 + \cdots + X_k}(t) = \prod_{i=1}^{k} e^{\lambda_i(t-1)} = e^{(\lambda_1 + \cdots + \lambda_k)(t-1)}$$

Donc $X_1 + \cdots + X_k \sim \mathcal{P}(\lambda_1 + \cdots + \lambda_k)$

---

## ❓ Questions de Révision

1. **Théorique** — Énoncer le théorème sur le rayon de convergence d'une série entière. Que se passe-t-il aux bords $\pm R$ ?

2. **Calcul** — Trouver le DSE de $f(x) = \dfrac{x}{(1-x)^2}$ et son rayon de convergence. *(Indice : dériver le DSE de $\frac{1}{1-x}$)*

3. **Calcul** — Trouver le DSE de $\arctan(x)$ à partir de $\dfrac{1}{1+x^2}$.

4. **Théorique** — Pourquoi la fonction génératrice $G_X(t)$ a-t-elle toujours un rayon de convergence $\geq 1$ ?

5. **Application** — Soit $X \sim \mathcal{G}(1/3)$. Calculer $P(X = 4)$, $E(X)$ et $\text{Var}(X)$.

6. **Application** — Soit $X \sim \mathcal{P}(2)$. Calculer $P(X = 0)$, $P(X = 1)$, $P(X \geq 2)$, $E(X)$ et $\text{Var}(X)$.

7. **Démonstration** — Prouver que $G_{X+Y}(t) = G_X(t) \cdot G_Y(t)$ lorsque $X$ et $Y$ sont indépendantes.

8. **Preuve** — Démontrer la formule $E(X) = G'_X(1)$ à partir de la définition de $G_X$.

9. **Synthèse** — Soit $X \sim \mathcal{G}(p)$ et $Y \sim \mathcal{G}(p)$ indépendantes. Calculer $G_{X+Y}(t)$ et en déduire la loi de $X+Y$ (ou montrer que ce n'est pas une loi géométrique usuelle).

10. **Ouverture** — On sait que $E(X) = \text{Var}(X)$. Quelle information cela donne-t-il sur la loi de $X$ ? *(Justifier que cela caractérise (partiellement) la loi de Poisson)*

---

## 🔗 Liens utiles

- [[Bienvenue]]
- [[Maths/README]]

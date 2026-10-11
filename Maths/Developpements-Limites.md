---
title: Développements Limités
matiere: Maths
date: 2026-10-11
tags:
  - maths
  - analyse
  - DL
  - développements-limités
  - EPITA-S3
  - révision
---

# 📐 Développements Limités (DL)

> [!NOTE] Liens rapides
> [[Bienvenue]] | [[Maths/README]]

---

## 🔑 Points Clés

- Un DL d'ordre $n$ en $x_0$ approxime $f$ par un polynôme au voisinage de $x_0$, à un reste près.
- Si le DL existe, il est **unique**.
- Les DL s'additionnent, se multiplient et se composent (sous conditions).
- Les comparaisons $o$, $O$, $\sim$ mesurent le comportement **relatif** de deux fonctions.
- $f \sim g \not\Rightarrow f - g \to 0$ (piège classique !).

---

## 📖 Résumé Structuré

### Définition — DL en $x_0$ à l'ordre $n$

$f$ admet un **développement limité** en $x_0$ à l'ordre $n$ s'il existe $a_0, a_1, \ldots, a_n \in \mathbb{R}$ et une fonction $\varepsilon$ telle que $\lim_{x \to x_0} \varepsilon(x) = 0$ et :

$$f(x) = \underbrace{a_0 + a_1(x-x_0) + a_2(x-x_0)^2 + \cdots + a_n(x-x_0)^n}_{\text{partie polynomiale}} + \underbrace{(x-x_0)^n \cdot \varepsilon(x)}_{\text{reste}}$$

### Théorème de Taylor-Young

Si $f$ est de classe $\mathcal{C}^n$ en $x_0$ :

$$f(x) = \sum_{k=0}^{n} \frac{f^{(k)}(x_0)}{k!}(x-x_0)^k + (x-x_0)^n \cdot \varepsilon(x)$$

**Propriétés de parité :**
- $f$ **paire** $\Rightarrow$ la partie polynomiale ne contient que des **puissances paires**.
- $f$ **impaire** $\Rightarrow$ la partie polynomiale ne contient que des **puissances impaires**.

> [!TIP] Changement de point
> $f$ admet un DL en $x_0$ $\iff$ $x \mapsto f(x + x_0)$ admet un DL en $0$.  
> On se ramène donc toujours à un DL en $0$.

---

### 📋 DL Usuels en $0$ — À connaître absolument

| Fonction | Développement limité en $0$ à l'ordre $n$ |
|---|---|
| $e^x$ | $\displaystyle 1 + x + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots + \frac{x^n}{n!} + x^n\varepsilon(x)$ |
| $\sin(x)$ | $\displaystyle x - \frac{x^3}{3!} + \frac{x^5}{5!} - \cdots + (-1)^p\frac{x^{2p+1}}{(2p+1)!} + x^{2p+1}\varepsilon(x)$ |
| $\cos(x)$ | $\displaystyle 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \cdots + (-1)^p\frac{x^{2p}}{(2p)!} + x^{2p}\varepsilon(x)$ |
| $\dfrac{1}{1-x}$ | $\displaystyle 1 + x + x^2 + \cdots + x^n + x^n\varepsilon(x)$ |
| $\dfrac{1}{1+x}$ | $\displaystyle 1 - x + x^2 - \cdots + (-1)^n x^n + x^n\varepsilon(x)$ |
| $\ln(1+x)$ | $\displaystyle x - \frac{x^2}{2} + \frac{x^3}{3} - \cdots + (-1)^{n-1}\frac{x^n}{n} + x^n\varepsilon(x)$ |
| $(1+x)^\alpha$ | $\displaystyle 1 + \alpha x + \frac{\alpha(\alpha-1)}{2!}x^2 + \cdots + \frac{\alpha(\alpha-1)\cdots(\alpha-n+1)}{n!}x^n + x^n\varepsilon(x)$ |
| $\tan(x)$ | $\displaystyle x + \frac{x^3}{3} + \frac{2x^5}{15} + \cdots$ (ordre 5 courant) |
| $\arctan(x)$ | $\displaystyle x - \frac{x^3}{3} + \frac{x^5}{5} - \cdots + (-1)^p\frac{x^{2p+1}}{2p+1} + x^{2p+1}\varepsilon(x)$ |
| $\sinh(x)$ | $\displaystyle x + \frac{x^3}{3!} + \frac{x^5}{5!} + \cdots$ |
| $\cosh(x)$ | $\displaystyle 1 + \frac{x^2}{2!} + \frac{x^4}{4!} + \cdots$ |

> [!IMPORTANT] Mémo parité
> - $\sin, \tan, \arctan, \sinh$ : **fonctions impaires** → que des puissances **impaires**  
> - $\cos, \cosh$ : **fonctions paires** → que des puissances **paires**  
> - $e^x, \ln(1+x), \frac{1}{1\pm x}, (1+x)^\alpha$ : ni paires ni impaires → **toutes** les puissances

---

## ⚖️ Comparaisons de Fonctions

### Définitions

| Notation | Nom | Définition formelle | Intuition |
|---|---|---|---|
| $f = o(g)$ en $x_0$ | **Négligeabilité** | $f(x) = g(x)\cdot\varepsilon(x)$ avec $\varepsilon(x) \xrightarrow[x\to x_0]{} 0$ | $f$ est **petite** devant $g$ |
| $f = O(g)$ en $x_0$ | **Domination** | $f(x) = g(x)\cdot\varepsilon(x)$ avec $\varepsilon$ **bornée** | $f$ ne grandit pas **plus vite** que $g$ |
| $f \sim g$ en $x_0$ | **Équivalence** | $f(x) = g(x)(1+\varepsilon(x))$ avec $\varepsilon(x)\to 0$ | $f$ et $g$ ont le **même ordre de grandeur** |

### Équivalences utiles

Si $g$ ne s'annule pas au voisinage de $x_0$ :
$$f \sim g \iff \frac{f(x)}{g(x)} \xrightarrow[x \to x_0]{} 1 \iff f = g + o(g)$$

### Propriétés de l'équivalence $\sim$

- **Relation d'équivalence** : réflexive, symétrique, transitive.
- **Polynômes en $0$** : $P(x) \sim$ terme de **plus bas degré** (terme dominant en $0$).
- **Polynômes en $+\infty$** : $P(x) \sim$ terme de **plus haut degré**.
- $f \sim g \Rightarrow$ **même limite** (mais pas la réciproque !).
- $f \sim g$ (positifs, en $+\infty$) $\Rightarrow$ $\sum f_n$ et $\sum g_n$ ont la **même nature** (convergence/divergence).

> [!WARNING] Piège classique — Équivalence ≠ différence nulle
> $$f \sim g \not\Rightarrow f - g \to 0$$
> L'équivalence signifie $\dfrac{f-g}{g} \to 0$, **pas** $f-g \to 0$.
>
> **Exemple :** $x+1 \sim x$ quand $x\to +\infty$ (car $\frac{x+1}{x} \to 1$), mais $(x+1)-x = 1 \not\to 0$.

> [!WARNING] On ne soustrait/additionne pas les équivalents !
> En général $f_1 \sim g_1$ et $f_2 \sim g_2$ **n'implique pas** $f_1 - f_2 \sim g_1 - g_2$.  
> On peut cependant **multiplier** et **diviser** des équivalents.

### Hiérarchie des infinis (quand $x \to +\infty$)

$$\ln(x) \ll x^\alpha \ll e^x \quad (\alpha > 0)$$

i.e. $\ln(x) = o(x^\alpha)$ et $x^\alpha = o(e^x)$.

---

## 🔧 Opérations sur les DL

Soit $f(x) = \sum_{k=0}^n a_k x^k + x^n\varepsilon_1(x)$ et $g(x) = \sum_{k=0}^n b_k x^k + x^n\varepsilon_2(x)$ deux DL en $0$ à l'ordre $n$.

### Somme

$$(f+g)(x) = \sum_{k=0}^n (a_k + b_k)\,x^k + x^n\varepsilon(x)$$

On **additionne** terme à terme les coefficients.

### Produit

$$(f \times g)(x) = T_n(x) + x^n\varepsilon(x)$$

où $T_n$ est le polynôme obtenu en **tronquant à l'ordre $n$** le produit des deux parties polynomiales (on ignore les termes de degré $> n$).

> [!TIP] Méthode produit
> Développer $(a_0 + a_1 x + \cdots)(b_0 + b_1 x + \cdots)$ et **conserver uniquement** les termes $x^k$ avec $k \leq n$.

### Composition $f \circ g$

**Condition :** $g(0) = 0$ (sinon on se ramène à ce cas par changement de variable).

**Méthode :**
1. Écrire le DL de $f$ en $u$.
2. Remplacer $u$ par $g(x)$ (le DL de $g$).
3. Développer et **tronquer à l'ordre $n$**.

> [!IMPORTANT] Condition de composition
> $g(0) = 0$ est **indispensable** pour que la composition soit bien définie au voisinage de $0$.

### Division (quotient)

Pour calculer le DL de $\dfrac{f}{g}$ avec $g(0) \neq 0$ :
- Écrire $g(x) = g(0)\left(1 + h(x)\right)$ avec $h(0) = 0$.
- Utiliser le DL de $\dfrac{1}{1+h(x)}$.

### Intégration

Si $f(x) = \sum_{k=0}^n a_k x^k + x^n\varepsilon(x)$, alors :
$$\int_0^x f(t)\,dt = \sum_{k=0}^n \frac{a_k}{k+1} x^{k+1} + x^{n+1}\varepsilon'(x)$$

Le DL obtenu est à l'ordre $n+1$.

### Dérivation

Si $f$ admet un DL à l'ordre $n$ : $f(x) = \sum_{k=0}^n a_k x^k + x^n\varepsilon(x)$, alors :
$$f'(x) = \sum_{k=1}^n k\,a_k x^{k-1} + x^{n-1}\varepsilon'(x)$$

Le DL obtenu est à l'ordre $n-1$ (on **perd** un ordre).

> [!WARNING] Dérivation fait perdre un ordre
> Préférer l'**intégration** quand possible : elle fait **gagner** un ordre.

---

## ⚡ À Retenir Absolument

> [!IMPORTANT] Unicité du DL
> Si $f$ admet un DL en $x_0$ à l'ordre $n$, **il est unique**.  
> Deux méthodes différentes donneront toujours les mêmes coefficients.

> [!IMPORTANT] DL et limite
> $$\lim_{x \to x_0} f(x) = a_0$$
> Le terme constant du DL donne la limite (ou la valeur) de $f$ en $x_0$.

> [!IMPORTANT] DL et dérivée
> $$f'(x_0) = a_1$$
> Le coefficient de $(x - x_0)$ dans le DL est la dérivée de $f$ en $x_0$.

> [!WARNING] Développer puis tronquer
> Lors d'un produit ou d'une composition, **toujours tronquer à la fin**, pas au milieu du calcul.  
> Conserver tous les termes intermédiaires jusqu'à l'ordre $n$ pour ne pas perdre des contributions.

> [!WARNING] DL nul ≠ fonction nulle
> Un reste $o(x^n)$ signifie que les termes négligés sont d'ordre $> n$, pas qu'ils sont nuls.

---

## 💡 Exemples Clés

### Exemple 1 — DL de $e^{\sin(x)}$ en $0$ à l'ordre $3$

**Étape 1 :** DL de $\sin(x)$ à l'ordre $3$ :
$$\sin(x) = x - \frac{x^3}{6} + o(x^3)$$

**Étape 2 :** DL de $e^u$ à l'ordre $3$ avec $u = \sin(x)$ :
$$e^u = 1 + u + \frac{u^2}{2} + \frac{u^3}{6} + o(u^3)$$

**Étape 3 :** Substituer $u = x - \frac{x^3}{6} + o(x^3)$ :
- $u = x - \frac{x^3}{6}$
- $u^2 = x^2 - \frac{x^4}{3} + \cdots \approx x^2$ (ordre 2 suffit ici)
- $u^3 \approx x^3$ (ordre 3)

$$e^{\sin(x)} = 1 + \left(x - \frac{x^3}{6}\right) + \frac{x^2}{2} + \frac{x^3}{6} + o(x^3) = 1 + x + \frac{x^2}{2} + o(x^3)$$

---

### Exemple 2 — Calcul d'une limite avec DL

**Calculer** $\displaystyle \lim_{x \to 0} \frac{\ln(1+x) - \sin(x)}{x^2}$

DL à l'ordre $2$ en $0$ :
$$\ln(1+x) = x - \frac{x^2}{2} + o(x^2)$$
$$\sin(x) = x - \frac{x^3}{6} + o(x^3) = x + o(x^2)$$

Donc :
$$\ln(1+x) - \sin(x) = \left(x - \frac{x^2}{2}\right) - x + o(x^2) = -\frac{x^2}{2} + o(x^2)$$

$$\frac{\ln(1+x) - \sin(x)}{x^2} \xrightarrow[x\to 0]{} -\frac{1}{2}$$

---

### Exemple 3 — Équivalent et nature de série

**Montrer que** $\sum \ln\!\left(1 + \frac{1}{n}\right)$ diverge.

$$\ln\!\left(1 + \frac{1}{n}\right) \sim \frac{1}{n} \quad (n \to +\infty)$$

Or $\sum \frac{1}{n}$ diverge (série harmonique), donc $\sum \ln\!\left(1 + \frac{1}{n}\right)$ **diverge**.

---

### Exemple 4 — DL par intégration

**Obtenir** le DL de $\arctan(x)$ à partir de $\dfrac{1}{1+x^2}$.

$$\frac{1}{1+x^2} = \frac{1}{1-(-x^2)} = \sum_{k=0}^n (-1)^k x^{2k} + o(x^{2n})$$

En intégrant :
$$\arctan(x) = \int_0^x \frac{dt}{1+t^2} = \sum_{k=0}^n \frac{(-1)^k x^{2k+1}}{2k+1} + o(x^{2n+1}) = x - \frac{x^3}{3} + \frac{x^5}{5} - \cdots$$

---

## ❓ Questions de Révision

1. **Définition.** Qu'est-ce qu'un développement limité d'ordre $n$ en $x_0$ ? Que sont la partie polynomiale et le reste ?

2. **Unicité.** Un DL est-il toujours unique ? Dans quel cas peut-il ne pas exister ?

3. **Parité.** Si $f$ est une fonction paire, que peut-on dire de la forme de son DL ? Et si elle est impaire ?

4. **DL usuels.** Donnez le DL de $e^x$, $\ln(1+x)$ et $\cos(x)$ en $0$ à l'ordre $4$.

5. **Composition.** Quelle condition doit vérifier $g$ pour pouvoir composer le DL de $f$ avec $g$ au voisinage de $0$ ? Pourquoi ?

6. **Différence o/O/$\sim$.** Expliquez la différence entre $f = o(g)$, $f = O(g)$ et $f \sim g$. Donnez un exemple pour chacun.

7. **Piège équivalence.** On a $f \sim g$ en $x_0$. Peut-on affirmer que $f - g \to 0$ ? Justifiez avec un contre-exemple.

8. **Limite.** Comment utilise-t-on un DL pour calculer une limite de la forme $\frac{f(x)}{g(x)}$ quand $f(x) \to 0$ et $g(x) \to 0$ ?

9. **Intégration vs dérivation.** Pourquoi préfère-t-on souvent obtenir un DL par intégration plutôt que par dérivation ?

10. **Application séries.** Énoncez le critère qui permet d'utiliser une équivalence pour déterminer la nature d'une série à termes positifs. Illustrez avec $\sum \frac{1}{\sqrt{n^2+1}}$.

---

*Fiche générée le 2026-10-11 — EPITA S3 Analyse*

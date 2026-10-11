---
title: Séries Numériques
matiere: Maths
date: 2026-10-11
tags:
  - maths
  - séries
  - analyse
  - EPITA
  - S3
  - convergence
---

# 📐 Séries Numériques — EPITA S3

> [!important] Objectif
> Maîtriser la convergence/divergence des séries numériques : définitions, critères, méthodes et pièges classiques.

---

## ⭐ Points Clés

- Une **série** $\sum u_n$ est définie par ses **sommes partielles** $S_n = \sum_{k=0}^{n} u_k$
- Elle **converge** si $(S_n)$ converge, **diverge** sinon
- La **condition nécessaire** $u_n \to 0$ n'est **pas suffisante** (contre-exemple : $\sum \frac{1}{n}$)
- Les **séries de Riemann** $\sum \frac{1}{n^\alpha}$ convergent $\iff \alpha > 1$
- La **convergence absolue** implique la convergence (mais pas l'inverse)
- Le **critère de Leibniz** s'applique aux séries alternées décroissantes

---

## 📋 Résumé des Théorèmes

### 1. Généralités

| Propriété | Énoncé |
|---|---|
| **Définition** | $S_n = \sum_{k=0}^{n} u_k$, la série converge si $\lim_{n\to+\infty} S_n \in \mathbb{R}$ |
| **Reste** | $R_n = \sum_{k=n+1}^{+\infty} u_k = S - S_n$ |
| **Linéarité** | $\sum u_n$ et $\sum v_n$ convergent $\Rightarrow \sum (u_n + v_n)$ converge et $\sum(au_n + bv_n) = a\sum u_n + b\sum v_n$ |
| **Divergence forcée** | $\sum u_n$ converge et $\sum v_n$ diverge $\Rightarrow \sum(u_n + v_n)$ **diverge** |
| **Télescopage** | $(u_n)$ converge $\iff \sum (u_n - u_{n-1})$ converge |
| **C.N.C.** | $\sum u_n$ converge $\Rightarrow u_n \to 0$ (réciproque **FAUSSE**) |

### 2. Série Géométrique

$$\sum_{n=0}^{+\infty} q^n \text{ converge} \iff |q| < 1 \quad \text{et sa somme est } \frac{1}{1-q}$$

Sommes partielles : $S_n = \frac{1 - q^{n+1}}{1 - q}$ pour $q \neq 1$.

### 3. Séries à Termes Positifs ($u_n \geq 0$)

| Critère | Condition | Conclusion |
|---|---|---|
| **Monotonie** | $u_n \geq 0$ | $\sum u_n$ converge $\iff (S_n)$ est majorée |
| **Comparaison** | $0 \leq u_n \leq v_n$ | $\sum v_n$ converge $\Rightarrow \sum u_n$ converge |
| **Comparaison** | $0 \leq u_n \leq v_n$ | $\sum u_n$ diverge $\Rightarrow \sum v_n$ diverge |
| **Équivalence** | $u_n \sim v_n > 0$ | $\sum u_n$ et $\sum v_n$ ont la **même nature** |
| **Grand O** | $u_n = O(v_n) > 0$ et $\sum v_n$ converge | $\sum u_n$ converge |
| **Riemann** | $n^\alpha \cdot u_n \to 0$ avec $\alpha > 1$ | $\sum u_n$ converge |
| **D'Alembert** | $\frac{u_{n+1}}{u_n} \to \ell$ | $\ell < 1 \Rightarrow$ converge ; $\ell > 1 \Rightarrow$ diverge ; $\ell = 1 \Rightarrow$ ? |
| **Cauchy** | $\sqrt[n]{u_n} \to \ell$ | $\ell < 1 \Rightarrow$ converge ; $\ell > 1 \Rightarrow$ diverge ; $\ell = 1 \Rightarrow$ ? |

### 4. Série de Riemann

$$\sum_{n=1}^{+\infty} \frac{1}{n^\alpha} \text{ converge} \iff \alpha > 1$$

| $\alpha$ | Nature |
|---|---|
| $\alpha > 1$ | Converge |
| $\alpha = 1$ | **Diverge** (série harmonique) |
| $\alpha \leq 1$ | Diverge |

### 5. Comparaisons de Landau

| Notation | Définition | Signification |
|---|---|---|
| $u_n = O(v_n)$ | $\exists (\varepsilon_n)$ bornée : $u_n = \varepsilon_n \cdot v_n$ | $u_n$ est du même ordre au plus |
| $u_n = o(v_n)$ | $\varepsilon_n \to 0$ | $u_n$ est négligeable devant $v_n$ |
| $u_n \sim v_n$ | $\varepsilon_n \to 1$ | $u_n$ et $v_n$ sont équivalents |

### 6. Séries à Termes Quelconques

| Critère | Condition | Conclusion |
|---|---|---|
| **Convergence absolue** | $\sum |u_n|$ converge | $\sum u_n$ converge |
| **Leibniz** | $(|u_n|)$ décroissante, $|u_n| \to 0$, série alternée | $\sum u_n$ converge et $|R_n| \leq |u_{n+1}|$ |
| **Semi-convergence** | $\sum u_n$ converge mais $\sum |u_n|$ diverge | Série semi-convergente |

### 7. Série Alternée de Référence

$$\sum_{n=1}^{+\infty} \frac{(-1)^n}{n^\alpha} \text{ converge} \iff \alpha > 0$$

---

## 📖 Définitions Importantes

| Terme | Définition |
|---|---|
| **Série** | La donnée d'une suite $(u_n)$ et l'étude de $\sum u_n$, définie par ses sommes partielles $S_n$ |
| **Somme partielle** | $S_n = \sum_{k=0}^{n} u_k$ |
| **Convergence** | $\sum u_n$ converge si $\lim_{n \to +\infty} S_n$ existe et est finie |
| **Somme de la série** | $S = \lim_{n \to +\infty} S_n = \sum_{k=0}^{+\infty} u_k$ |
| **Reste d'ordre $n$** | $R_n = S - S_n = \sum_{k=n+1}^{+\infty} u_k$ |
| **Série géométrique** | Série de la forme $\sum q^n$ |
| **Série de Riemann** | Série de la forme $\sum \frac{1}{n^\alpha}$ |
| **Série alternée** | Série dont les termes changent de signe : $u_n = (-1)^n a_n$ ou $(-1)^{n+1} a_n$ avec $a_n \geq 0$ |
| **Convergence absolue** | $\sum \|u_n\|$ converge |
| **Semi-convergence** | Convergente mais **pas** absolument convergente |
| **Partie positive** | $u_n^+ = \max(u_n, 0)$ |
| **Partie négative** | $u_n^- = \max(-u_n, 0)$, avec $u_n = u_n^+ - u_n^-$ |

---

## ⚠️ À Retenir Absolument

> [!warning] Pièges Classiques
> - $u_n \to 0$ **ne suffit pas** pour conclure que $\sum u_n$ converge : la **série harmonique** $\sum \frac{1}{n}$ diverge !
> - Quand D'Alembert ou Cauchy donne $\ell = 1$, on ne peut **rien conclure** — il faut utiliser un autre critère.
> - La somme de deux séries divergentes peut converger (ex : $\sum (-1)$ et $\sum 1$). En revanche, une convergente + une divergente = **toujours divergente**.
> - Le **théorème de réarrangement de Riemann** : pour une série **semi-convergente**, un réarrangement des termes peut donner n'importe quelle valeur (ou même $\pm\infty$) ! Une série **absolument convergente** est stable par réarrangement.

> [!important] Critère de Leibniz — Conditions à vérifier
> Pour appliquer Leibniz à $\sum (-1)^n a_n$ (avec $a_n \geq 0$), il faut **deux conditions** :
> 1. $(a_n)$ est **décroissante** (à partir d'un certain rang)
> 2. $a_n \to 0$
>
> Si ces deux conditions sont remplies → convergence + $|R_n| \leq a_{n+1}$

> [!important] Convergence Absolue
> $$\sum |u_n| \text{ converge} \Rightarrow \sum u_n \text{ converge}$$
> La réciproque est **fausse** : $\sum \frac{(-1)^n}{n}$ converge (Leibniz) mais $\sum \frac{1}{n}$ diverge.

> [!warning] Règle d'Alembert et Cauchy — Cas $\ell = 1$
> Si $\frac{u_{n+1}}{u_n} \to 1$ ou $\sqrt[n]{u_n} \to 1$, ces règles sont **inconclulsives**.
> Exemples : $\sum \frac{1}{n}$ (diverge) et $\sum \frac{1}{n^2}$ (converge) donnent toutes les deux $\ell = 1$.

---

## 🌳 Méthode / Arbre de Décision

### Étape 0 — Vérification préalable
- Calculer $\lim u_n$
  - Si $u_n \not\to 0$ → **diverge** (C.N.C.)
  - Si $u_n \to 0$ → continuer (rien conclu)

### Étape 1 — Identifier la nature des termes

**Cas A : Termes de signe constant ($u_n \geq 0$ à partir d'un rang)**
1. Chercher un **équivalent simple** : $u_n \sim \frac{c}{n^\alpha}$
   - Si $\alpha > 1$ → **converge** (Riemann)
   - Si $\alpha \leq 1$ → **diverge** (Riemann)
2. Si pas d'équivalent simple : essayer **D'Alembert** $\frac{u_{n+1}}{u_n} \to \ell$
   - $\ell < 1$ → converge
   - $\ell > 1$ → diverge
   - $\ell = 1$ → essayer autre chose
3. Si D'Alembert inconclus : essayer **Cauchy** $\sqrt[n]{u_n} \to \ell$ (mêmes conclusions)
4. Si tout échoue : **comparaison directe** avec une série connue

**Cas B : Série alternée $\sum (-1)^n a_n$ avec $a_n \geq 0$**
1. Vérifier **convergence absolue** $\sum a_n$ : si converge → converge absolument
2. Sinon, appliquer **Leibniz** : $(a_n)$ décroissante et $a_n \to 0$ → converge (semi-convergente)
3. Sinon : étude cas par cas

**Cas C : Termes quelconques de signe variable**
1. Tenter **convergence absolue** $\sum |u_n|$
2. Décomposer $u_n = u_n^+ - u_n^-$ et étudier chaque partie
3. Rechercher si la série est alternée → Leibniz

### Résumé visuel

```
u_n → 0 ?
   └── Non → DIVERGE
   └── Oui → continuer
         |
         ├── u_n ≥ 0 ?
         │     ├── Équivalent ~ 1/n^α → Riemann (α > 1 ?)
         │     ├── D'Alembert / Cauchy → ℓ ≠ 1 ?
         │     └── Comparaison directe
         │
         ├── Alternée (-1)^n aₙ ?
         │     ├── Σ|uₙ| converge → converge absolument
         │     └── Leibniz (aₙ décroissante, → 0)
         │
         └── Quelconque → Σ|uₙ| puis décomposition u⁺/u⁻
```

---

## 💡 Exemples Clés

### Exemple 1 — Série géométrique
$$\sum_{n=0}^{+\infty} \left(\frac{2}{3}\right)^n \quad \text{converge car } \left|\frac{2}{3}\right| < 1 \quad \text{Somme} = \frac{1}{1 - \frac{2}{3}} = 3$$

### Exemple 2 — Série harmonique (piège classique)
$$\sum_{n=1}^{+\infty} \frac{1}{n} \quad \text{diverge (Riemann, } \alpha = 1\text{) bien que } \frac{1}{n} \to 0$$

### Exemple 3 — Série de Riemann
$$\sum_{n=1}^{+\infty} \frac{1}{n^2} \quad \text{converge (} \alpha = 2 > 1\text{)} \qquad \sum_{n=1}^{+\infty} \frac{1}{n^{1/2}} \quad \text{diverge (} \alpha = \frac{1}{2} \leq 1\text{)}$$

### Exemple 4 — D'Alembert
$$\sum_{n=0}^{+\infty} \frac{n!}{n^n} \qquad \frac{u_{n+1}}{u_n} = \frac{(n+1)!}{(n+1)^{n+1}} \cdot \frac{n^n}{n!} = \left(\frac{n}{n+1}\right)^n \to \frac{1}{e} < 1 \Rightarrow \text{converge}$$

### Exemple 5 — Critère de Leibniz
$$\sum_{n=1}^{+\infty} \frac{(-1)^n}{n} \quad : a_n = \frac{1}{n} \text{ décroissante} \to 0 \Rightarrow \text{converge (semi-convergente)}$$
$$|R_n| \leq a_{n+1} = \frac{1}{n+1}$$

### Exemple 6 — Équivalent et comparaison
$$u_n = \frac{n^2 + 1}{n^4 + n + 2} \sim \frac{n^2}{n^4} = \frac{1}{n^2} \quad (\alpha = 2 > 1) \Rightarrow \sum u_n \text{ converge}$$

### Exemple 7 — Convergence absolue
$$\sum_{n=1}^{+\infty} \frac{\cos(n)}{n^2} \quad : \left|\frac{\cos(n)}{n^2}\right| \leq \frac{1}{n^2} \text{ et } \sum \frac{1}{n^2} \text{ converge} \Rightarrow \text{converge absolument}$$

### Exemple 8 — Télescopage
$$\sum_{n=1}^{+\infty} \left(\frac{1}{n} - \frac{1}{n+1}\right) = \lim_{n\to+\infty} \left(1 - \frac{1}{n+1}\right) = 1 \quad \text{(série télescopique, converge)}$$

---

## ❓ Questions de Révision

1. **Quelle est la condition nécessaire de convergence d'une série $\sum u_n$ ? Pourquoi n'est-elle pas suffisante ? Donner un contre-exemple.**

2. **Énoncer la règle de d'Alembert. Que peut-on conclure si la limite vaut exactement $1$ ?**

3. **Démontrer que $\sum \frac{1}{n}$ diverge** (indication : regrouper les termes ou utiliser la comparaison avec une intégrale).

4. **Énoncer le critère de Leibniz. Quelles sont les deux hypothèses indispensables ? Quel est le contrôle du reste ?**

5. **Quelle est la différence entre convergence absolue et semi-convergence ? Donner un exemple de série semi-convergente.**

6. **Énoncer le théorème de réarrangement de Riemann. Pourquoi est-il surprenant ?**

7. **Pour quelle(s) valeur(s) de $\alpha$ la série $\sum \frac{(-1)^n}{n^\alpha}$ converge-t-elle ? Justifier.**

8. **Étudier la convergence de $\sum \frac{n^3 + 2n}{n^5 - 1}$** (chercher un équivalent).

9. **Soit $\sum u_n$ une série convergente et $\sum v_n$ une série divergente. Que peut-on dire de $\sum (u_n + v_n)$ ? Démontrer le résultat.**

10. **Expliquer pourquoi D'Alembert et Cauchy donnent le même résultat en général, et dans quel cas l'un peut être préférable à l'autre.**

---

## 🔗 Voir aussi

- [[Bienvenue]]
- [[Maths/README]]

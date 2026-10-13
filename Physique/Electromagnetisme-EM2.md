---
title: "Synthèse Électrostatique & Magnétostatique (EM2)"
matiere: "Physique"
date: "2026-10-11"
tags: [fiche, revision, physique, electromagnetisme, gauss, amperes, coulomb, epita, s3]
source: "EPITA S3 FISE 2030 – Électrostatique et Magnétostatique (Cours_EM2)"
---

# ⚡ Électrostatique et Magnétostatique (EM2)

> **Matière :** Physique S3 (EPITA Promo 2030)  
> **Module :** `Physique : Électrostatique et Magnétostatique, ondes électromagnétiques`  
> **Fichiers sources Moodle :** `cours_em2.pdf`, `fiche_coordonnees.pdf`, `td1_corrige.pdf`, `td2_corrige.pdf`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Passage Discret $\to$ Continu :**
   - Discret : Champ $\vec{E}(M) = \frac{1}{4\pi\varepsilon_0} \sum_i \frac{q_i}{PM_i^2} \vec{u}_{P_i M}$.
   - Continu volumique ($\rho$), surfacique ($\sigma$), linéique ($\lambda$) :
     $$\vec{E}(M) = \frac{1}{4\pi\varepsilon_0} \iiint \frac{\rho(P)}{PM^2} \vec{u}_{PM} \, \mathrm{d}\tau$$
2. **Invariances et Symétries (Étapes incontournables avant tout calcul) :**
   - **Invariance par translation / rotation :** Réduit le nombre de variables dont dépend le champ (ex: invariance selon $z$ et $\theta \implies \vec{E}(M) = \vec{E}(r)$).
   - **Plan de symétrie de la distribution ($\Pi_s$) :** Le champ électrique en tout point du plan appartient au plan $\vec{E}(M) \in \Pi_s$. Le champ magnétique $\vec{B}(M)$ est orthogonal à ce plan.
   - **Plan d'antisymétrie ($\Pi_a$) :** Le champ électrique $\vec{E}(M)$ est **orthogonal** à $\Pi_a$. Le champ magnétique $\vec{B}(M)$ appartient au plan.
3. **Théorème de Gauss (Électrostatique) :**
   $$\Phi_E = \oiint_{\Sigma} \vec{E} \cdot \mathrm{d}\vec{S} = \frac{Q_{\text{int}}}{\varepsilon_0}$$
   - Permet de calculer $\vec{E}$ sans intégration compliquée si la géométrie admet de fortes symétries (sphère, cylindre infini, plan infini).
4. **Potentiel Électrostatique :**
   - Relation fondamentale : $\vec{E} = -\vec{\nabla} V = -\mathbf{grad}(V)$.
   - Circulation conservative : $\int_A^B \vec{E} \cdot \mathrm{d}\vec{\ell} = V(A) - V(B)$.
5. **Théorème d'Ampère (Magnétostatique) :**
   $$\oint_{\mathcal{C}} \vec{B} \cdot \mathrm{d}\vec{\ell} = \mu_0 I_{\text{enlacé}}$$

---

## 📐 1. Systèmes de Coordonnées & Éléments Différentiels

| Système | Variables | Déplacement élémentaire $\mathrm{d}\vec{\ell}$ | Surface élémentaire $\mathrm{d}\vec{S}$ | Volume élémentaire $\mathrm{d}\tau$ |
| :--- | :---: | :--- | :--- | :--- |
| **Cartésien** | $(x, y, z)$ | $\mathrm{d}x\,\vec{u}_x + \mathrm{d}y\,\vec{u}_y + \mathrm{d}z\,\vec{u}_z$ | $\mathrm{d}x\mathrm{d}y\,\vec{u}_z$ (plan $xy$) | $\mathrm{d}x\,\mathrm{d}y\,\mathrm{d}z$ |
| **Cylindrique** | $(r, \theta, z)$ | $\mathrm{d}r\,\vec{u}_r + r\mathrm{d}\theta\,\vec{u}_\theta + \mathrm{d}z\,\vec{u}_z$ | $r\,\mathrm{d}\theta\,\mathrm{d}z\,\vec{u}_r$ (surface latérale) | $r\,\mathrm{d}r\,\mathrm{d}\theta\,\mathrm{d}z$ |
| **Sphérique** | $(r, \theta, \varphi)$ | $\mathrm{d}r\,\vec{u}_r + r\mathrm{d}\theta\,\vec{u}_\theta + r\sin\theta\mathrm{d}\varphi\,\vec{u}_\varphi$ | $r^2\sin\theta\,\mathrm{d}\theta\,\mathrm{d}\varphi\,\vec{u}_r$ (sphère) | $r^2\sin\theta\,\mathrm{d}r\,\mathrm{d}\theta\,\mathrm{d}\varphi$ |

---

## ⚡ 2. Méthode pour appliquer le Théorème de Gauss

1. **Étude des invariances :** Trouver de quelles coordonnées spatiales dépend $\vec{E}$ (ex: cylindre infini $\implies$ invariant par $z$ et $\theta \implies \vec{E} = E(r) \vec{u}_r$).
2. **Étude des symétries :** Montrer que le champ est purement radial.
3. **Choix de la surface de Gauss fermée $\Sigma$ :** Choisir une surface fermée respectant la symétrie (cylindre fermé de rayon $r$ et hauteur $h$).
4. **Calcul du flux :**
   $$\Phi_E = \iint_{\text{latérale}} \vec{E} \cdot \mathrm{d}\vec{S} + \iint_{\text{bases}} \vec{E} \cdot \mathrm{d}\vec{S} = E(r) \cdot (2\pi r h) + 0 = 2\pi r h E(r)$$
5. **Calcul de la charge intérieure $Q_{\text{int}}$ :**
   - Si $r < R$ (intérieur) : $Q_{\text{int}} = \iiint \rho \,\mathrm{d}\tau = \rho \cdot \pi r^2 h$.
   - Si $r > R$ (extérieur) : $Q_{\text{int}} = \rho \cdot \pi R^2 h$.
6. **Égalité et déduction de $E(r)$ :**
   $$E(r < R) = \frac{\rho r}{2\varepsilon_0}, \quad E(r > R) = \frac{\rho R^2}{2\varepsilon_0 r}$$

---

## 🧲 3. Théorème d'Ampère en Magnétostatique

- **Champ créé par un fil infini parcouru par un courant $I$ :**
  $$\vec{B}(r) = \frac{\mu_0 I}{2\pi r} \vec{u}_\theta$$
- **Champ dans un solénoïde infini ($n$ spires par mètre) :**
  $$\vec{B}_{\text{int}} = \mu_0 n I \vec{u}_z, \quad \vec{B}_{\text{ext}} = \vec{0}$$

---

## ❓ Questions Types d'Examen

1. **Pourquoi le champ électrique est-il nul à l'intérieur d'un conducteur parfait à l'équilibre ?**
   - Si $\vec{E} \neq \vec{0}$, les charges libres se déplaceraient sous l'effet de la force de Coulomb $\vec{F} = q\vec{E}$, ce qui contredirait l'état d'équilibre électrostatique.
2. **Que vaut le saut de champ électrique à la traversée d'une surface chargée uniformément avec $\sigma$ ?**
   - $\vec{E}_2 - \vec{E}_1 = \frac{\sigma}{\varepsilon_0} \vec{n}_{1\to 2}$ (continuité de la composante tangentielle, discontinuité de la composante normale).

---
*Index général : [[Physique/README]]* | *Accueil : [[Bienvenue]]*

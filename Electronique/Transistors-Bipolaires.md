---
title: "Synthèse Les Transistors Bipolaires"
matiere: "Electronique"
date: "2026-10-11"
tags: [fiche, revision, electronique, transistors, bjt, polarisation, amplification, epita, s3]
source: "EPITA S3 FISE 2030 – [Elec] Transistors (cours_transistors_bipolaires.pdf)"
---

# 🔌 Les Transistors Bipolaires (BJT)

> **Matière :** Électronique S3 (EPITA Promo 2030)  
> **Module :** `[Elec] Transistors`  
> **Fichiers sources Moodle :** `cours_transistors_bipolaires.pdf`, `td_transistors_bipolaires.pdf`

---

## 🎯 Ce qu'il faut absolument retenir

1. **Structure physique & Jonctions :**
   - Transistor NPN (le plus courant) et PNP.
   - 3 électrodes : **Base (B)**, **Collecteur (C)**, **Émetteur (E)**.
   - Loi des nœuds fondamentale : $I_E = I_B + I_C$.
   - Tension seuil de la jonction Base-Émetteur passante : $V_{BE} \approx 0.7\text{ V}$.
2. **Les 3 Régimes de fonctionnement fondamentaux :**
   - **Régime Bloqué :** $I_B = 0 \implies I_C = 0$. Le transistor se comporte comme un **interrupteur ouvert** entre C et E ($V_{CE} = V_{CC}$).
   - **Régime Linéaire (Actif direct) :**
     - Relation de gain en courant : **$I_C = \beta \cdot I_B$** (ou $h_{FE}$).
     - Comme $\beta \gg 1$ (généralement $100$ à $300$), un faible courant de base commande un fort courant collecteur $\implies$ **Amplification de signal**.
     - Condition de régime linéaire : $V_{CE} > V_{CE,\text{sat}} \approx 0.2\text{ V}$.
   - **Régime Saturé :**
     - $I_B > \frac{I_{C,\text{sat}}}{\beta}$. Le courant $I_C$ est limité par le circuit extérieur et ne dépend plus de $I_B$.
     - $V_{CE} = V_{CE,\text{sat}} \approx 0.2\text{ V}$. Le transistor se comporte comme un **interrupteur fermé**.
3. **Point de fonctionnement au repos $(I_{C0}, V_{CE0})$ :**
   - Déterminé par la droite de charge statique et la polarisation de base.
   - En commutation (logique numérique, commande de relais/LED) : on alterne entre **Blocage** et **Saturation**.
   - En amplification linéaire (audio, capteurs) : on polarise le point de repos au milieu de la droite de charge pour maximiser l'excursion sans distorsion ni écrêtage.

---

## 📊 1. Tableau Comparatif des Régimes de Fonctionnement

| Régime | Conditions sur les grandeurs | Relations entre courants | Schéma équivalent C-E |
| :--- | :--- | :--- | :--- |
| **Bloqué (Off)** | $V_{BE} < 0.7\text{ V}$ ou $I_B = 0$ | $I_B = 0, \quad I_C = 0, \quad I_E = 0$ | Interrupteur ouvert |
| **Linéaire / Actif** | $V_{BE} = 0.7\text{ V}$ et $V_{CE} > 0.2\text{ V}$ | $I_C = \beta I_B, \quad I_E \approx I_C$ | Source de courant liée $I_C = \beta I_B$ |
| **Saturé (On)** | $I_B \ge I_{B,\text{sat}} = \frac{I_{C,\text{sat}}}{\beta}$ | $I_C = \frac{V_{CC} - V_{CE,\text{sat}}}{R_C} < \beta I_B$ | Interrupteur fermé ($V_{CE} \approx 0.2\text{ V}$) |

---

## ⚡ 2. Méthode d'analyse d'un étage émetteur commun

Soit un montage polarisé par résistance de base $R_B$ et résistance de charge $R_C$ sous alimentation $V_{CC}$ :

1. **Maille d'entrée (Base-Émetteur) :**
   $$V_{CC} - R_B I_B - V_{BE} = 0 \implies I_B = \frac{V_{CC} - V_{BE}}{R_B}$$
2. **Maille de sortie (Collecteur-Émetteur) - Droite de charge statique :**
   $$V_{CC} - R_C I_C - V_{CE} = 0 \implies V_{CE} = V_{CC} - R_C I_C$$
3. **Calcul de $I_{C,\text{sat}}$ :**
   $$I_{C,\text{sat}} = \frac{V_{CC} - V_{CE,\text{sat}}}{R_C}$$
4. **Conclusion du régime :**
   - Si $\beta I_B < I_{C,\text{sat}} \implies$ **Régime Linéaire** : $I_C = \beta I_B$ et $V_{CE} = V_{CC} - R_C (\beta I_B)$.
   - Si $\beta I_B \ge I_{C,\text{sat}} \implies$ **Régime Saturé** : $I_C = I_{C,\text{sat}}$ et $V_{CE} = 0.2\text{ V}$.

---

## 💡 3. Applications Numériques & Commutateurs de Puissance

- **Commande d'une LED ou d'un moteur par microcontrôleur (3.3V / 5V) :**
  - Un GPIO de microcontrôleur ne peut fournir que 10 à 20 mA.
  - Le transistor bipolaire sert d'interface de puissance en saturation :
    $$R_B \le \frac{V_{\text{GPIO}} - 0.7}{\frac{I_{\text{charge}}}{\beta_{\text{min}}}} \times k_{\text{sur}}$$
    (avec un coefficient de sursaturation de sécurité $k_{\text{sur}} \approx 2$ à $3$).

---

## ❓ Questions Types d'Examen

1. **Pourquoi $I_E$ est-il quasiment égal à $I_C$ en régime linéaire ?**
   - Parce que $I_E = I_B + I_C = \left(1 + \frac{1}{\beta}\right) I_C$. Comme $\beta \ge 100$, $\frac{1}{\beta} \le 0.01$, soit une différence de moins de 1%.
2. **Quel est le risque si le point de repos d'un amplificateur est trop proche de $V_{CC}$ ?**
   - Le signal d'alternance positive va être écrêté au niveau de $V_{CC}$ car le transistor va entrer en zone de blocage.

---
*Index général : [[Electronique/README]]* | *Accueil : [[Bienvenue]]*

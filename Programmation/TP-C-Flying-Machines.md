---
title: "Synthèse TP C S3 — Flying Machines (Structures, I/O & Modélisation)"
matiere: "Programmation"
date: "2026-10-12"
tags: [fiche, revision, programmation, c, epita, s3, bimestriel-5, io, structures, math]
source: "EPITA S3 FISE 2030 – Programmation Avancée en C (PROG-205 P-02)"
---

# ✈️ TP Flying Machines : Entrées/Sorties, Parsing & Modélisation en C

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Bimestre 5 — Projet `flying_machines` (`prog-205-p-02`)  
> **Concepts clés :** `stdio.h`, parsing de fichiers structurés (`fgets`, `strchr`, `strtod`), manipulation de chaînes sécurisée (`snprintf`), encapsulation et intégration de bibliothèques statiques tierces (`libporco.a`, `libhangar.a`).

---

## 🎯 Ce qu'il faut absolument retenir

1. **Lecture et Parsing robuste de fichiers texte :**
   - Utilisation systématique de `fgets(buf, sizeof(buf), f)` (évite les buffer overflows de `gets` ou `fscanf` non borné).
   - Découpage par délimiteur via `strchr(buf, ';')` : substitution par `'\0'` pour isoler le champ gauche, puis passage du pointeur au caractère suivant `p + 1`.
   - Conversion numérique fiable avec `strtod(str, &endptr)` : vérification obligatoire que `endptr != str` pour valider qu'un nombre a bien été lu.
2. **Génération de chaînes formatées et allocation dynamique :**
   - Règle d'or avec `snprintf` : appeler d'abord ou utiliser un buffer temporaire pour récupérer la taille exacte nécessaire :
     ```c
     int len = snprintf(NULL, 0, format, ...);
     char *str = malloc(len + 1);
     snprintf(str, len + 1, format, ...);
     ```
   - Vérifier scrupuleusement les retours d'allocation (`malloc == NULL`).
3. **Contrat d'API et Bibliothèques Statiques (`libporco.a`, `libhangar.a`) :**
   - Ne jamais tenter de réimplémenter ou de modifier les symboles fournis en bibliothèque fermée.
   - Respecter les sentinelles de retour : `porco_knots_to_ms` renvoie `-1.0` si négatif, `porco_parse_code` renvoie `-1` si code invalide.
   - Les chaînes renvoyées par des bibliothèques (`porco_machine_class`) sont en lecture seule (mémoire statique) : **ne jamais faire `free()` dessus**.
4. **Calculs balistiques et flottants (`math.h`) :**
   - Attention aux conversions d'unités : les fonctions trigonométriques du C (`sin`, `cos`) exigent des **radians**.
   - Conversion : $\text{rad} = \text{deg} \times \frac{\pi}{180}$ (avec `M_PI` issu de `#define _USE_MATH_DEFINES`).

---

## 🛠️ 1. Architecture du Projet

Le projet est divisé en deux sous-systèmes :
- **`fundamentals/`** :
  - `physics.c` : Calculs cinématiques (vitesse $V_x, V_y$, portée, flèche $H_{\text{max}}$, temps de vol).
  - `records.c` : Lecture de catalogues de machines (`inventory.txt`), conversion d'unités (nœuds vers m/s) et écriture de fiches descriptives formatées.
  - `report.c` : Génération de comptes-rendus de vol et export filtré selon un seuil d'altitude.
- **`proficiencies/`** :
  - `hangar.h` / `libhangar.a` : Manipulation de conteneurs génériques opaques (`HangarList`), tri par fonction de comparaison (`qsort`-like), gestion du cycle de vie mémoire avec destructeurs personnalisés.
  - `matching.c` & `simulation.c` : Appariement machines / missions selon les contraintes environnementales.

---

## 🔍 2. Techniques de Code Clés & Bonnes Pratiques

### A. Parsing sans crash d'un fichier CSV/DSV (Délimiteur `;`)
```c
double total_declared_speed(const char *filepath) {
    FILE *f = fopen(filepath, "r");
    if (!f)
        return -1.0;

    char buf[256];
    double total = 0.0;

    while (fgets(buf, sizeof(buf), f)) {
        char *sep = strchr(buf, ';');
        if (!sep)
            continue; // Ligne malformée, on ignore

        char *end;
        double knots = strtod(sep + 1, &end);
        if (end != sep + 1) { // Vérifie qu'au moins un chiffre a été consommé
            double ms = porco_knots_to_ms(knots);
            if (ms >= 0.0)
                total += ms;
        }
    }
    fclose(f);
    return total;
}
```

### B. Écriture sécurisée de rapports formatés
```c
int write_machine_cards(const char *in_path, const char *out_path) {
    FILE *in = fopen(in_path, "r");
    if (!in) return -1;

    FILE *out = fopen(out_path, "w");
    if (!out) {
        fclose(in);
        return -1;
    }

    char buf[256];
    while (fgets(buf, sizeof(buf), in)) {
        char *sep = strchr(buf, ';');
        if (!sep) continue;

        *sep = '\0'; // Coupe la chaîne en place pour isoler le nom
        char *name = buf;
        char *speed_str = sep + 1;

        char *end;
        double knots = strtod(speed_str, &end);
        if (end == speed_str) continue;

        double speed_ms = porco_knots_to_ms(knots);
        const char *classe = porco_machine_class(speed_ms);

        fprintf(out, "%s | %.2f m/s | %s\n", name, speed_ms, classe);
    }

    fclose(in);
    fclose(out);
    return 0;
}
```

---

## ⚠️ Pièges Classiques Rencontrés

| Piège | Conséquence | Solution |
| :--- | :--- | :--- |
| Oubli de `fclose(f)` en cas d'erreur prématurée | Fuite de descripteur de fichier (*file descriptor leak*) | Toujours fermer les fichiers ouverts avant tout `return -1`. |
| Oubli du `+ 1` pour le caractère nul `'\0'` lors d'un `malloc` | Débordement mémoire d'un octet (*off-by-one heap overflow*) | Allouer systématiquement `strlen(s) + 1` ou `len_snprintf + 1`. |
| Passer des degrés à `sin()` ou `cos()` | Résultats balistiques complètement faux | Convertir impérativement en radians : `angle * (M_PI / 180.0)`. |
| `free()` sur une chaîne constante statique | *Invalid free / Segmentation fault* | Ne libérer que la mémoire obtenue via `malloc`, `calloc` ou `realloc`. |

---

## ❓ Questions de Révision

1. **Pourquoi préfère-t-on `strtod` à `atof` dans du code C robuste ?**
   - `atof` ne fournit aucun moyen de savoir si la conversion a échoué ou si la chaîne contenait zéro (`0.0`). `strtod` fournit `endptr`, permettant de valider les caractères effectivement lus.
2. **Comment `snprintf` protège-t-il contre les débordements de tampon par rapport à `sprintf` ?**
   - `snprintf` prend en paramètre la taille maximale du tampon `size` et garantit qu'il n'écrira jamais au-delà, tout en garantissant la présence du caractère nul terminateur.
3. **Quel est le rôle d'un pointeur de fonction `HangarDestroyFn` passé à un conteneur générique ?**
   - Permettre au conteneur de libérer la mémoire interne allouée dynamiquement par chaque élément lors de la destruction du conteneur sans avoir à connaître la structure interne de l'élément.

---
*Index général : [[Programmation/README]]* | *Accueil : [[Bienvenue]]*

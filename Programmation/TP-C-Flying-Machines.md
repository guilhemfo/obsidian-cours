---
title: "Synthèse TP C S3 — Flying Machines (Entrées/Sorties, Parsing & Structures)"
matiere: "Programmation"
date: "2026-10-12"
tags: [fiche, revision, programmation, c, epita, s3, bimestriel-5, io, parsing, structures]
source: "EPITA S3 FISE 2030 – Programmation Avancée en C (PROG-205 P-02)"
---

# ✈️ TP Flying Machines : Entrées/Sorties, Parsing Robuste & Modélisation en C

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Bimestre 5 — Projet `flying_machines` (`prog-205-p-02`)

---

## 🎯 Points Clés

- Parsing sécurisé de données tabulaires (CSV/DSV) sans débordement de tampon mémoire.
- Différence cruciale entre conversion de données fragile (`atoi`, `atof`) et robuste (`strtod`, `strtol`).
- Dimensionnement exact de tampons dynamiques avec `snprintf(NULL, 0, ...)` et `malloc`.
- Intégration de bibliothèques tierces compilées (`.a`) avec respect des contrats d'API et de la gestion de mémoire statique vs dynamique.

---

## 📖 Cours & Fonctions Détaillées

### 1. `fgets` — Lecture sécurisée de flux ligne par ligne

#### 🔍 Définition formelle & Fonctionnement interne
```c
char *fgets(char *s, int size, FILE *stream);
```
`fgets` lit des caractères depuis le flux `stream` et les stocke dans le tableau `s` jusqu'à rencontrer un caractère de saut de ligne (`\n`), la fin de fichier (`EOF`), ou jusqu'à avoir lu au maximum `size - 1` caractères. Il ajoute **toujours** un caractère nul `'\0'` final. Si la ligne est lue en entier, le `\n` est conservé dans `s`.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
En C, utiliser `gets()` est une faille de sécurité critique car il n'impose aucune limite de taille (provoquant des attaques par buffer overflow). De même, `fscanf(f, "%s", ...)` ne s'arrête pas au bout de la ligne et déborde si le mot est trop long.  
`fgets` est l'outil standard pour charger des fichiers texte ligne par ligne de manière prédictible et bornée en mémoire.

#### 💻 Exemple concret
```c
FILE *f = fopen("inventory.txt", "r");
if (!f) return -1;

char buffer[256];
// On lit au maximum 255 caractères par itération
while (fgets(buffer, sizeof(buffer), f) != NULL) {
    // buffer contient une ligne complète terminée par '\n\0'
    printf("Ligne lue : %s", buffer);
}
fclose(f);
```

---

### 2. `strchr` — Recherche et scission de chaînes en place

#### 🔍 Définition formelle & Fonctionnement interne
```c
char *strchr(const char *s, int c);
```
Parcourt la chaîne `s` jusqu'à trouver la première occurrence de l'octet `c` (converti en `char`) ou le caractère nul `'\0'`. Renvoie un pointeur direct vers cet emplacement dans `s`, ou `NULL` si le caractère est absent.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Idéal pour parser des formats à séparateurs (ex: fichiers CSV avec virgules `,` ou points-virgules `;`). Plutôt que de réallouer de la mémoire avec `strtok` (qui n'est pas thread-safe) ou des copies manuelles, on remplace le délimiteur directement par `'\0'`. La chaîne d'origine est ainsi découpée en deux sous-chaînes instantanément en mémoire sans allocation supplémentaire ($\mathcal{O}(1)$ en espace).

#### 💻 Exemple concret
```c
// Ligne lue : "Savoia S.21;85.50\n"
char *sep = strchr(buffer, ';');
if (sep != NULL) {
    *sep = '\0';            // Remplace ';' par '\0'
    char *nom = buffer;     // "Savoia S.21"
    char *vitesse = sep + 1; // "85.50\n"
}
```

---

### 3. `strtod` — Conversion numérique rigoureuse avec validation

#### 🔍 Définition formelle & Fonctionnement interne
```c
double strtod(const char *nptr, char **endptr);
```
Convertit la portion initiale de la chaîne `nptr` en un nombre flottant `double`. Ignore les espaces initiaux, lit les chiffres, points et exposants. Si `endptr` n'est pas `NULL`, `strtod` y stocke l'adresse du **premier caractère non consommé**.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
`atof("abc")` renvoie `0.0`, tout comme `atof("0.0")`. Il est donc impossible de savoir si la donnée était réellement zéro ou si le texte était corrompu !  
Avec `strtod`, si `endptr == nptr`, cela prouve qu'**aucun chiffre n'a pu être lu**. Si `endptr != nptr`, la conversion est valide.

#### 💻 Exemple concret
```c
char *vitesse_str = "120.45 knots";
char *end;
double knots = strtod(vitesse_str, &end);

if (end == vitesse_str) {
    // Échec de conversion : la chaîne ne commence pas par un nombre
    fprintf(stderr, "Erreur : donnée invalide\n");
} else {
    // Succès : knots = 120.45, et *end pointe sur " knots"
    printf("Vitesse extraite : %.2f\n", knots);
}
```

---

### 4. `snprintf` — Formatage sécurisé & Dimensionnement dynamique

#### 🔍 Définition formelle & Fonctionnement interne
```c
int snprintf(char *str, size_t size, const char *format, ...);
```
Écrit au plus `size` octets (en incluant le `'\0'` final) dans `str`. **Valeur de retour clé :** renvoie le nombre total de caractères qui *auraient été écrits* si `size` avait été infinie (hors `'\0'`). Si la valeur retournée est $\ge size$, une troncature s'est produite.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Éviter les buffer overflows :** Remplace définitivement `sprintf` qui écrit aveuglément en mémoire.
2. **Dimensionner un `malloc` au juste octet :** En appelant `snprintf(NULL, 0, format, ...)`, la fonction ne modifie aucune mémoire mais renvoie la taille exacte nécessaire pour allouer la chaîne résultante.

#### 💻 Exemple concret (Pattern d'allocation dynamique parfaite)
```c
char *generate_flight_summary(double velocity, double angle_rad, const char *rating) {
    // 1. Calcul du nombre de caractères nécessaires
    int len = snprintf(NULL, 0, 
        "Vitesse: %.2f m/s, Angle: %.2f rad, Statut: %s.", 
        velocity, angle_rad, rating);

    if (len < 0) return NULL;

    // 2. Allocation exacte (+1 pour le '\0')
    char *result = malloc(len + 1);
    if (!result) return NULL;

    // 3. Écriture garantie sans débordement
    snprintf(result, len + 1, 
        "Vitesse: %.2f m/s, Angle: %.2f rad, Statut: %s.", 
        velocity, angle_rad, rating);

    return result; // L'appelant devra libérer cette mémoire
}
```

---

### 5. `M_PI` & Conversions Trigonométriques (`math.h`)

#### 🔍 Définition formelle & Fonctionnement interne
Les fonctions de la bibliothèque standard `math.h` (`sin`, `cos`, `tan`) attendent **exclusivement des angles en radians**. La constante $\pi$ est définie sous la macro `M_PI` (accessible avec `#define _USE_MATH_DEFINES` avant l'inclusion de `math.h`).

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Dans la plupart des spécifications, les angles de tir ou de vol sont fournis en degrés par l'utilisateur ou par des capteurs. Injecter directement des degrés dans `sin()` produit des résultats mathématiques aberrants.

#### 💻 Exemple concret
```c
#define _USE_MATH_DEFINES
#include <math.h>

double degrees_to_radians(double deg) {
    return deg * (M_PI / 180.0);
}

// Calcul de la portée maximale : R = (v^2 * sin(2*theta)) / g
double calculate_range(double velocity, double angle_deg) {
    double angle_rad = degrees_to_radians(angle_deg);
    return (velocity * velocity * sin(2.0 * angle_rad)) / 9.81;
}
```

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **Gestion des descripteurs de fichiers (`FILE *`) :**  
> Dès lors qu'un fichier a été ouvert avec `fopen`, chaque branche de code menant à un `return` d'erreur doit impérativement comporter un `fclose`. Sinon, le système d'exploitation épuise sa table de descripteurs de fichiers (*file descriptor leak*).

> [!warning]
> **Piège de propriété mémoire avec les bibliothèques tierces :**  
> Si une fonction de bibliothèque (comme `porco_machine_class`) retourne un `const char *`, cette chaîne réside dans la mémoire statique en lecture seule de la bibliothèque.  
> **Faire `free((char *)classe)` provoquera un crash instantané (`SIGSEGV` ou `free(): invalid pointer`).**

---

## ❓ Questions de Révision & Cas Pratiques

1. **Pourquoi `fgets` conserve-t-il le caractère `\n` dans son tampon, et comment le retirer proprement ?**
   - Il le conserve pour indiquer au programmeur que la ligne entière a été lue. Pour le retirer : `buffer[strcspn(buffer, "\n")] = '\0';`.
2. **Si `strtod` renvoie `0.0`, comment savoir si la chaîne contenait le chiffre zéro ou du texte invalide ?**
   - En vérifiant `endptr` : si `endptr != nptr`, la chaîne contenait bien un zéro valide ; si `endptr == nptr`, la conversion a échoué.
3. **À quoi sert le passage par `size_t element_size` dans un conteneur générique comme `hangar_create` ?**
   - Cela permet au conteneur de manipuler des éléments de n'importe quel type de données en effectuant des copies mémoires de taille arbitraire avec `memcpy`, rendant le conteneur totalement polymorphe.

---
*Fiche suivante : [[TP-C-Howls-Machine-SDL2]]*  
*Index général : [[Programmation/README]]*

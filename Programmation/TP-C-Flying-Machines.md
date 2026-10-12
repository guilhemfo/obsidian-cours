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

- Lecture et parsing sécurisé de fichiers tabulaires (CSV/DSV) sans risque de dépassement de tampon (*buffer overflow*).
- Différence fondamentale entre les fonctions historiques fragiles (`gets`, `atoi`, `atof`, `strtok`) et les standards robustes de l'industrie (`fgets`, `strtod`, `strtol`, `strcspn`).
- Allocation dynamique exacte au byte près via le mécanisme de pré-calcul de `snprintf(NULL, 0, ...)`.
- Intégration de bibliothèques tierces compilées (`.a`), gestion stricte des responsabilités mémoire (mémoire statique partagée vs mémoire tas *heap* allouée par l'appelant).
- Rigueur mathématique en C : manipulation trigonométrique sous `math.h` et conversions d'unités impératives (degrés $\to$ radians).

---

## 📖 Cours & Fonctions Détaillées

---

### 1. `fgets` — Lecture bornée et sécurisée d'un flux ligne par ligne

#### 🔍 Définition formelle & Fonctionnement interne
```c
char *fgets(char *s, int size, FILE *stream);
```
- **Rôle :** Lit des caractères consécutifs depuis le flux `stream` (`FILE *`) et les place dans le tableau `s`.
- **Mécanisme d'arrêt :** `fgets` s'arrête dès qu'une des 3 conditions est atteinte :
  1. Il a lu un caractère de saut de ligne (`\n`).
  2. Il atteint la fin du fichier (`EOF`).
  3. Il a lu $size - 1$ caractères.
- **Terminaison :** Il insère **toujours** le caractère nul terminal `'\0'` à la fin de la chaîne écrite.
- **Valeur de retour :** Renvoie le pointeur `s` en cas de succès, ou `NULL` en cas de fin de fichier (`EOF`) ou d'erreur de lecture.
- **Sous le capot :** Contrairement aux lectures caractère par caractère (`fgetc`), `fgets` exploite les mécanismes de mise en mémoire tampon (*buffering*) de la libc : les blocs de données sont transférés du disque vers la RAM par blocs (souvent 4096 octets), ce qui minimise le nombre d'appels système `read(2)` et optimise drastiquement les performances d'E/S.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
`fgets` est **le standard de l'industrie** pour lire des fichiers texte ligne par ligne ou pour capturer les saisies utilisateur depuis `stdin`.
- **Pourquoi pas `gets()` ?** `gets()` ne prend aucun paramètre de taille. Si l'utilisateur tape plus de caractères que la taille de votre tableau, les octets écrasent la pile d'exécution (*stack buffer overflow*), ce qui permet à un attaquant de modifier l'adresse de retour de la fonction pour exécuter du code malveillant. `gets` a d'ailleurs été **purement et simplement supprimé** de la norme C11.
- **Pourquoi pas `fscanf(f, "%s", buf)` ?** Par défaut, `%s` s'arrête au premier espace (pas à la fin de la ligne) et ne limite pas le nombre de caractères lus, ce qui provoque le même danger de dépassement de tampon que `gets`.
- **Cas d'usage fréquents :**
  1. Lire des fichiers de configuration (`.ini`, `.conf`).
  2. Parcourir des fichiers de données volumineux (CSV, logs système, traces réseau).
  3. Réceptionner des commandes saisies par l'utilisateur dans une invite de commande (CLI).

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <string.h>

int process_log_file(const char *filename) {
    // 1. Ouverture du fichier en lecture seule ("r" = read)
    FILE *f = fopen(filename, "r");
    if (f == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        return -1;
    }

    char buffer[256];
    int line_number = 1;

    // 2. Boucle de lecture : fgets renvoie NULL uniquement à l'EOF ou sur erreur
    while (fgets(buffer, sizeof(buffer), f) != NULL) {
        
        // Explication : fgets conserve le '\n' s'il a eu la place de le lire.
        // Pour nettoyer la chaîne et éviter un saut de ligne parasite lors de l'affichage,
        // on cherche l'indice du '\n' avec strcspn et on le remplace par '\0'.
        buffer[strcspn(buffer, "\n")] = '\0';

        printf("Ligne %03d : [%s]\n", line_number++, buffer);
    }

    // 3. Fermeture obligatoire du descripteur de fichier pour libérer les ressources OS
    fclose(f);
    return 0;
}
```
**Ce que fait ce code et pourquoi :**
- `sizeof(buffer)` est utilisé directement comme argument de taille : cela garantit qu'on ne dépassera jamais les 256 octets alloués sur la pile.
- La ligne `buffer[strcspn(buffer, "\n")] = '\0';` recherche le premier `\n` et coupe la chaîne à cet endroit précis. Si la ligne a été tronquée parce qu'elle faisait plus de 255 caractères, aucun `\n` n'est présent et `strcspn` renvoie l'indice du `'\0'` final, évitant tout comportement indéfini.

---

### 2. `strchr` — Recherche de caractère et découpage en place sans allocation

#### 🔍 Définition formelle & Fonctionnement interne
```c
char *strchr(const char *s, int c);
```
- **Rôle :** Recherche la première occurrence de l'octet `c` (converti en `char`) dans la chaîne pointée par `s`.
- **Valeur de retour :** Renvoie un pointeur vers le premier caractère correspondant dans `s`, ou `NULL` si le caractère n'apparaît nulle part. Le caractère nul `'\0'` est considéré comme faisant partie de la chaîne.
- **Fonctionnement interne :** La fonction effectue une comparaison séquentielle en mémoire $\mathcal{O}(L)$ (où $L$ est la longueur de la chaîne). Sur les processeurs modernes avec glibc, cette fonction est hautement optimisée en assembleur avec des instructions SIMD (AVX/SSE) pour analyser 16 ou 32 octets par cycle d'horloge.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Découpage en place (*In-place tokenization*) :**  
   Plutôt que d'allouer de nouveaux blocs de mémoire pour chaque mot ou d'utiliser `strtok` (qui maintient un état global statique et **n'est pas thread-safe**), `strchr` permet de localiser un délimiteur (virgule, point-virgule, tiret), de le remplacer temporairement par `'\0'`, créant ainsi instantanément deux sous-chaînes valides dans le même buffer initial. **Complexité mémoire : $\mathcal{O}(1)$ supplémentaire.**
2. **Extraction d'extensions de fichiers :**  
   Pour trouver l'extension d'un fichier (ex: chercher le dernier point avec `strrchr`), ou vérifier si un paramètre d'URL contient un point d'interrogation `?`.
3. **Validation de caractères :**  
   Vérifier si un caractère interdit est présent dans un identifiant ou un mot de passe.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <string.h>

void parse_csv_line(char *line) {
    // line vaut initialement : "Savoia S.21;142.80;FAST"
    
    // 1. Recherche du premier délimiteur ';'
    char *first_semi = strchr(line, ';');
    if (!first_semi) return;

    // 2. Découpage en place : on remplace le ';' par un octet nul
    *first_semi = '\0'; 
    // line est désormais la chaîne : "Savoia S.21"
    
    // 3. Le pointeur juste après pointe sur le reste de la ligne
    char *speed_str = first_semi + 1; // "142.80;FAST"

    // 4. Recherche du second délimiteur
    char *second_semi = strchr(speed_str, ';');
    if (second_semi) {
        *second_semi = '\0';
        char *category = second_semi + 1; // "FAST"
        
        printf("Machine : %s | Vitesse : %s | Classe : %s\n", line, speed_str, category);
    }
}
```
**Ce que fait ce code et pourquoi :**
- Aucun appel à `malloc` ni `strdup` : la manipulation s'exécute directement dans le tampon mémoire existant.
- Les pointeurs `line`, `speed_str` et `category` pointent tous les trois dans le même bloc de mémoire initial, devenant trois chaînes C indépendantes grâce aux `'\0'` insérés. C'est la méthode de parsing la plus rapide possible en langage C.

---

### 3. `strtod` / `strtol` — Conversion numérique rigoureuse avec contrôle d'erreur

#### 🔍 Définition formelle & Fonctionnement interne
```c
double strtod(const char *nptr, char **endptr);
long strtol(const char *nptr, char **endptr, int base);
```
- **Rôle :** Convertit une portion de texte en un nombre à virgule flottante (`double` pour `strtod`) ou en entier (`long` pour `strtol` en base $2$ à $36$).
- **Fonctionnement interne :**
  1. Ignore automatiquement les espaces blancs au début (`isspace()`).
  2. Parse le signe optionnel (`+` ou `-`).
  3. Lit la suite de chiffres (avec point décimal et notation exponentielle `e`/`E` pour `strtod`).
  4. S'arrête au **tout premier caractère non reconnu** dans le format du nombre.
  5. Si `endptr != NULL`, il assigne à `*endptr` l'adresse mémoire exacte de ce premier caractère non reconnu.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
- **Le problème critique de `atoi` et `atof` :**  
  Considérez l'appel `val = atof(texte);`.
  - Si `texte = "0.0"`, `val` vaudra `0.0`.
  - Si `texte = "avion"`, `val` vaudra également `0.0` !  
  Il est **strictement impossible** avec `atoi`/`atof` de faire la différence entre une vraie valeur zéro et une erreur de syntaxe. De plus, `atoi` a un comportement indéfini en cas de dépassement de capacité (*overflow*).
- **La supériorité de `strtod`/`strtol` :**
  En vérifiant si `endptr == nptr`, on détecte instantanément si la chaîne était invalide.
  De plus, `strtol` permet d'analyser des nombres en **hexadécimal** (`base 16`), en **binaire** (`base 2`) ou en **décimal** (`base 10`) avec détection d'overflow via la variable globale `errno` (`ERANGE`).

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int parse_measurement(const char *input, double *out_value) {
    char *endptr = NULL;
    errno = 0; // Réinitialisation impérative de la variable globale d'erreur

    // Tentative de conversion
    double val = strtod(input, &endptr);

    // Cas 1 : Aucun caractère numérique n'a pu être lu
    if (endptr == input) {
        fprintf(stderr, "Erreur : aucun chiffre trouvé dans '%s'\n", input);
        return 0; // Échec
    }

    // Cas 2 : La valeur dépasse la plage de représentation des doubles (Overflow / Underflow)
    if (errno == ERANGE) {
        fprintf(stderr, "Erreur : dépassement de capacité (overflow) pour '%s'\n", input);
        return 0;
    }

    // Cas 3 : Succès partiel ou total
    // On peut même vérifier s'il reste des caractères non lus après le nombre
    if (*endptr != '\0' && *endptr != '\n') {
        printf("Information : unité ou texte détecté après le nombre : '%s'\n", endptr);
    }

    *out_value = val;
    return 1; // Succès garanti
}
```
**Ce que fait ce code et pourquoi :**
- `errno = 0` avant l'appel est obligatoire car la bibliothèque standard ne remet jamais `errno` à zéro d'elle-même.
- Le test `endptr == input` est la signature d'un échec total de parsing : la chaîne ne commençait pas par un format numérique valide.
- `endptr` donne accès direct à l'unité (ex: si l'entrée est `"45.8 knots"`, `endptr` pointe directement sur `" knots"`).

---

### 4. `snprintf` — Formatage sécurisé & Pattern d'allocation dynamique exacte

#### 🔍 Définition formelle & Fonctionnement interne
```c
int snprintf(char *str, size_t size, const char *format, ...);
```
- **Rôle :** Formate une chaîne de caractères selon le gabarit `format` et écrit le résultat dans le tampon `str`.
- **Garantie matérielle :** N'écrit **jamais plus de `size` octets** en mémoire (octet nul terminal compris, à condition que `size > 0`).
- **Valeur de retour (Crucial) :** Renvoie le **nombre total de caractères qui auraient été écrits** si la taille avait été infinie (sans compter le `'\0'`).
  - Si le retour est $\ge size$, cela signifie que la chaîne a été **tronquée**.
  - Si le retour est $< 0$, une erreur d'encodage est survenue.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Remplacement obligatoire de `sprintf` :** `sprintf` n'a pas de paramètre de taille et provoque des corruptions de mémoire si la chaîne produite est plus longue que prévu.
2. **Le Pattern "Allocation Dynamique Parfaite" :**  
   En C, on se demande souvent : *"Combien d'octets dois-je allouer avec `malloc` pour formater ce message ?"*  
   Plutôt que d'allouer au hasard un tampon géant de 1024 octets (ce qui gaspille la RAM ou risque encore de déborder), on appelle `snprintf(NULL, 0, format, ...)`. Comme `size = 0`, la fonction n'écrit aucun octet en mémoire, mais calcule et renvoie la taille exacte requise ! On alloue ensuite exactement `retour + 1` octets.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <stdlib.h>

char *build_flight_summary(const char *pilot, double speed, double altitude, const char *status) {
    if (!pilot || !status) return NULL;

    // Étape 1 : Appel avec buffer NULL et taille 0 pour calculer la longueur exacte
    int required_len = snprintf(NULL, 0,
        "Pilote : %s | Vitesse : %.2f m/s | Altitude : %.2f m | Statut : [%s]",
        pilot, speed, altitude, status);

    if (required_len < 0) {
        return NULL; // Erreur de formatage
    }

    // Étape 2 : Allocation dynamique sur le tas (heap) au byte près (+1 pour le '\0')
    char *result_str = malloc((size_t)required_len + 1);
    if (result_str == NULL) {
        perror("Échec d'allocation mémoire");
        return NULL;
    }

    // Étape 3 : Écriture réelle garantie à 100% sans troncature ni débordement
    snprintf(result_str, (size_t)required_len + 1,
        "Pilote : %s | Vitesse : %.2f m/s | Altitude : %.2f m | Statut : [%s]",
        pilot, speed, altitude, status);

    return result_str; // La responsabilité de libérer (free) est transférée à l'appelant
}
```
**Ce que fait ce code et pourquoi :**
- L'appel `snprintf(NULL, 0, ...)` élimine tout risque d'estimation erronée : que le nom du pilote fasse 3 caractères ou 500 caractères, la mémoire allouée sera mathématiquement parfaite.
- `(size_t)required_len + 1` réserve exactement la place pour tous les caractères visibles plus l'octet nul de fin.

---

### 5. `math.h` — Rigueur cinématique et conversions trigonométriques

#### 🔍 Définition formelle & Fonctionnement interne
Les fonctions mathématiques en C (`sin`, `cos`, `tan`, `atan2`, `sqrt`) font partie de la bibliothèque mathématique standard liée à la compilation avec l'option `-lm`.
- **Règle absolue :** Toutes les fonctions trigonométriques du langage C prennent leurs arguments **en radians**, jamais en degrés.
- **La constante $\pi$ :** Elle est définie sous la macro `M_PI` (valeur $3.14159265358979323846$). Pour la rendre visible dans un code portable conforme POSIX, il est nécessaire de déclarer `#define _USE_MATH_DEFINES` avant toute inclusion de `<math.h>`.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
En ingénierie logicielle (robotique, aéronautique, jeux vidéo, simulation physique), les interfaces graphiques et les capteurs renvoient souvent des angles en degrés (de $0^\circ$ à $360^\circ$). Les injecter directement dans `sin()` ou `cos()` produit des trajectoires et des vitesses complètement fausses.

#### 💻 Exemple concret & Explication pas à pas
```c
#define _USE_MATH_DEFINES
#include <math.h>
#include <stdio.h>

// Définition de l'accélération de pesanteur terrestre standard
#define GRAVITY 9.81

typedef struct {
    double velocity;   // Vitesse initiale en m/s
    double angle_deg;  // Angle de tir en degrés
} LaunchParams;

// Fonction de conversion pure
static inline double to_radians(double degrees) {
    return degrees * (M_PI / 180.0);
}

// Calcul balistique complet d'un projectile
void simulate_trajectory(LaunchParams p, double *out_max_height, double *out_range, double *out_flight_time) {
    double angle_rad = to_radians(p.angle_deg);
    double sin_theta = sin(angle_rad);
    double cos_theta = cos(angle_rad);

    // Vitesse initiale selon les axes
    double vx = p.velocity * cos_theta;
    double vy = p.velocity * sin_theta;

    // 1. Temps de vol total : t = (2 * vy) / g
    *out_flight_time = (2.0 * vy) / GRAVITY;

    // 2. Hauteur maximale (Flèche) : H = (vy^2) / (2 * g)
    *out_max_height = (vy * vy) / (2.0 * GRAVITY);

    // 3. Portée horizontale : R = vx * t = (v^2 * sin(2*theta)) / g
    *out_range = (p.velocity * p.velocity * sin(2.0 * angle_rad)) / GRAVITY;
}
```
**Ce que fait ce code et pourquoi :**
- `to_radians` applique la bijection mathématique $\text{rad} = \text{deg} \times \frac{\pi}{180}$.
- `simulate_trajectory` utilise les équations différentielles de Newton intégrées pour un tir parabolique sans frottement. Les résultats sont renvoyés proprement par des pointeurs de sortie (*out parameters*), un idiome C classique.

---

### 6. Contrats d'API & Bibliothèques Statiques (`libporco.a`, `libhangar.a`)

#### 🔍 Définition formelle & Fonctionnement interne
Une bibliothèque statique (`.a` pour *archive*) est un ensemble de fichiers objets (`.o`) regroupés avec l'utilitaire `ar`. Lors de la phase d'édition de liens (*linking* via `gcc ... libporco.a`), le compilateur extrait les fonctions utilisées et les intègre directement dans le binaire final.
- Le développeur ne dispose que du fichier d'en-tête (`.h`) qui définit le **contrat d'interface** (types des paramètres, valeurs de retour, gestion des erreurs).

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Modularité et encapsulation :** Cacher l'implémentation interne (secret industriel, séparation des responsabilités entre équipes).
2. **Garantie d'invariance mémoire :** Si une fonction de bibliothèque renvoie `const char *porco_machine_class(...)`, cette chaîne est stockée dans le segment `.rodata` (données en lecture seule du binaire).
   - **Règle absolue :** Ne **jamais** appeler `free()` sur un pointeur retourné par une bibliothèque externe sauf si sa documentation stipule explicitement que l'objet a été alloué sur le tas et doit être libéré par l'appelant.

#### 💻 Exemple concret & Explication pas à pas
```c
#include "hangar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Structure métier définie par l'étudiant
typedef struct {
    char *name;         // Pointeur vers mémoire allouée dynamiquement
    double speed_ms;    // Scalaire direct
} PlaneRecord;

// Destructeur personnalisé : appelé par libhangar pour chaque élément détruit
void destroy_plane_record(void *element) {
    PlaneRecord *plane = (PlaneRecord *)element;
    if (plane->name) {
        free(plane->name); // Libération du champ alloué dynamiquement
        plane->name = NULL;
    }
}

// Fonction de comparaison pour trier par vitesse croissante (façon qsort)
int compare_planes_by_speed(const void *a, const void *b) {
    const PlaneRecord *p1 = (const PlaneRecord *)a;
    const PlaneRecord *p2 = (const PlaneRecord *)b;
    if (p1->speed_ms < p2->speed_ms) return -1;
    if (p1->speed_ms > p2->speed_ms) return 1;
    return 0;
}
```
**Ce que fait ce code et pourquoi :**
- `HangarList` est un conteneur générique (similaire à un `std::vector` en C++). Il ne connaît pas le type `PlaneRecord`.
- En lui passant le pointeur de fonction `destroy_plane_record`, on fournit au conteneur la procédure exacte pour nettoyer la mémoire profonde (`plane->name`) lors de la fermeture du hangar via `hangar_destroy(list);`.

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **La règle des descripteurs de fichiers :**  
> Dès lors qu'un fichier a été ouvert avec `fopen()`, tout chemin d'exécution (y compris les retours d'erreur prématurés) doit impérativement exécuter `fclose()`.  
> *Symptôme d'oubli :* Le programme fonctionne sur de petits tests, mais plante avec l'erreur `EMFILE` (*Too many open files*) lorsqu'on traite des centaines de fichiers.

> [!warning]
> **Le piège de l'octet nul `'\0'` :**  
> Une chaîne C de $N$ caractères imprimables occupe **$N + 1$ octets** en mémoire.  
> Oublier le `+ 1` lors d'un `malloc(strlen(s))` écrit le `'\0'` dans la zone mémoire suivante, corrompant les métadonnées du tas (*heap corruption*), détectée plus tard par glibc lors d'un `free` avec le message `corrupted size vs. prev_size`.

---

## ❓ Questions de Révision & Cas Pratiques

1. **Pourquoi l'utilisation de `strtok` est-elle déconseillée dans les projets multi-threadés, et que privilégier à la place ?**
   - `strtok` conserve un pointeur statique interne pour mémoriser l'avancement dans la chaîne entre chaque appel. Si deux threads appellent `strtok` simultanément, ils s'écrasent mutuellement leur contexte d'itération. On lui préfère `strtok_r` (version réentrante qui prend un paramètre `char **saveptr`) ou un parsing en place avec `strchr`.
2. **Que renvoie `fgets` si le fichier contient une ligne vide (uniquement `\n`) ?**
   - Il renvoie le pointeur sur le buffer, qui contient les deux caractères : `"\n\0"`. La fonction ne renvoie `NULL` que lorsqu'il n'y a plus aucun caractère à lire à la fin du fichier (`EOF`).
3. **Pourquoi est-il crucial de tester le retour de `malloc` en C ?**
   - Si le système n'a plus de mémoire disponible, `malloc` renvoie `NULL`. Tenter d'écrire immédiatement dans le pointeur retourné sans test déréférence un pointeur nul, ce qui déclenche un signal `SIGSEGV` (*Segmentation Fault*) et tue le processus.

---
*Fiche suivante : [[TP-C-Howls-Machine-SDL2]]*  
*Index général : [[Programmation/README]]*

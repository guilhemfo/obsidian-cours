---
title: "Synthèse TP C S3 — Howl's Machine (Graphisme, SDL2 & Événements)"
matiere: "Programmation"
date: "2026-10-12"
tags: [fiche, revision, programmation, c, epita, s3, bimestriel-5, sdl2, graphisme, events]
source: "EPITA S3 FISE 2030 – Programmation Avancée en C (PROG-205 P-03)"
---

# 🎮 TP Howl's Machine : Programmation Graphique, Moteur Événementiel & SDL2

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Bimestre 5 — Projet `Howls_machine` (`prog-205-p-03`)

---

## 🎯 Points Clés

- Architecture d'une **Game Loop** interactive : événements, calcul d'état, dessin sur back-buffer, affichage écran.
- Rôle distinct entre la mémoire CPU (`SDL_Surface`) et la mémoire GPU VRAM (`SDL_Texture` / `SDL_Renderer`).
- Formule d'adressage mémoire physique d'un pixel bidimensionnel via le `pitch`.
- Algorithme de conversion de couleur RGB vers niveau de gris basé sur la sensibilité humaine à la luminance.
- Détection de collision géométrique boîte contre boîte (AABB) pour boutons d'interface et grilles de jeu.

---

## 📖 Cours & Fonctions Détaillées

### 1. `SDL_Surface` vs `SDL_Texture` & `SDL_Renderer`

#### 🔍 Définition formelle & Fonctionnement interne
- **`SDL_Surface`** : Structure de données stockée en **mémoire vive centrale (RAM)**. Elle contient un tableau d'octets brut `pixels` directement accessible et modifiable par le processeur (CPU).
- **`SDL_Texture`** : Image résidant directement dans la **mémoire vidéo (VRAM)** de la carte graphique. Le CPU ne peut pas lire ni écrire directement dans ses pixels ; seul le GPU peut la manipuler.
- **`SDL_Renderer`** : Gestionnaire de dessin accéléré par le matériel (GPU) qui projette des textures et des primitives sur la fenêtre.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Si l'on veut dessiner ou appliquer un filtre pixel par pixel (ex: flou, noir et blanc, détection de contours dans un projet OCR), on travaille sur une `SDL_Surface` car le CPU peut lire chaque octet.  
Une fois le traitement terminé, on transfère l'image vers le GPU avec `SDL_CreateTextureFromSurface()`. Le rendu sera ensuite affiché à 60 ou 144 images par seconde sans ralentir le CPU.

#### 💻 Exemple concret
```c
// 1. Chargement d'une image en mémoire RAM (CPU)
SDL_Surface *surface = SDL_LoadBMP("image.bmp");

// 2. Traitement d'image en RAM (ex: passage en noir et blanc)
grayscale(surface);

// 3. Téléversement de l'image traitée vers la mémoire GPU (VRAM)
SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);

// 4. La surface en RAM n'est plus utile : on la détruit pour libérer la mémoire !
SDL_FreeSurface(surface);
```

---

### 2. Le `pitch` et l'adressage mémoire d'un pixel $(x, y)$

#### 🔍 Définition formelle & Fonctionnement interne
Le **pitch** (ou stride) est la **longueur réelle en octets d'une ligne de pixels en mémoire**.  
Il est souvent strictement supérieur à $\text{largeur} \times \text{BytesPerPixel}$ en raison de l'alignement mémoire matériel exigé par le système (ex: alignement sur des multiples de 4 ou 16 octets pour optimiser les accès cache du processeur).  
L'adresse mémoire d'un pixel aux coordonnées $(x, y)$ est :
$$\text{Adresse}(x, y) = \text{surface}\to\text{pixels} + (y \times \text{pitch}) + (x \times \text{BytesPerPixel})$$

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Si l'on calcule l'adresse avec la formule naïve $(y \times \text{largeur} + x) \times 4$, on ignore les octets de rembourrage (*padding*). L'image affichée apparaîtra alors complètement déformée, zébrée ou décalée en diagonale (*skewed artifact*). Le `pitch` garantit un accès mathématiquement exact à la case mémoire de chaque pixel.

#### 💻 Exemple concret
```c
Uint32 get_pixel(SDL_Surface *surface, int x, int y) {
    // Calcul de l'adresse de départ du pixel (x, y)
    Uint8 *p = (Uint8 *)surface->pixels 
               + (y * surface->pitch) 
               + (x * surface->format->BytesPerPixel);

    // Déréférencement sur 32 bits (4 octets : RGBA ou ARGB)
    return *(Uint32 *)p;
}

void set_pixel(SDL_Surface *surface, int x, int y, Uint32 pixel) {
    Uint8 *p = (Uint8 *)surface->pixels 
               + (y * surface->pitch) 
               + (x * surface->format->BytesPerPixel);

    *(Uint32 *)p = pixel;
}
```

---

### 3. Filtre Niveaux de Gris & Luminance pondérée

#### 🔍 Définition formelle & Fonctionnement interne
Pour convertir un pixel couleur $(R, G, B)$ en niveau de gris, on calcule une valeur scalaire unique reproduite sur les trois canaux.  
La physiologie humaine possède une rétine beaucoup plus dense en photorécepteurs pour le spectre vert que pour le rouge ou le bleu. La norme internationale de perception **ITU-R BT.601** applique les pondérations suivantes :
$$\text{Luminance} = 0.299 \times R + 0.587 \times G + 0.114 \times B$$

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Une moyenne brute $\frac{R+G+B}{3}$ donne des images ternes où un vert vif et un bleu foncé peuvent avoir la même intensité perçue. La formule pondérée préserve le contraste naturel de l'image, ce qui est une étape préliminaire obligatoire pour la binarisation d'image, le traitement vidéo et la reconnaissance de caractères (OCR).

#### 💻 Exemple concret
```c
void grayscale(SDL_Surface *surface) {
    if (!surface) return;

    // Verrouille la mémoire si la surface est stockée dans un format optimisé
    if (SDL_MUSTLOCK(surface))
        SDL_LockSurface(surface);

    for (int y = 0; y < surface->h; y++) {
        for (int x = 0; x < surface->w; x++) {
            Uint32 pixel = get_pixel(surface, x, y);

            Uint8 r, g, b;
            SDL_GetRGB(pixel, surface->format, &r, &g, &b);

            // Formule de luminance humaine
            Uint8 gray = (Uint8)(0.299 * r + 0.587 * g + 0.114 * b);

            // Création du pixel gris dans le même format pixel que la surface
            Uint32 gray_pixel = SDL_MapRGB(surface->format, gray, gray, gray);
            set_pixel(surface, x, y, gray_pixel);
        }
    }

    if (SDL_MUSTLOCK(surface))
        SDL_UnlockSurface(surface);
}
```

---

### 4. `SDL_PollEvent` & La Boucle Événementielle (Game Loop)

#### 🔍 Définition formelle & Fonctionnement interne
```c
int SDL_PollEvent(SDL_Event *event);
```
Interroge la file d'attente d'événements du système d'exploitation. Si un événement est en attente (clic souris, touche enfoncée, redimensionnement), il le retire de la file, le copie dans `event` et renvoie `1`. Si la file est vide, il renvoie `0`.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Permet à une application graphique d'être réactive en temps réel. Sans boucle `while (SDL_PollEvent(&event))`, les événements s'accumulent dans le système, la fenêtre se fige et le système d'exploitation affiche *"Le programme ne répond plus"*.

#### 💻 Exemple concret (Game Loop standard complète)
```c
int running = 1;
SDL_Rect player = { .x = 100, .y = 100, .w = 50, .h = 50 };

while (running) {
    SDL_Event event;
    // 1. Dépouillement de tous les événements survenus depuis la dernière frame
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT)
            running = 0; // Clic sur la croix
        if (event.type == SDL_KEYDOWN) {
            if (event.key.keysym.sym == SDLK_ESCAPE)
                running = 0;
            if (event.key.keysym.sym == SDLK_RIGHT && player.x + player.w + 5 <= 800)
                player.x += 5;
        }
    }

    // 2. Nettoyage de l'écran avec une couleur de fond (Noir)
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);

    // 3. Dessin des objets du jeu (Joueur en blanc)
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_RenderFillRect(renderer, &player);

    // 4. Échange du back-buffer et du front-buffer (affichage à l'écran)
    SDL_RenderPresent(renderer);

    // 5. Régulation de la boucle à ~60 images par seconde (16ms par frame)
    SDL_Delay(16);
}
```

---

### 5. Hitbox AABB & Projection Coordonnées Écran $\to$ Grille de Jeu

#### 🔍 Définition formelle & Fonctionnement interne
- **AABB (Axis-Aligned Bounding Box) :** Test mathématique vérifiant si un point $(x, y)$ est contenu dans un rectangle aligné sur les axes :
  $$x \ge \text{rect.x} \quad \land \quad x \le \text{rect.x} + \text{rect.w} \quad \land \quad y \ge \text{rect.y} \quad \land \quad y \le \text{rect.y} + \text{rect.h}$$
- **Projection Grille :** Pour une grille régulière de $N \times N$ cellules de largeur $W$ :
  $$\text{colonne} = \left\lfloor \frac{x}{W} \right\rfloor, \quad \text{ligne} = \left\lfloor \frac{y}{W} \right\rfloor$$

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Permet de créer tous les composants d'interface utilisateur (boutons cliquables, zones de texte, curseurs) et de traduire les clics de la souris en coordonnées de cases logiques dans un jeu vidéo (échecs, dames, morpion).

#### 💻 Exemple concret (Détection de clic Morpion / Tic-Tac-Toe)
```c
int handle_click_cell(int mouse_x, int mouse_y, int cell_size, int *out_row, int *out_col) {
    // Vérifie que le clic est bien dans la zone du plateau 3x3
    if (mouse_x < 0 || mouse_x >= 3 * cell_size || 
        mouse_y < 0 || mouse_y >= 3 * cell_size) {
        return 0; // Clic en dehors du plateau
    }

    // Division entière : projette immédiatement sur l'indice de case 0, 1 ou 2
    *out_col = mouse_x / cell_size;
    *out_row = mouse_y / cell_size;
    return 1;
}
```

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **Double buffering & `SDL_RenderPresent` :**  
> En SDL2, toutes les fonctions `SDL_RenderDraw...` dessinent sur une image cachée (le *back-buffer*). Si vous oubliez d'appeler `SDL_RenderPresent(renderer)`, l'écran restera définitivement noir car le GPU n'affiche jamais l'image à l'utilisateur !

> [!warning]
> **Fuite de mémoire VRAM avec les textures :**  
> Une texture créée avec `SDL_CreateTextureFromSurface` doit impérativement être détruite avec `SDL_DestroyTexture(texture)` quand elle n'est plus utilisée.  
> Créer une texture à chaque tour de boucle sans la détruire sature la carte graphique en quelques secondes et provoque un crash système.

---

## ❓ Questions de Révision & Cas Pratiques

1. **Pourquoi utilise-t-on `SDL_Delay(16)` ou le flag `SDL_RENDERER_PRESENTVSYNC` ?**
   - Sans régulation temporelle, la boucle `while (running)` s'exécute à plein régime (milliers de tours/seconde), ce qui sature un cœur de processeur à 100%, fait chauffer la machine et gaspille de l'énergie.
2. **Quelle est la différence entre `SDL_RenderDrawRect` et `SDL_RenderFillRect` ?**
   - `SDL_RenderDrawRect` trace uniquement le contour extérieur (les 4 lignes d'un pixel d'épaisseur), tandis que `SDL_RenderFillRect` remplit intégralement l'intérieur du rectangle avec la couleur courante.
3. **Que fait `SDL_GetRGB` et pourquoi est-elle indispensable ?**
   - Selon le système (Linux, Windows, macOS) et la profondeur de couleur (16, 24 ou 32 bits), l'ordre des octets en mémoire change (RGBA, BGRA, ARGB). `SDL_GetRGB` utilise le descripteur `surface->format` pour extraire avec certitude les vraies valeurs des canaux rouge, vert et bleu indépendamment de l'endianness.

---
*Fiche précédente : [[TP-C-Flying-Machines]]*  
*Index général : [[Programmation/README]]*

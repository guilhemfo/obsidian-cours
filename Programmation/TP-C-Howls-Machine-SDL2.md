---
title: "Synthèse TP C S3 — Howl's Machine (Graphisme & Événements SDL2)"
matiere: "Programmation"
date: "2026-10-12"
tags: [fiche, revision, programmation, c, epita, s3, bimestriel-5, sdl2, graphisme, events]
source: "EPITA S3 FISE 2030 – Programmation Avancée en C (PROG-205 P-03)"
---

# 🎮 TP Howl's Machine : Programmation Graphique & Événements SDL2

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Bimestre 5 — Projet `Howls_machine` (`prog-205-p-03`)  
> **Concepts clés :** Bibliothèque `SDL2`, boucle d'événements principale (*Game Loop*), gestion de fenêtre et de rendu hardware (`SDL_Window`, `SDL_Renderer`), manipulation directe de pixels sur surface (`SDL_Surface`), traitement d'image (niveaux de gris), détection de collisions AABB et UI interactive.

---

## 🎯 Ce qu'il faut absolument retenir

1. **Cycle de vie standard d'une application SDL2 :**
   - **Initialisation :** `SDL_Init(SDL_INIT_VIDEO)` $\to$ `SDL_CreateWindow` $\to$ `SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)`.
   - **Game Loop :** Traitement des événements (`SDL_PollEvent`) $\to$ Mise à jour de l'état $\to$ Dessin sur le back-buffer (`SDL_RenderClear`, `SDL_RenderFillRect`, etc.) $\to$ Affichage à l'écran (`SDL_RenderPresent`) $\to$ Régulation du framerate (`SDL_Delay`).
   - **Nettoyage strict :** Libération des textures/surfaces $\to$ `SDL_DestroyRenderer` $\to$ `SDL_DestroyWindow` $\to$ `SDL_Quit`.
2. **Gestion des événements (`SDL_PollEvent`) :**
   - Toujours traiter les événements dans une boucle `while (SDL_PollEvent(&event))` pour vider la file d'attente système à chaque frame.
   - Les événements majeurs : `SDL_QUIT` (clic sur la croix de fermeture), `SDL_KEYDOWN` (touche pressée, ex: `SDLK_ESCAPE`, `SDLK_UP`), `SDL_MOUSEMOTION`, `SDL_MOUSEBUTTONDOWN`.
3. **Manipulation directe de pixels sur `SDL_Surface` (Traitement d'image) :**
   - Accès mémoire au pixel $(x, y)$ via le **pitch** (largeur d'une ligne en octets, incluant le padding) :
     ```c
     Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * surface->format->BytesPerPixel;
     Uint32 pixel = *(Uint32 *)p;
     ```
   - Extraction des composantes couleur : `SDL_GetRGB(pixel, surface->format, &r, &g, &b)`.
   - Calcul de la luminance pour passer en niveaux de gris :
     $$\text{Gray} = 0.299 \times R + 0.587 \times G + 0.114 \times B$$
   - Reconstruction du pixel : `SDL_MapRGB(surface->format, gray, gray, gray)`.
   - Toujours encadrer par `SDL_LockSurface` et `SDL_UnlockSurface` si `SDL_MUSTLOCK(surface)` est vrai.
4. **Interface utilisateur & Détection de clic (Hitbox AABB) :**
   - Pour tester si le curseur $(x, y)$ est dans un rectangle (`SDL_Rect`) :
     $$x \ge \text{rect.x} \quad \text{ET} \quad x \le \text{rect.x} + \text{rect.w} \quad \text{ET} \quad y \ge \text{rect.y} \quad \text{ET} \quad y \le \text{rect.y} + \text{rect.h}$$

---

## 🏗️ 1. Architecture du Projet

- **`Fundamentals/` :**
  - `window.c` / `window.h` : Wrapper propre pour l'ouverture et la fermeture de la fenêtre graphique SDL2.
  - `shapes/` : Calibration de la grille, dessin de primitives (rectangles, lignes) et déplacement au clavier d'un carré avec gestion des bords de l'écran.
  - `images/` : Chargement de fichier BMP (`SDL_LoadBMP`), conversion `Surface` $\to$ `Texture`, manipulation directe des pixels (`get_pixel`, `set_pixel`) et filtre noir et blanc (`grayscale`).
  - `button/` : Bouton interactif avec gestion du survol de souris (*hover effect*) et déclenchement d'action au clic gauche.
- **`Proficiencies/` :**
  - `tic_tac_toe.h`, `main.c`, `game.c`, `render.c` : Jeu de Morpion interactif 2 joueurs avec détection des cases cliquées, dessin des symboles (croix / ronds), vérification des alignements gagnants et match nul.

---

## 🎨 2. Implémentations Références à Maîtriser

### A. La boucle événementielle & Clavier (Déplacement avec contrainte de bord)
```c
int handle_events(SDL_Rect *rect, int win_w, int win_h) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT)
            return 0; // Quitter
        if (event.type == SDL_KEYDOWN) {
            if (event.key.keysym.sym == SDLK_ESCAPE)
                return 0;
            if (event.key.keysym.sym == SDLK_UP && rect->y - 5 >= 0)
                rect->y -= 5;
            else if (event.key.keysym.sym == SDLK_DOWN && rect->y + rect->h + 5 <= win_h)
                rect->y += 5;
            else if (event.key.keysym.sym == SDLK_LEFT && rect->x - 5 >= 0)
                rect->x -= 5;
            else if (event.key.keysym.sym == SDLK_RIGHT && rect->x + rect->w + 5 <= win_w)
                rect->x += 5;
        }
    }
    return 1; // Continuer
}
```

### B. Filtre Niveaux de Gris (Grayscale) direct sur Surface 32-bit
```c
void grayscale(SDL_Surface *surface) {
    if (!surface) return;

    if (SDL_MUSTLOCK(surface))
        SDL_LockSurface(surface);

    for (int y = 0; y < surface->h; y++) {
        for (int x = 0; x < surface->w; x++) {
            // Calcul de l'adresse du pixel
            Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * surface->format->BytesPerPixel;
            Uint32 pixel = *(Uint32 *)p;

            Uint8 r, g, b;
            SDL_GetRGB(pixel, surface->format, &r, &g, &b);

            // Formule standard de luminance ITU-R BT.601
            Uint8 gray = (Uint8)(0.299 * r + 0.587 * g + 0.114 * b);
            *(Uint32 *)p = SDL_MapRGB(surface->format, gray, gray, gray);
        }
    }

    if (SDL_MUSTLOCK(surface))
        SDL_UnlockSurface(surface);
}
```

### C. Détection de Clic sur un Bouton / Cellule de Grille
```c
int is_inside(const SDL_Rect *btn, int x, int y) {
    if (!btn) return 0;
    return (x >= btn->x && x <= btn->x + btn->w &&
            y >= btn->y && y <= btn->y + btn->h);
}

// Convertit des coordonnées pixels en coordonnées grille Morpion (3x3)
int get_clicked_cell(int x, int y, int *row, int *col, int cell_size) {
    if (x < 0 || x >= 3 * cell_size || y < 0 || y >= 3 * cell_size)
        return 0; // Hors grille
    *col = x / cell_size;
    *row = y / cell_size;
    return 1;
}
```

---

## ⚠️ Pièges & Bonnes Pratiques Graphiques

| Piège | Conséquence | Bonne pratique |
| :--- | :--- | :--- |
| `surface->w * 4` au lieu de `surface->pitch` | Décalage horizontal diagonal des pixels (*skewed image*) | Toujours utiliser `surface->pitch` pour les sauts de ligne en mémoire. |
| Oubli de `SDL_RenderClear` avant le dessin | Superposition des anciennes images (*ghosting effect*) | Effacer systématiquement le renderer au début de chaque frame. |
| Oubli de `SDL_RenderPresent` | Écran noir persistant | Appeler `SDL_RenderPresent(renderer)` après avoir tout dessiné. |
| Boucle sans `SDL_Delay` | CPU à 100% sur un cœur | Ajouter `SDL_Delay(16)` pour stabiliser autour de ~60 FPS ou activer `SDL_RENDERER_PRESENTVSYNC`. |
| Oubli de `SDL_FreeSurface` après `SDL_CreateTextureFromSurface` | Fuite massive de mémoire RAM système | La texture est copiée en VRAM GPU : la surface CPU d'origine peut être libérée immédiatement. |

---

## ❓ Questions de Révision

1. **Quelle est la différence fondamentale entre une `SDL_Surface` et une `SDL_Texture` ?**
   - Une `SDL_Surface` réside dans la mémoire RAM système et ses pixels sont accessibles/modifiables par le CPU. Une `SDL_Texture` réside dans la mémoire vidéo (VRAM) du GPU et est optimisée pour un rendu matériel ultra-rapide par le renderer.
2. **Pourquoi la formule du niveau de gris n'est-elle pas une simple moyenne arithmétique $\frac{R+G+B}{3}$ ?**
   - L'œil humain est beaucoup plus sensible à la lumière verte (58.7%) qu'à la lumière rouge (29.9%) ou bleue (11.4%). Les coefficients pondérés reflètent la perception biologique de la luminance.
3. **À quoi sert le drapeau `SDL_RENDERER_PRESENTVSYNC` lors de la création du renderer ?**
   - Il synchronise le rafraîchissement des frames avec la fréquence de balayage de l'écran physique pour éviter les déchirures d'image (*tearing*).

---
*Index général : [[Programmation/README]]* | *Accueil : [[Bienvenue]]*

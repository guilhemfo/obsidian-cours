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

- Architecture d'une **Game Loop** industrielle : boucle synchrone cadencée avec traitement d'événements, simulation d'état physique, double buffering et synchronisation verticale (*VSync*).
- Séparation physique des mémoires : **RAM centrale (CPU)** via `SDL_Surface` vs **VRAM GPU** via `SDL_Texture`.
- Formule fondamentale du **pitch** pour l'adressage mémoire physique d'un tableau bidimensionnel de pixels avec contraintes d'alignement matériel.
- Modèle de luminance humaine (norme internationale ITU-R BT.601) pour la transformation d'images couleur en niveaux de gris.
- Mathématiques des interfaces graphiques : tests de collision AABB (*Axis-Aligned Bounding Box*) et formules de projection d'espace écran vers espace grille discrète.

---

## 📖 Cours & Fonctions Détaillées

---

### 1. `SDL_Init`, `SDL_CreateWindow`, `SDL_CreateRenderer` — Le cycle de vie matériel SDL2

#### 🔍 Définition formelle & Fonctionnement interne
- `SDL_Init(flags)` : Initialise les sous-systèmes matériels de bas niveau de la SDL (vidéo, audio, timers, événements). Communique directement avec le serveur graphique du système d'exploitation (`X11` ou `Wayland` sous Linux, `Win32` sous Windows, `Cocoa` sous macOS).
- `SDL_CreateWindow(...)` : Alloue et enregistre une fenêtre native gérée par le compositeur du système.
- `SDL_CreateRenderer(window, -1, flags)` :
  - `flags = SDL_RENDERER_ACCELERATED` : Exige que le rendu soit exécuté par la carte graphique (GPU via OpenGL/Vulkan/DirectX) plutôt que par le processeur.
  - `flags = SDL_RENDERER_PRESENTVSYNC` : Active la synchronisation verticale matérielle. Le rendu attend le balayage physique de la dalle d'écran avant d'échanger les buffers.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Abstraction multi-plateforme :** Écrire un jeu ou une interface graphique en C portable qui fonctionne à l'identique sous Linux, Windows et macOS sans modifier une ligne de code d'affichage.
2. **Élimination du tearing (déchirure d'écran) :** Sans VSync, si le processeur produit des images plus vite que le taux de rafraîchissement de l'écran (ex: 60Hz), le GPU affiche une demi-image du haut fusionnée avec une demi-image du bas, provoquant une cassure visuelle horizontale très désagréable. `SDL_RENDERER_PRESENTVSYNC` synchronise parfaitement les images avec la fréquence de l'écran.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <SDL2/SDL.h>
#include <stdio.h>

typedef struct {
    SDL_Window   *window;
    SDL_Renderer *renderer;
} GraphicsContext;

int init_graphics(GraphicsContext *ctx, int width, int height, const char *title) {
    // 1. Initialisation du sous-système vidéo
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "Erreur SDL_Init : %s\n", SDL_GetError());
        return 0;
    }

    // 2. Création de la fenêtre centrée à l'écran
    ctx->window = SDL_CreateWindow(
        title,
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height,
        SDL_WINDOW_SHOWN
    );
    if (!ctx->window) {
        fprintf(stderr, "Erreur création fenêtre : %s\n", SDL_GetError());
        SDL_Quit();
        return 0;
    }

    // 3. Création du renderer GPU avec VSync activé
    ctx->renderer = SDL_CreateRenderer(
        ctx->window,
        -1, // Premier pilote GPU disponible supportant les flags
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
    );
    if (!ctx->renderer) {
        fprintf(stderr, "Erreur création renderer : %s\n", SDL_GetError());
        SDL_DestroyWindow(ctx->window);
        SDL_Quit();
        return 0;
    }

    return 1; // Succès
}

void cleanup_graphics(GraphicsContext *ctx) {
    // Ordre de destruction inverse de l'initialisation pour éviter les pointeurs sauvages
    if (ctx->renderer) SDL_DestroyRenderer(ctx->renderer);
    if (ctx->window)   SDL_DestroyWindow(ctx->window);
    SDL_Quit();
}
```
**Ce que fait ce code et pourquoi :**
- `SDL_GetError()` retourne la description textuelle exacte de la dernière erreur survenue au niveau du sous-système graphique.
- Le paramètre `-1` dans `SDL_CreateRenderer` demande à la SDL de sélectionner automatiquement le premier périphérique de rendu matériel adéquat.
- L'ordre de nettoyage dans `cleanup_graphics` est capital : détruire la fenêtre avant le renderer provoquerait un déréférencement invalide dans le pilote graphique.

---

### 2. Mémoire CPU (`SDL_Surface`) vs Mémoire GPU (`SDL_Texture`)

#### 🔍 Définition formelle & Fonctionnement interne
- **`SDL_Surface` (Mémoire RAM système) :**
  Contient un champ `pixels` qui est un tableau linéaire d'octets résidant dans la mémoire centrale de l'ordinateur. Le CPU peut lire, écrire et appliquer des calculs mathématiques arbitraires sur chaque octet.
- **`SDL_Texture` (Mémoire VRAM de la carte graphique) :**
  Réside directement dans les puces mémoires de la carte graphique. Les données y sont stockées dans des formats opaques, compressés ou agencés de façon optimale pour les unités de calcul matriciel du GPU. Le CPU ne peut pas déréférencer les pixels d'une texture.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
- **Quand utiliser `SDL_Surface` ?**
  Pour tout ce qui relève de **l'analyse et du traitement d'image** : filtres de convolution, détection de contours (Sobel), seuillage pour OCR, génération procédurale de textures, modification d'octets bruts.
- **Quand utiliser `SDL_Texture` ?**
  Pour tout ce qui relève de **l'affichage en temps réel** : dessiner un sprite de jeu, faire pivoter un personnage, appliquer un zoom, superposer des calques. Le GPU est conçu pour projeter des textures en parallèle sur des millions de pixels à des cadences de plusieurs centaines de FPS sans utiliser aucun cycle du processeur central.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <SDL2/SDL.h>
#include <err.h>

SDL_Texture *load_and_process_texture(SDL_Renderer *renderer, const char *path) {
    // Étape 1 : Chargement de l'image bitmap BMP en mémoire RAM centrale
    SDL_Surface *surface = SDL_LoadBMP(path);
    if (!surface) {
        warnx("Impossible de charger l'image BMP : %s", SDL_GetError());
        return NULL;
    }

    // Étape 2 : Le CPU traite les octets en mémoire RAM (ex: passage en noir et blanc)
    // C'est possible uniquement parce que 'surface->pixels' est accessible en lecture/écriture !
    grayscale(surface);

    // Étape 3 : Copie de la surface modifiée depuis la RAM vers la mémoire VRAM de la carte graphique
    SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
    if (!texture) {
        warnx("Échec de création de la texture GPU : %s", SDL_GetError());
    }

    // Étape 4 : TRÈS IMPORTANT — Libération immédiate de la surface RAM
    // Les données étant maintenant dans le GPU, conserver la surface en mémoire centrale
    // gaspillerait inutilement des mégaoctets de mémoire RAM.
    SDL_FreeSurface(surface);

    return texture; // Renvoie la texture prête pour un affichage GPU ultra-rapide
}
```

---

### 3. Le `pitch` et l'adressage physique d'un pixel $(x, y)$

#### 🔍 Définition formelle & Fonctionnement interne
En informatique, une image bidimensionnelle de largeur $W$ et de hauteur $H$ est représentée en mémoire physique sous la forme d'un **tableau linéaire continu à une seule dimension**.
Le **pitch** (aussi appelé *stride*) représente le nombre total d'octets séparant le début d'une ligne de pixels du début de la ligne suivante en mémoire :
$$\text{pitch} \ge W \times \text{BytesPerPixel}$$
Cette inégalité s'explique par les contraintes d'alignement matériel : pour maximiser la bande passante du bus mémoire, les contrôleurs mémoires et les registres SIMD du CPU transfèrent les données par blocs alignés sur 64, 128 ou 256 bits. Des octets de remplissage inutilisés (*padding*) sont donc souvent insérés à la fin de chaque ligne.

L'adresse de l'octet de départ du pixel situé aux coordonnées $(x, y)$ est obligatoirement :
$$\text{Adresse}(x, y) = \text{pixels\_base} + (y \times \text{pitch}) + (x \times \text{BytesPerPixel})$$

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Si un développeur utilise la formule scolaire naïve :
$$\text{Adresse\_fausse}(x, y) = \text{pixels\_base} + (y \times W + x) \times 4$$
dès que l'image a une largeur qui n'est pas un multiple strict de l'alignement matériel (ex: largeur impaire), les octets de remplissage sont comptés comme des pixels normaux. À chaque nouvelle ligne, le décalage s'accumule : l'image finale apparaît alors entièrement brisée, inclinée en diagonale (*shearing effect*) et striée de lignes multicolores. **Utiliser le `pitch` est la seule façon d'assurer un adressage mémoire universellement valide.**

#### 💻 Exemple concret & Explication pas à pas
```c
#include <SDL2/SDL.h>
#include <err.h>

Uint32 get_pixel(SDL_Surface *surface, int x, int y) {
    // Vérification de sécurité : ce code suppose un format 32-bit (ex: ARGB8888 ou RGBA8888)
    if (surface->format->BytesPerPixel != 4) {
        errx(1, "Erreur : attendu 4 octets par pixel, reçu %d", surface->format->BytesPerPixel);
    }

    // 1. Arithmétique de pointeur sur Uint8* (1 octet par unité) pour calculer le décalage exact
    Uint8 *target_byte = (Uint8 *)surface->pixels 
                         + (y * surface->pitch) 
                         + (x * surface->format->BytesPerPixel);

    // 2. Cast en Uint32* puis déréférencement pour lire les 4 octets du pixel d'un seul coup
    return *(Uint32 *)target_byte;
}

void set_pixel(SDL_Surface *surface, int x, int y, Uint32 pixel) {
    if (surface->format->BytesPerPixel != 4) {
        errx(1, "Erreur : attendu 4 octets par pixel, reçu %d", surface->format->BytesPerPixel);
    }

    Uint8 *target_byte = (Uint8 *)surface->pixels 
                         + (y * surface->pitch) 
                         + (x * surface->format->BytesPerPixel);

    // Écriture atomique des 4 octets du pixel
    *(Uint32 *)target_byte = pixel;
}
```
**Ce que fait ce code et pourquoi :**
- On effectue d'abord un cast en `Uint8 *` avant d'ajouter le déplacement en octets, car l'arithmétique de pointeur en C dépend de la taille du type pointé (ajouter 1 à un `Uint32 *` avance de 4 octets en mémoire !).
- Une fois le bon octet atteint, on cast en `Uint32 *` pour lire ou écrire la valeur entière de couleur en un seul cycle machine.

---

### 4. Filtre Niveaux de Gris & Luminance Physiologique (ITU-R BT.601)

#### 🔍 Définition formelle & Fonctionnement interne
Pour convertir un pixel couleur $(R, G, B)$ en nuance de gris, on recherche la valeur de luminosité perçue (*luminance* notée $Y$).  
La biologie du système visuel humain possède des cônes photorécepteurs dont les sensibilités spectrales culminent vers 555 nm (couleur verte). L'œil perçoit donc le vert avec une clarté beaucoup plus intense que le rouge ou le bleu.  
La formule internationale de l'Union Internationale des Télécommunications (**ITU-R BT.601**) formalise cette pondération :
$$Y = 0.299 \times R + 0.587 \times G + 0.114 \times B$$
Le pixel résultant est réencodé avec la même valeur $Y$ sur les trois composantes : $(Y, Y, Y)$.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Éviter la perte d'information de la moyenne simple :**  
   Si l'on fait une moyenne naïve $Y_{\text{naïf}} = \frac{R + G + B}{3}$, un vert pur $(0, 255, 0)$ et un bleu pur $(0, 0, 255)$ donneront tous deux la même valeur de gris ($85$). Visuellement, un texte bleu sur fond vert perdrait tout contraste et deviendrait invisible ! Avec la formule ITU-R, le vert donnera une luminance de $150$ et le bleu une luminance de $29$, préservant un contraste parfait.
2. **Étape préliminaire fondamentale pour l'IA et la vision par ordinateur (OCR) :**  
   Avant d'analyser les lettres d'une page scannée dans un projet OCR, on doit réduire l'espace couleur de 3 dimensions $(R, G, B)$ à 1 seule dimension (luminance), divisant par 3 le coût computationnel des filtres de binarisation (Otsu, Sauvola) sans dégrader la qualité géométrique des caractères.

#### 💻 Exemple concret & Explication pas à pas
```c
#include "images.h"
#include <SDL2/SDL.h>

void grayscale(SDL_Surface *surface) {
    if (surface == NULL) return;

    // Certaines surfaces matérielles doivent être verrouillées avant que le CPU
    // n'ait l'autorisation de toucher au pointeur surface->pixels
    if (SDL_MUSTLOCK(surface)) {
        if (SDL_LockSurface(surface) < 0) return;
    }

    int width = surface->w;
    int height = surface->h;

    // Parcours de chaque pixel de l'image (lignes puis colonnes pour maximiser l'accès au cache L1)
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // Lecture du pixel au format brut (ex: 0xFF22AA)
            Uint32 pixel = get_pixel(surface, x, y);

            Uint8 r, g, b;
            // Décodage indépendant de l'endianness des canaux R, G, B
            SDL_GetRGB(pixel, surface->format, &r, &g, &b);

            // Application de la formule pondérée ITU-R BT.601
            Uint8 gray = (Uint8)(0.299 * r + 0.587 * g + 0.114 * b);

            // Réencodage d'un pixel ayant la même valeur sur les 3 canaux
            Uint32 gray_pixel = SDL_MapRGB(surface->format, gray, gray, gray);

            // Écriture du pixel gris à la même position
            set_pixel(surface, x, y, gray_pixel);
        }
    }

    // Déverrouillage obligatoire dès la fin des accès mémoires directs
    if (SDL_MUSTLOCK(surface)) {
        SDL_UnlockSurface(surface);
    }
}
```
**Ce que fait ce code et pourquoi :**
- `SDL_GetRGB()` et `SDL_MapRGB()` utilisent le champ `surface->format` qui décrit la disposition exacte des masques de bits (`Rmask`, `Gmask`, `Bmask`). Cela rend le code compatible avec n'importe quelle disposition d'octets en mémoire (RGBA, ARGB, BGRA, big-endian ou little-endian).
- L'itération s'effectue avec la boucle `y` en extérieur et `x` en intérieur : cela garantit qu'on parcourt les cases mémoires de façon linéaire et séquentielle, ce qui permet au processeur de charger efficacement les lignes de cache (*cache locality*).

---

### 5. `SDL_PollEvent` & Architecture d'une Game Loop Complète

#### 🔍 Définition formelle & Fonctionnement interne
```c
int SDL_PollEvent(SDL_Event *event);
```
- Le système d'exploitation place tous les événements physiques (touches du clavier, mouvements et clics de la souris, perte de focus) dans une file FIFO gérée par le noyau.
- `SDL_PollEvent` dépile le premier événement en attente et le stocke dans la structure union `SDL_Event`. Il renvoie `1` si un événement a été récupéré, et `0` dès que la file est vide.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Une application graphique interactive ne peut pas se contenter d'un simple `getchar()` qui bloque le programme. Elle doit continuellement tourner pour mettre à jour les animations tout en restant réactive aux actions de l'utilisateur.  
C'est le rôle de la **Game Loop**, qui structure l'application en 4 phases synchronisées à 60 FPS :
1. **Événements :** Vider la file avec `while (SDL_PollEvent(&event))`.
2. **Mise à jour (Update) :** Déplacer les entités, calculer la physique et les règles de jeu.
3. **Dessin (Render) :** Nettoyer le back-buffer (`SDL_RenderClear`), tracer les formes et textures.
4. **Présentation & Régulation :** Afficher l'image (`SDL_RenderPresent`) et attendre la frame suivante (`SDL_Delay`).

#### 💻 Exemple concret & Explication pas à pas
```c
#include <SDL2/SDL.h>

void run_game_loop(SDL_Renderer *renderer) {
    int running = 1;
    SDL_Rect player = { .x = 375, .y = 275, .w = 50, .h = 50 };
    int speed = 5;

    while (running) {
        Uint32 frame_start = SDL_GetTicks(); // Horloge en millisecondes

        // --- PHASE 1 : GESTION DES ÉVÉNEMENTS ---
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = 0; // L'utilisateur a cliqué sur la croix de la fenêtre
            }
            if (event.type == SDL_KEYDOWN) {
                switch (event.key.keysym.sym) {
                    case SDLK_ESCAPE: running = 0; break;
                    case SDLK_UP:    if (player.y - speed >= 0) player.y -= speed; break;
                    case SDLK_DOWN:  if (player.y + player.h + speed <= 600) player.y += speed; break;
                    case SDLK_LEFT:  if (player.x - speed >= 0) player.x -= speed; break;
                    case SDLK_RIGHT: if (player.x + player.w + speed <= 800) player.x += speed; break;
                }
            }
        }

        // --- PHASE 2 : RENDU GRAPHIQUE (DOUBLE BUFFERING) ---
        // A. Effacement du back-buffer avec une couleur de fond sombre
        SDL_SetRenderDrawColor(renderer, 25, 25, 35, 255);
        SDL_RenderClear(renderer);

        // B. Dessin du carré représentant le joueur (Blanc pur)
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_RenderFillRect(renderer, &player);

        // C. Échange des buffers : le back-buffer devient visible à l'écran
        SDL_RenderPresent(renderer);

        // --- PHASE 3 : RÉGULATION DU FRAMERATE (~60 FPS) ---
        Uint32 frame_time = SDL_GetTicks() - frame_start;
        if (frame_time < 16) { // 1000ms / 60 FPS = 16.6ms par frame
            SDL_Delay(16 - frame_time); // Rend la main au système d'exploitation
        }
    }
}
```
**Ce que fait ce code et pourquoi :**
- `SDL_RenderClear` efface l'écran invisible pour effacer les traces de l'image précédente.
- `SDL_RenderPresent` effectue le *swap buffer* : l'utilisateur ne voit jamais l'image en train de se dessiner ligne par ligne, ce qui élimine tout scintillement (*flickering*).
- `SDL_Delay(16 - frame_time)` évite que le CPU tourne en boucle infinie à 100% d'utilisation en lui faisant faire une pause contrôlée.

---

### 6. Hitbox AABB & Logique de Grille (Morpion / Tic-Tac-Toe)

#### 🔍 Définition formelle & Fonctionnement interne
- **Test d'inclusion de point dans une AABB (Axis-Aligned Bounding Box) :**  
  Un point $(x, y)$ se trouve à l'intérieur d'un rectangle défini par son origine $(\text{rect.x}, \text{rect.y})$ et ses dimensions $(\text{rect.w}, \text{rect.h})$ si et seulement si :
  $$(x \ge \text{rect.x}) \land (x \le \text{rect.x} + \text{rect.w}) \land (y \ge \text{rect.y}) \land (y \le \text{rect.y} + \text{rect.h})$$
- **Projection continue $\to$ discrète sur une grille uniforme :**  
  Pour un plateau carré divisé en $N \times N$ cases où chaque case a une dimension de $S$ pixels :
  $$\text{colonne} = \left\lfloor \frac{x}{S} \right\rfloor, \quad \text{ligne} = \left\lfloor \frac{y}{S} \right\rfloor$$

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Création de boutons interactifs (GUI) :** Permet de savoir si le curseur de la souris survole un bouton pour changer sa couleur (*hover state*), ou si un clic gauche a été déclenché à l'intérieur.
2. **Traduction des clics en coordonnées de gameplay :** Dans un jeu de stratégie, d'échecs ou de morpion, le moteur reçoit des coordonnées en pixels physiques (ex: $x = 245, y = 510$). La division entière par la taille d'une case convertit immédiatement cette position en indices de tableau 2D (`board[ligne][colonne]`).

#### 💻 Exemple concret & Explication pas à pas
```c
#include <SDL2/SDL.h>
#include <stdio.h>

// Détection de survol ou de clic sur un bouton
int is_mouse_over_rect(const SDL_Rect *rect, int mouse_x, int mouse_y) {
    if (!rect) return 0;
    return (mouse_x >= rect->x && mouse_x <= rect->x + rect->w &&
            mouse_y >= rect->y && mouse_y <= rect->y + rect->h);
}

// Projection d'un clic souris dans une case de Morpion 3x3
int process_grid_click(int mouse_x, int mouse_y, int cell_size, int *out_row, int *out_col) {
    int max_coord = 3 * cell_size;
    
    // 1. Rejet des clics en dehors de la surface du plateau
    if (mouse_x < 0 || mouse_x >= max_coord || mouse_y < 0 || mouse_y >= max_coord) {
        return 0; // Hors plateau
    }

    // 2. Division entière C : tronque vers zéro pour trouver l'indice de case (0, 1 ou 2)
    *out_col = mouse_x / cell_size;
    *out_row = mouse_y / cell_size;
    return 1; // Clic valide
}
```
**Ce que fait ce code et pourquoi :**
- Si la fenêtre fait 600x600 pixels avec 3 cases de 200 pixels :
  - Un clic à $x = 245$ donne $245 / 200 = 1$ (deuxième colonne, indice 1).
  - Un clic à $y = 510$ donne $510 / 200 = 2$ (troisième ligne, indice 2).
- Aucun algorithme complexe n'est requis : une simple division entière $\mathcal{O}(1)$ résout la localisation en temps constant.

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **Le piège de la mémoire GPU (VRAM Leak) :**  
> Une `SDL_Surface` réside en RAM et se libère avec `SDL_FreeSurface()`.  
> Une `SDL_Texture` réside dans le GPU et se libère avec `SDL_DestroyTexture()`.  
> Si vous créez une texture à chaque tour de boucle de rendu sans appeler `SDL_DestroyTexture`, la mémoire de votre carte graphique est saturée en quelques secondes, ce qui provoque le gel complet de l'affichage du système d'exploitation.

> [!warning]
> **Pourquoi `SDL_RenderPresent` est obligatoire :**  
> En mode accéléré matériel avec double buffer, les fonctions de dessin (`SDL_RenderDrawLine`, `SDL_RenderFillRect`) ne dessinent que dans l'espace mémoire caché. Si vous omettez `SDL_RenderPresent`, la fenêtre reste noire même si tous vos calculs de dessin sont mathématiquement justes.

---

## ❓ Questions de Révision & Cas Pratiques

1. **Pourquoi utilise-t-on `SDL_MUSTLOCK(surface)` avant de manipuler les pixels ?**
   - Certaines surfaces matérielles (ex: mémoires partagées avec le serveur X ou formats avec conversion dynamique) nécessitent un verrouillage exclusif pour empêcher le sous-système graphique de déplacer ou modifier le pointeur `pixels` pendant que le CPU écrit dedans.
2. **Que renvoie `SDL_PollEvent(&event)` quand l'utilisateur ne touche ni au clavier ni à la souris ?**
   - Il renvoie `0`. C'est pourquoi on l'utilise dans une boucle `while (SDL_PollEvent(&event))` : la boucle s'arrête immédiatement dès que tous les événements ont été consommés, permettant à la Game Loop de poursuivre vers la phase de rendu sans bloquer.
3. **Quelle est la différence fondamentale entre `SDL_Rect` et `SDL_FRect` ?**
   - `SDL_Rect` stocke des coordonnées et dimensions entières (`int`), adaptées aux grilles de pixels. `SDL_FRect` utilise des nombres flottants (`float`), permettant des sous-pixels pour des animations fluides et des moteurs physiques précis.

---
*Fiche précédente : [[TP-C-Flying-Machines]]*  
*Index général : [[Programmation/README]]*

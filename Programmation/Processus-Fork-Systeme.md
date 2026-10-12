---
title: "Synthèse Système UNIX — Processus, fork, wait, exec, pipe & IPC"
matiere: "Programmation"
date: "2026-10-12"
tags: [fiche, revision, programmation, c, epita, s3, systeme, unix, posix, fork, process, wait, exec, pipe]
source: "EPITA S3 FISE 2030 – Programmation Système Avancée en C (POSIX / UNIX)"
---

# 🧬 Programmation Système UNIX : Processus, `fork()`, Synchronisation & Redirections

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Gestion des processus POSIX sous UNIX/Linux  
> **En-têtes standards nécessaires :** `<unistd.h>`, `<sys/types.h>`, `<sys/wait.h>`, `<stdlib.h>`, `<stdio.h>`, `<errno.h>`

---

## 🎯 Points Clés

- **Nature d'un processus :** Instance isolée d'un programme en cours d'exécution dotée de son propre espace d'adressage virtuel (Stack, Heap, BSS, Data, Text) et d'un bloc de contrôle noyau (*PCB*).
- **`fork(2)` :** Appel système fondamental qui clone le processus appelant. Particularité unique en C : **appelé une fois, il retourne deux fois** ($0$ dans le fils, le PID du fils dans le père, $-1$ en cas d'échec).
- **Copy-On-Write (COW) :** Optimisation matérielle du noyau Linux. La mémoire physique n'est pas dupliquée lors du `fork()` ; les pages sont marquées en lecture seule et dupliquées uniquement au premier octet modifié en écriture.
- **Cycle de vie :**
  - **Zombie (`<defunct>`) :** Fils terminé dont le père n'a pas encore lu le statut de fin via `wait()` / `waitpid()`.
  - **Orphelin :** Fils dont le père est mort prématurément ; il est automatiquement adopté par le processus racine (`init` ou `systemd`, PID 1) qui fauchera son zombie.
- **Remplacement de contexte :** Le binôme `fork()` + `exec*()` permet de lancer n'importe quel binaire système en remplaçant la mémoire du fils sans tuer le processus père.
- **Communication Inter-Processus (IPC) :** Utilisation conjointe de tubes anonymes `pipe()` et de redirections de descripteurs `dup2()` pour enchaîner des programmes (ex: `cmd1 | cmd2`).

---

## 📖 Cours & Notions Détaillées

---

### 1. Qu'est-ce qu'un Processus sous Linux ? (PID & PCB)

#### 🔍 Définition formelle & Fonctionnement interne
Un **processus** est l'abstraction du système d'exploitation représentant un programme en cours d'exécution. Chaque processus est strictement isolé des autres grâce à la mémoire virtuelle (gérée par la MMU du processeur).

Dans le noyau Linux, un processus est décrit par une structure C colossale appelée **PCB (Process Control Block)**, matérialisée par `struct task_struct` (définie dans `<linux/sched.h>`). Elle contient :
1. **L'identité :** Son identifiant unique **PID** (*Process ID*) et celui de son parent **PPID** (*Parent Process ID*).
2. **L'espace mémoire virtuel :** Pointeurs vers les tables de pages (segment de code `Text`, variables globales `Data`/`BSS`, tas dynamique `Heap`, pile d'exécution `Stack`).
3. **La table des descripteurs de fichiers :** Tableau indexé pointant vers les structures de fichiers ouverts dans le noyau (`stdin = 0`, `stdout = 1`, `stderr = 2`, etc.).
4. **L'état d'ordonnancement :** Prêt (*Running*), Endormi (*Sleeping/Interruptible*), Arrêté (*Stopped*), Zombie.
5. **Les informations de sécurité :** UID (utilisateur), GID (groupe), masques de signaux et priorités d'ordonnancement.

Les fonctions d'identification immédiates sont :
```c
#include <unistd.h>
#include <sys/types.h>

pid_t getpid(void);   // Renvoie le PID du processus appelant (toujours un succès)
pid_t getppid(void);  // Renvoie le PID du père du processus appelant
```

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
- **Identification des logs et traçabilité :** Distinguer quel processus a généré quelle ligne de log dans un système multi-processus ou un cluster de calcul.
- **Fichiers temporaires uniques :** Créer des fichiers temporaires garantis sans collision de nom : `/tmp/job_worker_14892.tmp`.
- **Envoi de signaux ciblés :** Permet à un processus d'en envoyer à un autre via `kill(pid, SIGTERM)`.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <unistd.h>

int main(void) {
    pid_t mon_pid = getpid();
    pid_t parent_pid = getppid();

    printf("Mon identifiant (PID)       : %d\n", (int)mon_pid);
    printf("L'identifiant de mon père (PPID) : %d\n", (int)parent_pid);

    return 0;
}
```
**Ce que fait ce code et pourquoi :**
- Lorsque vous lancez ce binaire depuis votre terminal bash, `mon_pid` est le PID attribué à ce programme, et `parent_pid` est le PID de votre shell bash qui l'a lancé.

---

### 2. L'appel système `fork(2)` & L'optimisation Copy-On-Write (COW)

#### 🔍 Définition formelle & Fonctionnement interne
```c
#include <unistd.h>
#include <sys/types.h>

pid_t fork(void);
```
- **Rôle :** Crée un nouveau processus (le **fils**) en dupliquant le processus appelant (le **père**).
- **Le prodige du `fork` :** Il est **appelé une seule fois**, mais il **retourne deux fois** dans deux espaces mémoires distincts au même point du code :
  - **Dans le processus PÈRE :** `fork()` renvoie le **PID du fils** nouvellement créé (un entier strictement positif $> 0$).
  - **Dans le processus FILS :** `fork()` renvoie **`0`**. Cela permet au fils de savoir qu'il est le fils.
  - **En cas d'erreur :** `fork()` renvoie **`-1`**, aucun fils n'est créé, et la variable globale `errno` est positionnée (ex: `EAGAIN` si la limite maximale de processus système `ulimit -u` est atteinte, ou `ENOMEM` si la mémoire vive est épuisée).

#### 🔬 Sous le capot : Qu'est-ce que le Copy-On-Write (COW) ?
À l'origine d'UNIX, `fork()` copiait intégralement toute la mémoire vive du père dans le fils. Si un programme consommait 4 Go de RAM, `fork()` prenait des dizaines de millisecondes pour allouer 4 Go et tout recopier !

Sur les systèmes modernes (Linux) :
1. Lors du `fork()`, le noyau ne copie **pas** la mémoire physique. Il duplique uniquement la **table des pages virtuelles**.
2. Les deux processus pointent physiquement vers les **mêmes cases de RAM**.
3. Le noyau marque toutes les pages partagées en **Lecture Seule (*Read-Only*)**.
4. Dès que l'un des deux processus tente de modifier une variable (`écriture`), la MMU matérielle déclenche une interruption processeur (*Page Fault*).
5. Le noyau intercepte le défaut, alloue **uniquement à cet instant** une nouvelle page de 4 Ko physique, y copie les données, rend la page accessible en écriture et relance l'instruction.
- **Résultat :** `fork()` s'exécute en quelques microsecondes, quasi instantanément !

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Parallélisme & Exploitation Multi-Cœurs :** Découper un calcul lourd (ex: rendu 3D, traitement d'images d'un OCR, compilation avec `make -j8`) sur plusieurs cœurs sans partage de mémoire dangereux (contrairement aux threads qui partagent la même mémoire et risquent des *data races* sans mutex).
2. **Isolation & Résilience aux plantages :** Si un processus fils plante à cause d'une erreur de segmentation (`SIGSEGV`), le père reste vivant et peut relancer un fils propre (architecture des serveurs Web comme Apache ou NGINX, ou des onglets du navigateur Google Chrome).
3. **Exécution de commandes externes :** Permet à un shell d'exécuter des programmes (`ls`, `grep`) tout en conservant son propre état.

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

int main(void) {
    int variable_locale = 42;
    printf("[PID %d] Avant le fork...\n", getpid());

    pid_t pid = fork();

    // 1. Gestion de l'erreur d'échec de création
    if (pid < 0) {
        perror("Échec critique de fork");
        exit(EXIT_FAILURE);
    }

    // 2. Branche exécutée EXCLUSIVEMENT par le processus FILS
    if (pid == 0) {
        printf("[FILS] Je suis le fils (PID=%d, mon père est PPID=%d)\n", 
               getpid(), getppid());
        variable_locale += 10; // Déclenche le Copy-On-Write sur cette page de pile
        printf("[FILS] Ma variable locale modifiée vaut : %d\n", variable_locale);
        
        // Le fils termine son travail et quitte proprement
        exit(0);
    } 
    
    // 3. Branche exécutée EXCLUSIVEMENT par le processus PÈRE
    else {
        printf("[PÈRE] Je suis le père (PID=%d). J'ai créé le fils de PID=%d\n", 
               getpid(), pid);
        printf("[PÈRE] Ma variable locale est INTACTE et vaut : %d\n", variable_locale);
        
        // Pause pour observer la coexistence des deux processus
        sleep(1);
    }

    printf("[PID %d] Fin normale d'un processus.\n", getpid());
    return 0;
}
```
**Ce que fait ce code et pourquoi :**
- L'instruction conditionnelle `if (pid == 0)` est la structure universelle en C pour scinder le comportement entre le père et le fils.
- La modification de `variable_locale += 10` dans le fils ne modifie **absolument pas** la variable dans le père (qui reste à 42). Cela démontre l'isolation totale des espaces d'adressage grâce au Copy-On-Write.

---

### 3. Cycle de Vie : Processus Zombie vs Processus Orphelin

#### 🔍 Définition formelle & Fonctionnement interne

```
[Création via fork()]
        │
        ▼
   [Exécution]
        │
        ▼
  [Appel exit()] ────► Le processus libère sa RAM, ses fichiers et ses verrous.
        │
        ▼
   [État ZOMBIE] ────► Le PCB reste dans la table noyau avec son code de retour.
        │
   (Le père appelle wait())
        │
        ▼
 [Disparition totale]
```

1. **Le Processus ZOMBIE (`<defunct>`) :**
   - Lorsqu'un processus se termine avec `exit(code)`, le noyau désalloue immédiatement sa mémoire vive (RAM) et ferme ses descripteurs de fichiers.
   - **Mais** son entrée dans la table des processus (son PCB) est **conservée** par le noyau jusqu'à ce que son père vienne lire son code de retour via `wait()` ou `waitpid()`.
   - Tant que le père n'a pas lu ce code, le processus est dans l'état **ZOMBIE** (visible dans `ps aux` avec l'état `Z` ou `[nom] <defunct>`).
   - **Le danger :** Un zombie ne consomme pas de RAM, mais il **consomme un PID**. Si un programme père crée des milliers de fils sans jamais appeler `wait()`, la table des processus du noyau se remplit jusqu'à saturation (`PID exhaustion`). Plus aucun utilisateur ne peut alors lancer de commande sur la machine !

2. **Le Processus ORPHELIN :**
   - Un processus devient **orphelin** lorsque son processus père se termine **avant lui**.
   - Le système d'exploitation ne laisse jamais un processus sans parent : le fils est immédiatement **adopté** par le processus racine du système (historiquement `init`, aujourd'hui `systemd`, ayant le **PID 1**).
   - Le processus `systemd` (PID 1) exécute en boucle des appels `wait()` : ainsi, dès qu'un processus orphelin se termine, `systemd` nettoie immédiatement son PCB, empêchant tout zombie persistant.

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
- **Création de Démons (*Daemons*) :** Les services d'arrière-plan sous Linux (serveurs HTTP, bases de données) utilisent la technique du "double-fork" pour devenir orphelins volontairement, se détacher du terminal de contrôle et tourner en arrière-plan sans bloquer la session de l'utilisateur.

#### 💻 Exemple concret & Explication pas à pas (Démonstration d'un Zombie)
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
    pid_t pid = fork();

    if (pid == 0) {
        // Processus FILS : s'arrête immédiatement
        printf("[FILS %d] Je termine tout de suite mon travail.\n", getpid());
        exit(42); 
    } else {
        // Processus PÈRE : dort 10 secondes SANS appeler wait()
        printf("[PÈRE %d] Mon fils %d est mort mais je ne l'attends pas !\n", getpid(), pid);
        printf("[PÈRE] Ouvrez un autre terminal et tapez : ps aux | grep 'Z'\n");
        sleep(10); // Pendant ces 10 secondes, le fils apparaît en ZOMBIE dans le système !
        printf("[PÈRE] Fin du père.\n");
    }
    return 0;
}
```

---

### 4. Synchronisation : `wait(2)`, `waitpid(2)` & Macros d'analyse d'état

#### 🔍 Définition formelle & Fonctionnement interne
```c
#include <sys/types.h>
#include <sys/wait.h>

pid_t wait(int *wstatus);
pid_t waitpid(pid_t pid, int *wstatus, int options);
```
- **`wait(&wstatus)` :** Bloque le père jusqu'à ce que **l'un quelconque** de ses fils se termine. Renvoie le PID du fils terminé (ou `-1` s'il n'y a plus aucun fils).
- **`waitpid(pid, &wstatus, options)` :** Permet un contrôle chirurgical :
  - `pid > 0` : Attend spécifiquement le fils de PID égal à `pid`.
  - `pid == -1` : Attend n'importe quel fils (équivalent à `wait`).
  - `options = WNOHANG` : **Mode non-bloquant**. Si aucun fils n'est terminé au moment de l'appel, la fonction n'attend pas et renvoie immédiatement `0`.

#### 🔬 Décodage de l'entier `wstatus` via les macros POSIX
L'entier `wstatus` n'est pas simplement le code de retour brut ; c'est un mot binaire compacté contenant à la fois la raison de la mort, les bits de signal et le code de sortie. **Il ne faut jamais lire `wstatus` directement, mais TOUJOURS utiliser les macros officielles :**

| Macro POSIX | Signification & Rôle |
| :--- | :--- |
| **`WIFEXITED(status)`** | Renvoie vrai ($>0$) si le processus s'est terminé **normalement** (via `exit()` ou un `return` du `main`). |
| **`WEXITSTATUS(status)`** | Extrait le **code de retour réel** ($0$ à $255$). Valide **uniquement** si `WIFEXITED(status)` est vrai. |
| **`WIFSIGNALED(status)`** | Renvoie vrai si le processus a été **tué par un signal** non intercepté (ex: `SIGSEGV`, `SIGKILL`, `SIGINT`). |
| **`WTERMSIG(status)`** | Donne le **numéro du signal tueur** (ex: `SIGSEGV = 11`, `SIGFPE = 8`). Valide si `WIFSIGNALED` est vrai. |

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Élimination systématique des zombies :** Libérer la table des processus du système.
2. **Récupération des codes d'erreur :** Un script bash ou un compilateur doit savoir si la compilation d'un fichier source a réussi (`exit(0)`) ou échoué (`exit(1)`).
3. **Détection de crashs mémoires :** Détecter si un sous-processus de test a fait un crash mémoire sans faire planter le lanceur de tests (*test runner*).

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    pid_t pid = fork();

    if (pid == 0) {
        printf("[FILS] Début du calcul lourd...\n");
        sleep(1);
        printf("[FILS] Fin avec code d'erreur 7.\n");
        exit(7); // Code de retour volontaire
    }

    // Processus PÈRE
    int status;
    printf("[PÈRE] J'attends la fin de mon fils (PID=%d)...\n", pid);

    // Appel bloquant : le père est suspendu par l'ordonnanceur jusqu'à la mort du fils
    pid_t finished_pid = waitpid(pid, &status, 0);

    if (finished_pid == -1) {
        perror("Erreur waitpid");
        exit(EXIT_FAILURE);
    }

    // Analyse experte du statut de terminaison
    if (WIFEXITED(status)) {
        int exit_code = WEXITSTATUS(status);
        printf("[PÈRE] Le fils %d s'est terminé normalement avec le code : %d\n", 
               finished_pid, exit_code);
    } else if (WIFSIGNALED(status)) {
        int sig = WTERMSIG(status);
        printf("[PÈRE] ALERTE : Le fils %d a été tué par le signal numéro %d !\n", 
               finished_pid, sig);
    }

    return 0;
}
```

---

### 5. Le Binôme Canonique : `fork()` + Famille `exec*()`

#### 🔍 Définition formelle & Fonctionnement interne
Les fonctions de la famille `exec` (`execl`, `execlp`, `execv`, `execvp`, `execve`) **remplacent l'intégralité de l'espace d'adressage du processus appelant** par un nouveau programme exécutable chargé depuis le disque.
- Le segment de code (`Text`), les variables (`Data`, `BSS`), la pile (`Stack`) et le tas (`Heap`) sont entièrement effacés et réinitialisés avec le nouveau binaire.
- **Le PID reste le même !** Le processus ne meurt pas, il change simplement d'identité de programme.
- **Règle absolue :** En cas de succès, une fonction `exec` **ne retourne jamais**. Si l'instruction suivante est exécutée, c'est obligatoirement qu'une erreur s'est produite (ex: binaire introuvable, permissions d'exécution manquantes).

#### 🔬 Comprendre la nomenclature des fonctions `exec` :
| Lettre | Signification | Exemple | Description |
| :---: | :--- | :--- | :--- |
| **`l`** | *List* | `execlp("ls", "ls", "-l", NULL)` | Arguments passés un par un sous forme de liste terminée par `NULL`. |
| **`v`** | *Vector* | `execvp("ls", argv)` | Arguments passés sous forme d'un tableau `char *argv[]` terminé par `NULL`. |
| **`p`** | *Path* | `execvp`, `execlp` | Recherche le binaire automatiquement dans la variable d'environnement `$PATH`. |
| **`e`** | *Environment* | `execve` (seul vrai appel système) | Permet de passer un tableau d'environnement personnalisé `char *envp[]`. |

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
C'est le mécanisme fondamental par lequel fonctionne **absolument tout shell UNIX (bash, zsh)** :
1. Le shell affiche une invite et lit une commande tapée par l'utilisateur (ex: `ls -la`).
2. Le shell appelle `fork()` pour créer un clone de lui-même.
3. Le fils appelle `execvp("ls", args)` pour devenir le programme `ls`.
4. Le père (le shell) appelle `waitpid()` pour attendre que `ls` ait fini d'afficher la liste des fichiers, puis réaffiche son invite de commande !

#### 💻 Exemple concret & Explication pas à pas
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    pid_t pid = fork();

    if (pid == 0) {
        // Dans le processus FILS : on va exécuter la commande "ls -l /tmp"
        char *args[] = {
            "ls",       // argv[0] : conventionnellement le nom de la commande
            "-l",       // argv[1]
            "/tmp",     // argv[2]
            NULL        // OBLIGATOIRE : le tableau DOIT être terminé par NULL !
        };

        printf("[FILS] Remplacement de mon image mémoire par 'ls'...\n");
        execvp("ls", args);

        // Cette ligne n'est atteinte QUE si execvp a échoué !
        perror("Échec de execvp");
        exit(EXIT_FAILURE);
    }

    // Dans le processus PÈRE
    int status;
    waitpid(pid, &status, 0); // Attend que 'ls' termine son affichage
    printf("[PÈRE] La commande externe s'est terminée avec succès.\n");

    return 0;
}
```

---

### 6. Communication Inter-Processus : `pipe(2)` & Redirection `dup2(2)`

#### 🔍 Définition formelle & Fonctionnement interne
- **`int pipe(int pipefd[2]);` :**  
  Crée un canal de communication unidirectionnel géré en mémoire tampon dans le noyau (taille classique : 64 Ko).
  - `pipefd[0]` : Descripteur ouvert en **lecture seule** (*Read end*).
  - `pipefd[1]` : Descripteur ouvert en **écriture seule** (*Write end*).
  - Les données écrites dans `pipefd[1]` sont lues dans le même ordre (FIFO) depuis `pipefd[0]`.
- **`int dup2(int oldfd, int newfd);` :**  
  Ferme silencieusement `newfd` s'il était ouvert, puis duplique `oldfd` vers `newfd`. Après cet appel, `newfd` et `oldfd` font référence exactement au même fichier/flux.
  - Exemple canonique : `dup2(pipefd[1], STDOUT_FILENO)` fait en sorte que toute écriture sur la sortie standard (`printf`, `stdout`, descripteur 1) atterrisse directement dans le tube !

#### 🔬 La règle d'or des tubes : Fermeture des descripteurs inutilisés
Lorsqu'un processus lit sur un tube avec `read()`, l'appel ne renvoie `0` (Fin de Fichier / `EOF`) **QUE si TOUS les descripteurs d'écriture du tube dans tout le système sont fermés**.  
Puisque `fork()` duplique la table des descripteurs de fichiers, le père ET le fils possèdent tous deux une copie de `pipefd[0]` et `pipefd[1]`.  
**Si le processus lecteur oublie de fermer sa propre copie de `pipefd[1]`, son appel `read()` se bloquera indéfiniment en attendant des données qui ne viendront jamais (*Deadlock*) !**

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
Permet d'implémenter le symbole tube du shell : `ls -l | wc -l`. Le programme `ls` écrit ses résultats dans le pipe, et le programme `wc` lit l'entrée depuis ce même pipe pour compter les lignes, sans jamais écrire aucun fichier temporaire sur le disque dur.

#### 💻 Exemple concret & Explication pas à pas (Implémentation de `ls | wc -l`)
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pfd[2];

    // 1. Création du tube avant le fork pour que les deux processus en héritent
    if (pipe(pfd) == -1) {
        perror("Échec pipe");
        exit(EXIT_FAILURE);
    }

    pid_t pid1 = fork();
    if (pid1 == 0) {
        // --- PREMIER FILS : exécute "ls" ---
        // Il doit écrire dans le tube au lieu de l'écran (stdout)
        dup2(pfd[1], STDOUT_FILENO);

        // Fermeture des deux descripteurs devenus inutiles après duplication
        close(pfd[0]);
        close(pfd[1]);

        execlp("ls", "ls", NULL);
        perror("Erreur execlp ls");
        exit(EXIT_FAILURE);
    }

    pid_t pid2 = fork();
    if (pid2 == 0) {
        // --- SECOND FILS : exécute "wc -l" ---
        // Il doit lire depuis le tube au lieu du clavier (stdin)
        dup2(pfd[0], STDIN_FILENO);

        close(pfd[0]);
        close(pfd[1]);

        execlp("wc", "wc", "-l", NULL);
        perror("Erreur execlp wc");
        exit(EXIT_FAILURE);
    }

    // --- PROCESSUS PÈRE ---
    // Le père n'utilise ni la lecture ni l'écriture du tube : il DOIT les fermer !
    // Si le père ne ferme pas pfd[1], wc ne recevra JAMAIS de fin de fichier (EOF).
    close(pfd[0]);
    close(pfd[1]);

    // Attente des deux fils
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);

    return 0;
}
```

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **Le piège du Buffer `printf` et du Flush avant `fork()` :**  
> `printf` utilise un tampon en espace utilisateur (RAM du processus). Si vous écrivez `printf("Bonjour");` (sans `\n`) juste avant un `fork()`, le tampon non vidé est **dupliqué dans le fils**. Lors de la terminaison, le père ET le fils videront le tampon, affichant `"BonjourBonjour"` à l'écran !  
> **Bonne pratique :** Toujours terminer par `\n` ou appeler `fflush(stdout);` avant tout appel à `fork()`.

> [!warning]
> **La Bombe Fork (*Fork Bomb*) :**  
> Un code comme :
> ```c
> while(1) { fork(); }
> ```
> crée une croissance exponentielle de processus ($2^n$). En quelques secondes, le système alloue des millions de tâches, sature la table des processus du noyau Linux et fige complètement la machine (nécessitant un redémarrage électrique forcé).  
> **Protection système :** Les administrateurs configurent `ulimit -u 500` ou des groupes de contrôle (*cgroups*) sous Linux pour limiter le nombre maximal de processus par utilisateur.

---

## ❓ Questions de Révision & Cas Pratiques

1. **Combien de processus au total sont créés par la séquence suivante : `fork(); fork(); fork();` ?**
   - **8 processus au total** (le processus initial + 7 nouveaux). Chaque appel à `fork()` double le nombre de processus existants ($2^3 = 8$).
2. **Quelle est la différence fondamentale entre un processus Zombie et un processus Orphelin ?**
   - Un **Zombie** est mort (`exit` déjà appelé) mais son père ne l'a pas attendu (`wait` manquant) : son PCB reste bloqué dans le noyau. Un **Orphelin** est bien vivant mais son père est mort prématurément : il est alors adopté par `systemd` (PID 1).
3. **Pourquoi le code situé après un appel `exec*()` n'est-il normalement jamais exécuté ?**
   - Parce que la fonction `exec` écrase intégralement la mémoire du processus appelant (y compris son code assembleur en cours d'exécution) par le nouveau programme. Si le processeur revient à la ligne suivante, c'est obligatoirement que l'exécutable n'a pas pu être chargé (erreur).
4. **Que se passe-t-il si un processus tente de lire (`read`) sur un `pipe` dont tous les descripteurs d'écriture ont été fermés ?**
   - L'appel `read()` renvoie immédiatement `0`, ce qui indique la fin de fichier (*End Of File* / `EOF`). C'est ainsi qu'un filtre UNIX sait qu'il a traité toutes les données d'entrée.

---
*Index général : [[Programmation/README]]* | *Accueil : [[Bienvenue]]*

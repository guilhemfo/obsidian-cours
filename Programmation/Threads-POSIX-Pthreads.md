---
title: "Synthèse Système UNIX — Threads POSIX (pthreads), Mutex, Conditions & Synchronisation"
matiere: "Programmation"
date: "2026-10-13"
tags: [fiche, revision, programmation, c, epita, s3, systeme, unix, posix, threads, pthreads, mutex, synchronisation, concurrence]
source: "EPITA S3 FISE 2030 – Programmation Système Avancée en C (POSIX / UNIX)"
---

# 🧵 Programmation Multithread en C : Threads POSIX (`pthread`), Mutex & Synchronisation

> **Matière :** Programmation Système Avancée en C (EPITA Promo 2030 - S3)  
> **Cadre :** Concurrence, parallélisme et synchronisation POSIX sous UNIX/Linux  
> **En-têtes standards nécessaires :** `<pthread.h>`, `<semaphore.h>`, `<stdlib.h>`, `<stdio.h>`, `<unistd.h>`, `<errno.h>`  
> **Option de compilation obligatoire :** `gcc -Wall -Wextra -pthread main.c -o main`

---

## 🎯 Points Clés

- **Processus vs Thread :**
  - Un **processus** possède son propre espace mémoire virtuel isolé (lourd, protégé par la MMU).
  - Un **thread** (*fil d'exécution* ou *LWP - Light Weight Process*) partage le **même espace mémoire** (tas, variables globales, descripteurs de fichiers) que les autres threads du même processus, mais possède sa **propre pile d'exécution (*stack*)**, ses registres CPU et son identifiant.
- **La bibliothèque POSIX (`<pthread.h>`) :**
  - Fonctions préfixées par `pthread_`.
  - Toujours compiler avec l'option **`-pthread`** (qui active les macros de réentrance comme `_REENTRANT` et lie la bibliothèque système adéquate).
- **Cycle de vie :**
  - `pthread_create()` : Lance l'exécution concurrente d'une fonction `void *routine(void *arg)`.
  - `pthread_join()` : Attend la fin d'un thread et récupère sa valeur de retour (évite les threads zombies).
  - `pthread_detach()` : Indique au système de libérer automatiquement les ressources du thread dès sa fin, sans attendre un `join`.
  - `pthread_exit()` : Termine uniquement le thread appelant (contrairement à `exit()` qui tue **tout** le processus et tous ses threads !).
- **Course critique (*Race Condition*) :** Accès concurrent non synchronisé d'au moins deux threads à une donnée partagée avec au moins une écriture. L'ordre d'exécution dépend de l'ordonnanceur et engendre des résultats corrompus imprévisibles.
- **Exclusion mutuelle (`pthread_mutex_t`) :** Garantit qu'un seul thread à la fois exécute une section critique protégée par `pthread_mutex_lock()` et `pthread_mutex_unlock()`.
- **Variables de condition (`pthread_cond_t`) :** Permettent d'endormir un thread en attendant qu'une condition logique devienne vraie, évitant l'attente active (*busy-waiting*). Règle d'or : **toujours utiliser une boucle `while`** autour de `pthread_cond_wait()` contre les réveils intempestifs (*spurious wakeups*).
- **Détection des bugs :** Compiler avec **`-fsanitize=thread -g`** (ThreadSanitizer) ou utiliser `valgrind --tool=helgrind` pour traquer les *data races* et interblocages (*deadlocks*).

---

## 📖 Cours & Notions Détaillées

---

### 1. Processus vs Thread : Anatomie & Modèle Mémoire

#### 🔍 Définition formelle & Fonctionnement interne
Un **thread** (ou unité de traitement léger) est un flux de contrôle séquentiel au sein d'un processus. Sous Linux, le noyau implémente le modèle **1:1** via la bibliothèque **NPTL** (*Native POSIX Thread Library*) : chaque thread utilisateur correspond directement à une entité ordonnançable par le noyau créée via l'appel système `clone(2)`.

```
┌─────────────────────────────────────────────────────────────┐
│                 ESPACE MÉMOIRE DU PROCESSUS                 │
│                                                             │
│  [Code / Text]         Partagé par tous les threads         │
│  [Variables globales]  Partagé (.data / .bss)               │
│  [Tas / Heap]          Partagé (malloc / free commun)       │
│  [Descripteurs Fich.]  Partagé (stdin, stdout, sockets...)  │
│                                                             │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐   │
│  │ Pile Thread 1  │ │ Pile Thread 2  │ │ Pile Thread 3  │   │
│  │ (Stack ~8 Mo)  │ │ (Stack ~8 Mo)  │ │ (Stack ~8 Mo)  │   │
│  │ Variables loc. │ │ Variables loc. │ │ Variables loc. │   │
│  │ Registres (PC) │ │ Registres (PC) │ │ Registres (PC) │   │
│  └────────────────┘ └────────────────┘ └────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

#### ⚖️ Tableau comparatif Processus vs Thread

| Caractéristique | Processus (`fork`) | Thread (`pthread_create`) |
| :--- | :--- | :--- |
| **Espace mémoire** | Isolé (dupliqué en *Copy-On-Write*) | **Partagé** (même tas, mêmes globales) |
| **Pile d'exécution (*Stack*)** | Distincte | **Distincte** pour chaque thread |
| **Descripteurs de fichiers** | Dupliqués | **Partagés** (un `close()` impacte tous les threads) |
| **Coût de création / destruction** | Élevé (~quelques microsecondes) | Très faible (~dix fois plus rapide) |
| **Commutation de contexte (*Context Switch*)** | Lourde (invalidation de la table des pages MMU / TLB) | Légère (pas de changement de table de pages) |
| **Conséquence d'un crash (`SIGSEGV`)** | Seul le processus fils plante | **Tout le processus et tous les threads meurent !** |
| **Communication** | IPC (pipes, sockets, shm, signaux) | Directe par pointeurs et mémoire partagée |

#### 💡 À quoi ça sert concrètement ? (Utilité en pratique)
1. **Serveurs réseau à haute concurrence :** Traiter des milliers de requêtes clients simultanées (ex: un thread worker par requête) sans le surcoût de `fork()`.
2. **Calcul parallèle intensif (HPC / IA / 3D) :** Exploiter tous les cœurs CPU pour découper une matrice, filtrer une image ou encoder une vidéo en parallèle.
3. **Réactivité d'interface utilisateur (GUI) :** Garder l'interface fluide pendant qu'un thread d'arrière-plan télécharge un fichier ou calcule un rendu lourd.

---

### 2. Cycle de Vie d'un Thread : Création, Exécution & Synchronisation

#### 🔍 Les fonctions clés de l'API POSIX

```c
#include <pthread.h>

// 1. Création
int pthread_create(pthread_t *thread, 
                   const pthread_attr_t *attr,
                   void *(*start_routine)(void *), 
                   void *arg);

// 2. Attente de terminaison
int pthread_join(pthread_t thread, void **retval);

// 3. Terminaison propre
void pthread_exit(void *retval);

// 4. Détachement
int pthread_detach(pthread_t thread);

// 5. Identification
pthread_t pthread_self(void);
int pthread_equal(pthread_t t1, pthread_t t2);
```

- **`pthread_create` :**
  - `thread` : Pointeur vers une variable `pthread_t` qui recevra l'identifiant opaque du thread créé.
  - `attr` : Attributs de configuration (taille de pile, état détaché). Passer `NULL` pour les attributs par défaut.
  - `start_routine` : Pointeur sur fonction prenant un `void *` et retournant un `void *`.
  - `arg` : L'unique argument transmis à la routine (casté en `void *`).
  - **Retour :** Renvoie `0` en cas de succès, ou un code d'erreur direct (`EAGAIN`, `EINVAL`, etc. — **attention : ces fonctions ne modifient généralement pas `errno`, elles renvoient directement le code d'erreur !**).
- **`pthread_join` :**
  - Équivalent de `waitpid` pour les threads. Suspend le thread appelant jusqu'à ce que le thread cible désigné par `thread` se termine.
  - `retval` : Pointeur vers un `void *` où sera stockée l'adresse de la valeur de retour (fournie via `return` ou `pthread_exit`). Si le retour ne vous intéresse pas, passer `NULL`.
- **`pthread_exit` :**
  - Quitte le thread appelant en transmettant `retval` au thread qui fera le `join`.
  - Si le `main()` appelle `pthread_exit(NULL)`, le thread principal se termine mais les autres threads continuent de s'exécuter jusqu'à leur propre fin ! En revanche, un simple `return 0;` ou `exit(0)` dans le `main` tue immédiatement tout le processus.

#### 💻 Exemple concret : Création et passage propre de données

> [!important]
> **Règle absolue pour passer des arguments :**  
> Si vous créez plusieurs threads dans une boucle `for (int i = 0; i < N; i++)`, **ne passez JAMAIS `&i`** ! La variable `i` est modifiée par la boucle avant que les threads n'aient eu le temps de la lire (Race Condition). Il faut soit passer une copie par valeur transtypée, soit une structure allouée dynamiquement ou indicée.

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define NB_THREADS 4

// Structure pour encapsuler les paramètres et les résultats
typedef struct {
    int id;
    int debut;
    int fin;
    long long resultat;
} ThreadData;

// Routine exécutée par chaque thread
void *calcul_somme(void *arg) {
    ThreadData *data = (ThreadData *)arg;
    data->resultat = 0;

    printf("[Thread %d] Calcul de la somme de %d à %d...\n", 
           data->id, data->debut, data->fin);

    for (int i = data->debut; i <= data->fin; i++) {
        data->resultat += i;
    }

    // Terminaison en renvoyant le pointeur vers la structure
    pthread_exit((void *)data);
}

int main(void) {
    pthread_t threads[NB_THREADS];
    ThreadData donnees[NB_THREADS];
    int intervalle = 250000;

    // 1. Création des threads avec partitionnement des données
    for (int i = 0; i < NB_THREADS; i++) {
        donnees[i].id = i + 1;
        donnees[i].debut = i * intervalle + 1;
        donnees[i].fin = (i + 1) * intervalle;

        int ret = pthread_create(&threads[i], NULL, calcul_somme, &donnees[i]);
        if (ret != 0) {
            fprintf(stderr, "Erreur pthread_create (code %d)\n", ret);
            exit(EXIT_FAILURE);
        }
    }

    long long somme_totale = 0;

    // 2. Attente de la fin des threads et agrégation des résultats
    for (int i = 0; i < NB_THREADS; i++) {
        void *retour = NULL;
        int ret = pthread_join(threads[i], &retour);
        if (ret != 0) {
            fprintf(stderr, "Erreur pthread_join (code %d)\n", ret);
            exit(EXIT_FAILURE);
        }

        ThreadData *res = (ThreadData *)retour;
        printf("[MAIN] Thread %d a terminé avec le sous-total : %lld\n", 
               res->id, res->resultat);
        somme_totale += res->resultat;
    }

    printf("[MAIN] Somme globale finale : %lld\n", somme_totale);
    return 0;
}
```

---

### 3. La Concurrence & Le Piège des Race Conditions (*Data Races*)

#### 🔍 Pourquoi `compteur++` est-il dangereux en multithread ?
En C, une ligne comme `compteur++` paraît élémentaire et atomique. Or, au niveau du processeur, elle se traduit par **3 instructions assembleur distinctes** :

1. **`READ` :** Charger la valeur de la case mémoire en RAM dans un registre CPU (`mov eax, [compteur]`).
2. **`MODIFY` :** Incrémenter la valeur du registre (`add eax, 1`).
3. **`WRITE` :** Réécrire la nouvelle valeur du registre vers la RAM (`mov [compteur], eax`).

#### 🔬 Démonstration de l'entrelacement fautif (*Race Condition*) :
Supposons que `compteur = 10` et que deux threads veulent l'incrémenter simultanément :

```
Temps   Thread 1                    Thread 2               Valeur en RAM
  │     READ (eax1 = 10)                                         10
  ▼        [Commutation de contexte CPU !]
        ──                         READ (eax2 = 10)              10
        ──                         MODIFY (eax2 = 11)            10
        ──                         WRITE (RAM = 11)              11
           [Commutation de contexte CPU !]
        MODIFY (eax1 = 11)         ──                            11
        WRITE (RAM = 11)           ──                            11  <-- ERREUR !
```

- **Bilan :** Deux incrémentations ont eu lieu, mais le compteur final vaut **11 au lieu de 12**. Une incrémentation a été totalement écrasée et perdue !
- Une portion de code qui manipule ainsi une ressource partagée est appelée une **section critique**.

---

### 4. Exclusion Mutuelle : Les Mutex (`pthread_mutex_t`)

#### 🔍 Définition formelle & Fonctionnement interne
Un **Mutex** (*Mutual Exclusion*) est un verrou d'exclusion mutuelle. Il ne peut être possédé que par **un seul thread à la fois**.
- Si un thread tente d'acquérir un mutex déjà verrouillé par un autre thread via `pthread_mutex_lock()`, le thread appelant est **bloqué et endormi par le système** jusqu'à ce que le propriétaire le libère avec `pthread_mutex_unlock()`.

```c
#include <pthread.h>

// Initialisation statique (pour variables globales/statiques) :
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// Initialisation dynamique (pour variables sur le tas ou locales) :
int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *attr);

// Verrouillage (bloquant) :
int pthread_mutex_lock(pthread_mutex_t *mutex);

// Tentative de verrouillage non-bloquante (renvoie EBUSY si déjà verrouillé) :
int pthread_mutex_trylock(pthread_mutex_t *mutex);

// Déverrouillage :
int pthread_mutex_unlock(pthread_mutex_t *mutex);

// Destruction (libère les ressources noyau associées au mutex) :
int pthread_mutex_destroy(pthread_mutex_t *mutex);
```

#### 💻 Exemple concret : Protection d'un compteur partagé

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NB_ITERATIONS 1000000

long compteur = 0;
pthread_mutex_t mon_mutex = PTHREAD_MUTEX_INITIALIZER;

void *incrementer(void *arg) {
    (void)arg;
    for (int i = 0; i < NB_ITERATIONS; i++) {
        // --- DÉBUT SECTION CRITIQUE ---
        pthread_mutex_lock(&mon_mutex);
        compteur++;
        pthread_mutex_unlock(&mon_mutex);
        // --- FIN SECTION CRITIQUE ---
    }
    return NULL;
}

int main(void) {
    pthread_t t1, t2;

    pthread_create(&t1, NULL, incrementer, NULL);
    pthread_create(&t2, NULL, incrementer, NULL);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    // Résultat garanti : 2000000 exactement, sans perte !
    printf("Compteur final : %ld (Attendu : %d)\n", 
           compteur, 2 * NB_ITERATIONS);

    pthread_mutex_destroy(&mon_mutex);
    return 0;
}
```

#### ⚠️ Le Danger Suprême : L'Interblocage (*Deadlock*)

Un **Deadlock** se produit lorsque deux threads sont bloqués à l'infini, chacun attendant une ressource verrouillée par l'autre.

```
Thread A a verrouillé Mutex 1 ──(veut verrouiller)──► Mutex 2 (détenu par B)
                                                            ▲
Thread B a verrouillé Mutex 2 ──(veut verrouiller)──────────┘
```

**Règle d'or pour prévenir les interblocages (Ordre Total / Lock Ordering) :**  
Tous les threads du programme doivent **toujours acquérir les verrous dans le même ordre strict** (ex: toujours `Mutex 1` PUIS `Mutex 2`, et libérer dans l'ordre inverse `Mutex 2` PUIS `Mutex 1`).

---

### 5. Coordination par Événements : Variables de Condition (`pthread_cond_t`)

#### 🔍 Pourquoi un Mutex seul ne suffit-il pas ?
Supposons qu'un thread doive attendre qu'un tableau contienne des données avant de les traiter.
Sans variable de condition, le thread devrait faire une **attente active (*busy-waiting*)** :
```c
// DÉSASTREUX : consomme 100% d'un cœur CPU à tourner dans le vide !
while (1) {
    pthread_mutex_lock(&mutex);
    if (nb_elements > 0) {
        // traiter...
        pthread_mutex_unlock(&mutex);
        break;
    }
    pthread_mutex_unlock(&mutex);
}
```

Une **Variable de Condition** résout ce problème en permettant à un thread de **s'endormir complètement** (0% CPU) et d'être réveillé uniquement lorsqu'un signal lui indique qu'un événement s'est produit.

#### ⚙️ Fonctionnement atomique de `pthread_cond_wait`
L'appel `pthread_cond_wait(&cond, &mutex)` réalise de façon **atomique** :
1. La **libération du mutex** passé en paramètre.
2. La **mise en sommeil** du thread appelant sur la file d'attente de la condition `cond`.
3. Au moment du réveil (via `signal` ou `broadcast`), le thread **ré-acquiert obligatoirement le mutex** avant de sortir de la fonction `pthread_cond_wait`.

#### 🔬 Pourquoi TOUJOURS une boucle `while` et jamais un `if` ?
> [!caution]
> **Le piège des Spurious Wakeups (Réveils intempestifs) :**  
> Sous Linux et dans la spécification POSIX, un thread endormi dans `pthread_cond_wait` peut être réveillé sans qu'aucun autre thread n'ait appelé `pthread_cond_signal` (dû à des signaux système ou des optimisations noyau).  
> De plus, si deux consommateurs sont réveillés en même temps, le premier peut consommer la seule donnée disponible, laissant le second sans rien.  
> **Patron impératif :**
> ```c
> pthread_mutex_lock(&mutex);
> while (!condition_satisfaite) { // TOUJOURS while, JAMAIS if !
>     pthread_cond_wait(&cond, &mutex);
> }
> // Traiter la donnée garantie disponible...
> pthread_mutex_unlock(&mutex);
> ```

#### 💻 Exemple canonique : Le Patron Producteur / Consommateur

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define BUFFER_SIZE 5
#define TOTAL_ITEMS 10

int buffer[BUFFER_SIZE];
int count = 0; // Nombre d'éléments actuellement dans le buffer

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond_non_plein = PTHREAD_COND_INITIALIZER;
pthread_cond_t cond_non_vide  = PTHREAD_COND_INITIALIZER;

void *producteur(void *arg) {
    (void)arg;
    for (int i = 1; i <= TOTAL_ITEMS; i++) {
        pthread_mutex_lock(&mutex);

        // Si le buffer est plein, attendre qu'il se vide
        while (count == BUFFER_SIZE) {
            pthread_cond_wait(&cond_non_plein, &mutex);
        }

        // Production de la donnée
        buffer[count] = i;
        count++;
        printf("📦 [Producteur] Produit : %d (Buffer : %d/%d)\n", 
               i, count, BUFFER_SIZE);

        // Signaler aux consommateurs qu'une donnée est disponible
        pthread_cond_signal(&cond_non_vide);

        pthread_mutex_unlock(&mutex);
        usleep(100000); // 100 ms
    }
    return NULL;
}

void *consommateur(void *arg) {
    (void)arg;
    for (int i = 1; i <= TOTAL_ITEMS; i++) {
        pthread_mutex_lock(&mutex);

        // Si le buffer est vide, attendre qu'une donnée soit produite
        while (count == 0) {
            pthread_cond_wait(&cond_non_vide, &mutex);
        }

        // Consommation de la donnée
        count--;
        int donnee = buffer[count];
        printf("🍽️  [Consommateur] Consommé : %d (Buffer restant : %d)\n", 
               donnee, count);

        // Signaler au producteur qu'une place s'est libérée
        pthread_cond_signal(&cond_non_plein);

        pthread_mutex_unlock(&mutex);
        usleep(150000); // 150 ms
    }
    return NULL;
}

int main(void) {
    pthread_t prod, cons;

    pthread_create(&prod, NULL, producteur, NULL);
    pthread_create(&cons, NULL, consommateur, NULL);

    pthread_join(prod, NULL);
    pthread_join(cons, NULL);

    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&cond_non_plein);
    pthread_cond_destroy(&cond_non_vide);

    printf("Fin du traitement Producteur/Consommateur.\n");
    return 0;
}
```

---

### 6. Les Sémaphores POSIX (`<semaphore.h>`)

#### 🔍 Définition formelle & Comparatif avec le Mutex
Un **sémaphore** est une variable entière non négative protégée par le noyau, munie de deux opérations atomiques fondamentales :
- **`wait` (P / `sem_wait`) :** Si le compteur $> 0$, il est décrémenté et le thread continue. Si le compteur $= 0$, le thread est suspendu jusqu'à ce que le compteur redevienne $> 0$.
- **`post` (V / `sem_post`) :** Incrémente le compteur et réveille un thread éventuellement en attente.

```c
#include <semaphore.h>

int sem_init(sem_t *sem, int pshared, unsigned int value);
int sem_wait(sem_t *sem);      // Bloquant (P)
int sem_trywait(sem_t *sem);   // Non-bloquant
int sem_post(sem_t *sem);      // Incrémente (V)
int sem_destroy(sem_t *sem);
```
- `pshared == 0` : Le sémaphore est partagé **uniquement entre les threads** du processus en cours.
- `pshared != 0` : Le sémaphore est logé en mémoire partagée inter-processus.

| Critère | Mutex (`pthread_mutex_t`) | Sémaphore (`sem_t`) |
| :--- | :--- | :--- |
| **Valeurs possibles** | Binaire uniquement ($0$ ou $1$, verrouillé ou déverrouillé) | Entier naturel ($0, 1, 2, \dots, N$) |
| **Notion de Propriétaire (*Ownership*)** | **OUI** : Seul le thread qui a verrouillé le mutex a le droit de le déverrouiller ! | **NON** : N'importe quel thread peut appeler `sem_post` pour incrémenter. |
| **Cas d'usage type** | Protection exclusive d'une ressource ou structure de données | Comptage de ressources limitées (ex: pool de 5 connexions max). |

---

### 7. Outils de Détection de Bugs de Concurrence

#### 🛠️ 1. ThreadSanitizer (TSan) avec GCC / Clang
L'outil le plus puissant pour débusquer les accès concurrents non synchronisés à la compilation :
```bash
gcc -Wall -Wextra -pthread -fsanitize=thread -g programme.c -o programme
./programme
```
- En cas de race condition, TSan affiche la pile d'appels exacte des deux threads en conflit avec le numéro de ligne précis de l'écriture et de la lecture fautives !

#### 🛠️ 2. Valgrind Helgrind & DRD
Permet d'analyser un binaire déjà compilé sans recompilation spécifique :
```bash
valgrind --tool=helgrind ./programme
# ou
valgrind --tool=drd ./programme
```
- Détecte les violations de verrouillage, les locks oubliés et les risques d'interblocages (*deadlock cycle detection*).

---

## ⚠️ Pièges Classiques & Ce qu'il faut retenir absolument

> [!important]
> **Le piège du passage d'adresse dans une boucle `for` :**  
> ```c
> // DANGER MORTEL :
> for (int i = 0; i < 4; i++) {
>     pthread_create(&tid[i], NULL, routine, &i); // FAUX ! TOUS les threads lisent la même case &i !
> }
> 
> // SOLUTION PROPRE 1 (Transtypage par valeur si intptr_t tient dans void*) :
> for (intptr_t i = 0; i < 4; i++) {
>     pthread_create(&tid[i], NULL, routine, (void *)i);
> }
> 
> // SOLUTION PROPRE 2 (Tableau de structures distinctes) :
> for (int i = 0; i < 4; i++) {
>     donnees[i].id = i;
>     pthread_create(&tid[i], NULL, routine, &donnees[i]);
> }
> ```

> [!warning]
> **Le retour d'un pointeur vers la pile locale (*Dangling Pointer*) :**  
> ```c
> void *routine(void *arg) {
>     int resultat = 42;
>     pthread_exit(&resultat); // ERREUR CRITIQUE !
>     // 'resultat' est sur la pile du thread, qui est invalidée dès la fin du thread !
> }
> ```
> **Solution :** Allouer le résultat sur le tas avec `malloc()`, le passer par la structure d'argument, ou retourner directement un entier transtypé `(void *)(intptr_t)42`.

> [!caution]
> **Ne jamais oublier l'option `-pthread` à la compilation :**  
> Compiler simplement avec `-lpthread` est insuffisant sur certains systèmes UNIX : l'option `-pthread` active à la fois le lieur (*linker*) ET les macros de préprocesseur indispensables (telles que `_REENTRANT`) qui transforment certaines variables globales comme `errno` en variables locales à chaque thread (*Thread-Local Storage* / TLS).

> [!warning]
> **Appeler `exit()` au lieu de `pthread_exit()` :**  
> `exit(code)` tue instantanément **l'intégralité du processus**, stoppant net tous les autres threads au milieu de leurs calculs ou avec des fichiers ouverts !  
> Si vous voulez uniquement mettre fin au thread courant, utilisez `pthread_exit(NULL)` ou un `return`.

---

## ❓ Questions de Révision & Cas Pratiques

1. **Quelle est la différence fondamentale de modèle mémoire entre un processus créé par `fork()` et un thread créé par `pthread_create()` ?**
   - Un processus fils possède une **copie isolée** de l'espace mémoire virtuel (gérée en *Copy-On-Write* par le noyau). Un thread partage **le même espace d'adressage virtuel** (tas, variables globales, descripteurs de fichiers) avec tous les autres threads du processus, à l'exception de sa propre **pile d'exécution (*stack*)** et de ses registres CPU.

2. **Pourquoi l'instruction en C `i++` n'est-elle pas thread-safe ?**
   - Parce qu'elle se décompose en 3 instructions machine distinctes : lecture de la variable en mémoire vers un registre (`LOAD`), incrémentation du registre (`ADD`), puis réécriture du registre en mémoire (`STORE`). Deux threads entrelacés peuvent lire la même valeur initiale et s'écraser mutuellement, perdant un incrément (*race condition*).

3. **Dans quel ordre `pthread_cond_wait(&cond, &mutex)` manipule-t-il le mutex associé ?**
   - Il libère le `mutex` de manière atomique au moment où le thread s'endort sur la variable de condition, puis il **ré-acquiert automatiquement le mutex** avant de rendre la main au réveil.

4. **Pourquoi doit-on obligatoirement encapsuler `pthread_cond_wait()` dans une boucle `while` plutôt qu'un test `if` ?**
   - Pour deux raisons impératives :
     1. Les **réveils intempestifs (*spurious wakeups*)** autorisés par la norme POSIX, où un thread peut être réveillé sans qu'un `signal` n'ait été émis.
     2. Si plusieurs threads sont réveillés (notamment via `broadcast`), un premier thread peut consommer la ressource avant le second. La boucle `while` force le second thread à revérifier la condition logique et à se rendormir si la ressource n'est plus disponible.

5. **Quelle est la différence entre un Mutex et un Sémaphore binaire (valeur initiale = 1) ?**
   - La notion de **propriétaire (*ownership*)** : un mutex ne peut être déverrouillé que par le thread précis qui l'a verrouillé. Un sémaphore n'a aucune notion de propriétaire : n'importe quel thread peut appeler `sem_post()` pour incrémenter le compteur.

6. **Que se passe-t-il si un thread oublie d'appeler `pthread_join()` sur un thread non détaché qui s'est terminé ?**
   - Les métadonnées du thread terminé (son code de retour et ses structures internes) restent stockées dans le système d'exploitation, créant une fuite de ressources similaire à un **processus zombie**. Pour éviter cela, tout thread doit soit faire l'objet d'un `pthread_join()`, soit être marqué détaché via `pthread_detach()`.

---
*Index général : [[Programmation/README]]* | *Processus & Fork : [[Processus-Fork-Systeme]]* | *Accueil : [[Bienvenue]]*

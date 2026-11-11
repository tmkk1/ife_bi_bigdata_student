**Référence du cours :** Business Intelligence et Analyse des Mégadonnées (`01 31 0367 00`)  
**Public cible :** Étudiants ingénieurs en 4e année B.Sc., Génie Industriel et Management de la Production (IFE, Université de Technologie de Łódź)  
**Séance pratique :** Laboratoire 01 (Fondements pratiques & Prise en main)  
**Enseignants :** Tomasz Kołodziejczyk

---

# **Python et l'Écosystème d'Outillage Moderne : Guide Pratique pour l'Ingénieur de Production**

Bienvenue dans la composante pratique de **Business Intelligence et Analyse des Mégadonnées**. S'il s'agit de votre tout premier contact avec la programmation en Python ou si vous n'avez manipulé jusqu'ici que des tableurs traditionnels comme Microsoft Excel, ne vous inquiétez pas. Ce cours n'a pas pour objectif de faire de vous des informaticiens théoriciens ou des développeurs de logiciels web. Vous aborderez Python comme un ingénieur industriel aborde un **centre d'usinage CNC de précision ou une machine à mesurer tridimensionnelle (MMT) laser** : comme un outil robuste, puissant et fiable, taillé pour résoudre des goulets d'étranglement opérationnels concrets, éradiquer les tâches manuelles répétitives et traiter des données de télémétrie à des échelles où les outils de bureautique classiques échouent.

Ce guide d'initiation vous présente les concepts clés de la syntaxe Python, explique pourquoi l'industrie manufacturière et l'ingénierie des données à l'échelle mondiale ont standardisé leurs pratiques autour de cet écosystème, et détaille les outils professionnels que vous utiliserez tout au long du semestre : **Visual Studio Code**, les **Environnements Virtuels Python (venv)** et les **Notebooks Jupyter**.

---

## **1. Pourquoi Python pour les Ingénieurs Industriels et de Production ?**

Dans les ateliers de fabrication et les centres logistiques traditionnels, le premier réflexe de l'ingénieur consiste souvent à ouvrir Microsoft Excel pour effectuer des calculs, recenser les pièces rebutées et générer des graphiques de tendance. Bien qu'Excel soit pratique pour des vérifications tabulaires ponctuelles, il montre des défaillances critiques dès qu'une entreprise change d'échelle :

> * **Plafond Strict du Nombre de Lignes :** Excel est physiquement incapable d'ouvrir un fichier dépassant **1 048 576 lignes**. Un compteur communicant d'énergie ou un capteur de presse industrielle enregistrant une mesure par seconde atteint cette limite en moins de deux semaines !  
> * **Auditabilité et Reproductibilité Fragiles :** Lorsqu'un utilisateur étire maladroitement une formule le long d'une colonne et écrase la cellule `C42` avec une valeur numérique saisie en dur, l'erreur demeure invisible jusqu'à ce qu'un tableau de bord de direction présente des données erronées. En code, chaque étape de transformation est explicite, tracée sous contrôle de version (Git) et testable unitairement.  
> * **Automatisation Multi-Sources :** Python constitue la véritable « colle numérique » de l'Industrie 4.0. Un script Python peut se connecter à une base de données de production en SQL, interroger une API externe JSON de tarification énergétique, normaliser les horodatages en UTC, filtrer le bruit des capteurs défaillants et injecter des indicateurs fiabilisés dans un tableau de bord décisionnel, sans aucune manipulation humaine.

### **Caractéristiques Fondamentales du Langage**

> * **Haut Niveau et Lisibilité Directe :** La syntaxe de Python a été conçue pour se rapprocher de la langue naturelle. Elle élimine les artefacts visuels parasites comme les points-virgules obligatoires en fin de ligne ou la gestion manuelle de la mémoire.  
> * **Interprété (Sans Étape de Compilation) :** À la différence du C++ ou du Java, un programme Python n'exige pas d'être compilé en binaire machine avant son exécution. Vous pouvez exécuter le code ligne par ligne, examiner l'état des variables en mémoire et déboguer vos calculs de manière interactive.  
> * **Typage Dynamique :** Vous n'avez pas besoin de déclarer explicitement si une variable est un entier, un flottant ou une chaîne de caractères lors de sa création. Python déduit automatiquement le type de donnée à l'exécution.  
> * **Écosystème Open-Source Exceptionnel :** La prépondérance de Python repose sur ses bibliothèques spécialisées : `pandas` pour la manipulation tabulaire de données, `numpy` pour le calcul numérique matriciel, `duckdb` pour les requêtes analytiques OLAP ultra-rapides, et `plotly` pour la visualisation interactive.

---

## **2. Syntaxe Essentielle et Modèles Mentaux**

### **2.1. La Règle d'Or : L'Indentation Significative**

Dans de nombreux langages de programmation, les blocs d'instructions sont délimités par des accolades `{ ... }`. En Python, **seule l'indentation (l'espacement en début de ligne) définit la hiérarchie et la portée des blocs**. La convention industrielle universelle impose **4 espaces** par niveau d'indentation (ne mélangez jamais tabulations et espaces) :

```python
# Exemple : L'indentation définit le flux de contrôle
statut_machine = "EN_FONCTIONNEMENT"
temperature_mesuree = 318.5  # en Kelvin

if temperature_mesuree > 315.0:
    print("Attention : Seuil thermique dépassé !")
    if statut_machine == "EN_FONCTIONNEMENT":
        print("Action requise : Enclencher la pompe de refroidissement d'urgence.")
else:
    print("Paramètres opérationnels nominaux.")
```

### **2.2. Les Types de Données Primitifs**

| Type | Nom | Exemples | Contexte Industriel |
| :--- | :--- | :--- | :--- |
| `int` | Entier (*Integer*) | `42`, `-10`, `0` | Décomptes discrets : pièces usinées, nombre de rebuts, numéro de poste. |
| `float` | Nombre à virgule flottante | `3.1415`, `-999.0`, `45.8` | Mesures physiques continues : couple (Nm), température (°C), puissance (kWh). |
| `str` | Chaîne de caractères (*String*) | `"PRESSE_01"`, `'Ligne_A'` | Identifiants, codes d'anomalie, désignations clients, horodatages bruts. |
| `bool` | Booléen (*Boolean*) | `True`, `False` | Drapeaux d'état : `est_en_panne`, `qualite_validee`, `heure_pleine`. |
| `NoneType` | Nul / Absent (*None*) | `None` | Données manquantes, perte de signal d'un capteur, champs non renseignés. |

### **2.3. Structures de Données Fondamentales (Collections)**

Lors du traitement de données industrielles, les grandeurs scalaires sont regroupées en collections. Les deux structures prépondérantes sont les **Listes** et les **Dictionnaires** :

```python
# 1. LISTES : Collections ordonnées et modifiables d'éléments (indexées à partir de 0)
presses_emboutissage = ["PRESSE_01", "PRESSE_02", "PRESSE_03"]
presses_emboutissage.append("PRESSE_04")
print("Première machine de la ligne :", presses_emboutissage[0])  # Résultat : PRESSE_01

# 2. DICTIONNAIRES : Associations clés-valeurs non ordonnées (le modèle mental du format JSON)
telemesure_machine = {
    "id_machine": "PRESSE_01",
    "temps_cycle_nominal_sec": 12.0,
    "cout_horaire_eur": 180.0,
    "est_operationnelle": True
}
print(f"Coût horaire machine : {telemesure_machine['cout_horaire_eur']} EUR/h")
```

### **2.4. Fonctions : Encapsulation de la Logique d'Ingénierie**

Les fonctions isolent les calculs répétitifs afin d'appliquer une règle métier rigoureuse et uniforme sur des milliers d'enregistrements :

```python
def calculer_taux_rebut(pieces_produites: int, pieces_rebutees: int) -> float:
    """Calcule le pourcentage d'unités défectueuses d'un lot de production."""
    if pieces_produites <= 0:
        return 0.0
    return round((pieces_rebutees / pieces_produites) * 100.0, 2)

rebut_lot = calculer_taux_rebut(pieces_produites=1500, pieces_rebutees=45)
print(f"Taux de rebut du lot : {rebut_lot}%")  # Résultat : 3.0%
```

---

## **3. L'Environnement de Développement Professionnel : Visual Studio Code**

**Visual Studio Code (VS Code)** est l'éditeur de code source de référence de l'industrie, conçu par Microsoft. Gratuit, performant et open-source, il offre une expérience rigoureusement identique sous Windows, macOS et Linux. Contrairement aux environnements de développement intégrés (IDE) lourds et monolithiques, VS Code est modulaire et s'enrichit grâce à son écosystème d'**Extensions**.

### **Composants Clés de l'Interface VS Code**

> 1. **Barre d'Activité (Activity Bar, à l'extrême gauche) :** Permet de basculer instantanément entre l'Explorateur de fichiers, la Recherche globale, le Gestionnaire de versions (Git), l'Exécution/Débogage et le Marketplace d'extensions.  
> 2. **Barre Latérale (Sidebar / Explorer) :** Présente l'arborescence des répertoires, dossiers de données, scripts et notebooks de votre espace de travail.  
> 3. **Zone Centrale d'Édition :** Espace où vous visualisez et modifiez vos scripts Python (`.py`) et vos Notebooks Jupyter (`.ipynb`).  
> 4. **Terminal Intégré (En bas, `Ctrl + \`` ou `Cmd + \``) :** Ligne de commande intégrée (PowerShell, Bash ou Zsh) permettant de lancer vos scripts, manipuler l'environnement virtuel et installer des paquets sans quitter votre fenêtre.  
> 5. **Palette de Commandes (Command Palette, `Ctrl + Shift + P` ou `Cmd + Shift + P`) :** Le centre nerveux de VS Code. Pour tout paramètre ou commande dont vous avez oublié le raccourci, ouvrez la palette et saisissez quelques lettres.

### **Extensions Recommandées pour ce Cours**

> * **Python (Microsoft) :** Complétion intelligente du code (*IntelliSense*), coloration syntaxique, détection d'erreurs (*linting*) et débogueur interactif.  
> * **Jupyter (Microsoft) :** Lecture, édition et exécution interactive des notebooks directement au sein de VS Code, sans ouvrir de navigateur externe.  
> * **DuckDB SQL Tools (ou SQLTools) :** Visualisation des schémas, exploration et exécution directe de requêtes SQL sur vos entrepôts de données `.duckdb`.  
> * **DBML (Database Markup Language) :** Coloration syntaxique pour les fichiers `.dbml` lors de la modélisation dimensionnelle de vos schémas en étoile.

---

## **4. Isolation des Dépendances : Environnements Virtuels Python (`venv`)**

### **4.1. Pourquoi Recourir aux Environnements Virtuels ?**

Lorsqu'on installe Python sur un système d'exploitation, le programme dispose d'un répertoire global partagé nommé `site-packages`. Si vous exécutez simplement `pip install pandas` dans votre terminal global, la bibliothèque s'installe pour l'ensemble du système d'exploitation.  
Cette pratique mène directement à l'impasse classique nommée en industrie **« l'Enfer des Dépendances » (*Dependency Hell*)** :

> * Imaginons qu'un projet universitaire antérieur nécessite une version spécifique de bibliothèque (ex. `pandas==1.3.0`), alors que notre cours de Business Intelligence exploite des fonctions modernes de `pandas==2.2.0`. Installer l'une écrasera l'autre et rendra votre ancien projet immédiatement inopérant.  
> * Sur les postes informatiques de l'université, les stratégies de sécurité restreignent fréquemment les droits d'écriture sur le disque système (`C:\`), bloquant toute modification globale par un utilisateur standard.

Un **Environnement Virtuel** est une arborescence dédiée et étanche contenant un interpréteur Python isolé et son propre catalogue de bibliothèques. Chaque projet dispose de son bac à sable privé. Si vous effacez le dossier du projet, l'environnement disparaît proprement sans impacter le système d'exploitation.

### **4.2. Procédure Pas-à-Pas dans le Terminal**

Exécutez cette séquence exacte de commandes dans la console de votre dossier de travail :

```bash
# ÉTAPE 1 : Ouvrir le terminal de VS Code et contrôler la version de Python
python --version   # Doit indiquer Python 3.10, 3.11, 3.12 ou supérieur

# ÉTAPE 2 : Créer un environnement virtuel nommé '.venv' dans le dossier du projet
python -m venv .venv

# ÉTAPE 3 : Activer l'environnement virtuel
# Sous Windows (PowerShell) :
.venv\Scripts\Activate.ps1
# (Remarque : Si PowerShell restreint les scripts, exécuter : Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass)

# Sous macOS / Linux :
source .venv/bin/activate

# ÉTAPE 4 : Vérifier l'activation
# L'invite de votre invite de commande doit afficher '(.venv)' tout à gauche !

# ÉTAPE 5 : Mettre à jour l'installateur de paquets et installer les dépendances du cours
python -m pip install --upgrade pip
pip install pandas numpy openpyxl duckdb pyarrow plotly jupyter

# ÉTAPE 6 : Désactivation (à la fin de votre session de travail)
deactivate
```

---

## **5. Informatique Interactive : Notebooks Jupyter (`.ipynb`)**

### **5.1. Qu'est-ce qu'un Notebook ?**

En génie logiciel traditionnel, les programmes s'écrivent dans des fichiers de code statiques (ex. `script.py`) exécutés intégralement d'une traite. En analyse décisionnelle et mégadonnées, ce flux linéaire s'avère pénalisant : charger un fichier de télémesure de 1 Go peut réclamer 15 secondes. S'il faut recharger l'intégralité du fichier à chaque ajustement typographique d'un graphique, l'analyste perd un temps précieux.  
Un **Notebook Jupyter** incarne la **Programmation Lettrée (*Literate Programming*)** : un document dynamique associant des blocs de code exécutables, des explications rédigées en Markdown, des formules mathématiques et des visualisations interactives dans une interface unique et auditable.

### **5.2. Anatomie d'un Notebook : Code vs Markdown**

> * **Cellules de Code :** Contiennent le code Python à exécuter. Lorsque vous lancez une cellule, le moteur d'exécution (le **Noyau / Kernel**) traite les instructions, actualise la mémoire et affiche les tableaux ou graphiques immédiatement en dessous.  
> * **Cellules Markdown :** Contiennent les commentaires textuels, la formalisation des hypothèses industrielles et les équations (ex. formules LaTeX telles que $OEE = A \times P \times Q$). Dans ce cours, consigner rigoureusement vos hypothèses métier en Markdown est aussi déterminant que l'écriture du code lui-même.

### **5.3. Le Piège de l'Exécution Désordonnée (*Out-of-Order Execution*)**

Comme un notebook vous autorise à cliquer sur n'importe quelle cellule pour la réexécuter de façon autonome, les débutants tombent couramment dans le **piège de l'exécution désordonnée** :

> 1. Vous fixez `objectif_trs = 0.85` dans la Cellule [1].  
> 2. Vous le modifiez en `objectif_trs = 0.90` dans la Cellule [4] et exécutez la Cellule [4].  
> 3. Vous remontez exécuter la Cellule [2] en pensant qu'elle prendra 0.85, mais la mémoire de l'interpréteur a conservé la valeur 0.90 imposée par la Cellule [4] !

**La Règle d'Or du Notebook :** Avant de soumettre un livrable ou de soutenir vos résultats devant l'enseignant, cliquez systématiquement sur **« Restart Kernel and Run All Cells »** (icône double flèche ⏩ dans la barre d'outils). Votre travail doit s'exécuter de la première à la dernière cellule sans la moindre erreur sur un état mémoire vierge.

### **5.4. Raccourcis Clavier Indispensables**

| Raccourci | Action | Précision d'Usage |
| :--- | :--- | :--- |
| **Shift + Entrée** | Exécuter la cellule active | Lance la cellule sélectionnée et positionne le curseur sur la suivante. |
| **Ctrl + Entrée** (`Cmd + Entrée`) | Exécuter sur place | Lance la cellule sans déplacer le curseur. |
| **Échap (Escape)** | Mode Commande | Sort du mode édition textuelle pour parcourir les cellules avec les flèches. |
| **A** (en Mode Commande) | Insérer au-dessus (*Above*) | Crée une nouvelle cellule vierge au-dessus de la sélection. |
| **B** (en Mode Commande) | Insérer en-dessous (*Below*) | Crée une nouvelle cellule vierge en-dessous de la sélection. |
| **D + D** (appuyer 2x sur D) | Supprimer la cellule | Élimine la cellule active du notebook. |
| **M** / **Y** | Changer le type de cellule | Tapez `M` pour convertir en Markdown ; tapez `Y` pour convertir en Code Python. |

---

## **6. Liste de Contrôle Pratique pour le Laboratoire 01 (Les 20 Premières Minutes)**

Dès votre installation au poste de travail lors de la Séance 1, appliquez scrupuleusement la séquence d'initialisation suivante avant d'ouvrir les fichiers de données de votre étude de cas :

> 1. **Démarrer VS Code :** Ouvrez Visual Studio Code depuis le menu système de votre poste.  
> 2. **Ouvrir le Répertoire du Projet :** Faites `Fichier` → `Ouvrir le dossier...` et sélectionnez le dossier racine attribué à votre équipe. Ne travaillez jamais dans des répertoires temporaires ou des archives ZIP compressées !  
> 3. **Ouvrir le Terminal Intégré :** Pressez `Ctrl + \`` (accent grave) ou cliquez sur `Terminal` → `Nouveau terminal`.  
> 4. **Créer l'Environnement Virtuel :** Saisissez `python -m venv .venv` et patientez jusqu'à l'apparition du dossier `.venv` dans l'Explorateur.  
> 5. **Activer l'Environnement :** Lancez `.venv\Scripts\activate` (Windows) ou `source .venv/bin/activate` (macOS/Linux). Validez la présence du préfixe `(.venv)` sur votre ligne de commande.  
> 6. **Installer les Paquets Fondamentaux :** Lancez `pip install pandas numpy openpyxl duckdb pyarrow plotly jupyter`.  
> 7. **Sélectionner le Noyau Jupyter :** Ouvrez le cahier d'échauffement (`lab_01_python_and_tooling_primer_workbook_fr.ipynb`). Dans le coin supérieur droit de l'éditeur, cliquez sur **« Select Kernel »** → **« Python Environments... »** → choisissez **Python (.venv)**.  
> 8. **Finaliser l'Échauffement :** Complétez les défis pratiques du cahier d'exercices pour valider l'indentation, les types de données, les dictionnaires et les fonctions, puis vérifiez **« Restart Kernel and Run All Cells »**. Une fois ces acquis validés, vous pourrez ouvrir `../lab_02_bronze_ingestion_and_profiling/lab_02_bronze_ingestion_and_exploration_fr.ipynb` lors du Laboratoire 02 pour débuter l'ingestion de vos jeux de données industriels !


# Facteurs associés au décès chez les patients admis en soins intensifs

## Aperçu du projet

Ce projet présente une analyse statistique réalisée sous R visant à identifier les facteurs associés au décès chez les patients admis en unité de soins intensifs (ICU).

L’étude repose sur un modèle de régression logistique binaire permettant d’estimer l’association entre plusieurs caractéristiques sociodémographiques, cliniques et physiologiques et la probabilité de décès hospitalier.

Le projet a été réalisé dans le cadre d’un exercice de modélisation statistique appliquée aux données de santé.

---

## Objectif de l’étude

L’objectif principal est d’identifier les déterminants du décès chez les patients admis en soins intensifs à partir :

- des caractéristiques démographiques ;
- des paramètres physiologiques à l’admission ;
- des variables cliniques et biologiques.

Les associations ont été quantifiées à l’aide des Odds Ratios (OR) et de leurs intervalles de confiance à 95 %.

---

## Méthodologie

### Étapes de l’analyse

1. Importation et nettoyage des données
2. Analyse descriptive
3. Analyse univariée
4. Sélection des variables candidates (p ≤ 0,25)
5. Construction d’un modèle de régression logistique multivariée
6. Sélection automatique des variables par procédure stepwise
7. Évaluation des performances du modèle :
   - AIC
   - Déviance
   - Courbe ROC
   - AUC
   - Matrice de confusion

---

## Variables étudiées

Le jeu de données comporte :

- 13 variables
- 7 variables quantitatives
- 6 variables qualitatives

### Variable dépendante

- `DECEDE` : décès du patient (oui/non)

### Variables explicatives candidates

- Âge
- Sexe
- Type d’admission
- Chirurgie
- Infection à l’admission
- Tension artérielle systolique
- pH
- État de conscience
- Score de Glasgow
- Paramètres biologiques

---

## Principaux résultats

Le modèle final obtenu après sélection stepwise a identifié plusieurs facteurs significativement associés au décès :

### Facteurs associés à une augmentation du risque de décès

- Âge avancé
- Admission en urgence
- Altération de l’état de conscience

### Performances du modèle

- AUC = 0.842
- Forte réduction de la déviance
- Bon pouvoir discriminant du modèle

Le modèle identifie correctement la majorité des survivants mais présente une sensibilité plus limitée pour détecter tous les décès.

---

## Technologies et packages utilisés

### Langage

- R

### Packages principaux

- `gtsummary`
- `summarytools`
- `ggplot2`
- `GGally`
- `pROC`
- `ROCR`

---

## Structure du projet

```text
.
├── docs/
│   └── index.html
├── ICU.csv
├── ICU_reg_logistique.R
├── regression_logistique.Rproj
├── .gitignore
└── README.md
# Regression Logistique ----
# Chargement des packages ----
install.packages("ROCR")
library(ROCR)
install.packages("summarytools") #view(dfSummary(data))
library(summarytools)
install.packages("gtsummary") # tbl_summary(data)
library(gtsummary)
library(ggplot2)
library(GGally)

# Importation des données et passage en facteurs ----
ICU <- read.csv2("C:/Users/admin/Downloads/M1_DSS/BCC3/UE2_Statistiques_données_massives_de_santé/Modelisation_statistique_1/Dossier régression logistique (ICU)-20251017/ICU.csv", stringsAsFactors=TRUE)

# Première étape : stats descriptives ----
summary(ICU)
tbl_summary(ICU)
view(dfSummary(ICU))

#Correction valeur aberrante "10" au niveau de la variable chirugie 
ICU$CHIR_MED[143]=1

#croissement de la variable dépendante avec chaque vaiable dépendant 
tbl_summary(ICU, by = DECEDE) %>%
  add_p()

tab1 = tbl_summary(ICU, by = DECEDE) %>%
  add_p(test = list(
    all_continuous() ~ "t.test",
    all_categorical() ~ "fisher.test"
  ))

vars_sel = tab1$table_body |>
  dplyr::filter(!is.na(p.value)) |>
  dplyr::filter(p.value <= 0.25) |>
  dplyr::pull(variable) |>
  unique()

form <- as.formula(
  paste("DECEDE ~", paste(vars_sel, collapse = " + ")))

fit <- glm(form, data = ICU, family = binomial)

install.packages("broom.helpers")

tbl_regression(fit, exponentiate = TRUE)

# Sélection des variables ----
fit1 <- step(fit)
summary(fit1)

# ================================
# 1. Interpréter les OR
# ================================
library(gtsummary)
tbl_regression(fit1, exponentiate = TRUE)

# ================================
# 2. Tester les variables
#    - Wald : déjà dans summary()
#    - Rapport de vraisemblance (LR test)
# ================================
summary(fit1)  # Wald

anova(fit1, test = "Chisq")  # LR test


# ================================
# 3. Évaluer le modèle
#    - AIC
#    - Déviance
# ================================
AIC(fit1)
fit1$deviance
fit1$null.deviance


# ================================
# 4. ROC + AUC
# ================================
library(pROC)

prob <- fitted(fit1)
roc_obj <- roc(ICU$DECEDE, prob)

auc(roc_obj)
plot(roc_obj, col = "blue", lwd = 2)


# ================================
# 5. Matrice de confusion
# ================================
pred_class <- ifelse(prob > 0.5, 1, 0)

table(Prediction = pred_class, Observed = ICU$DECEDE)


# ================================
# 6. Interprétation scientifique finale
# (pas de code : à rédiger dans le rapport)
# ================================

"AGE
Coefficient positif et très significatif (p < 0.001).

Chaque année supplémentaire augmente les odds de décès d’environ 3,6 % (OR ≈ exp(0.035) ≈ 1.036). ➡️ L’âge est un facteur de risque important et robuste.

TA_SYS (tension artérielle systolique)
Coefficient négatif, borderline (p ≈ 0.08).

OR ≈ exp(-0.0093) ≈ 0.99. ➡️ Une tension plus basse tend à augmenter le risque de décès, mais l’effet reste modéré et incertain.

URG_NURG (admission en urgence vs non-urgence)
Très significatif (p = 0.001).

OR ≈ exp(1.846) ≈ 6.33. ➡️ Les patients admis en urgence ont un risque de décès environ 6 fois plus élevé. C’est un des facteurs les plus marquants du modèle.

PH
Coefficient négatif, borderline (p ≈ 0.06).

OR ≈ exp(-3.82) ≈ 0.022. ➡️ Un pH bas (acidose) est associé à un risque fortement accru de décès, même si la significativité statistique est limite. L’effet est biologiquement cohérent.

CONSC (état de conscience altéré)
Très significatif (p < 0.0001).

OR ≈ exp(1.54) ≈ 4.66. ➡️ Une altération de la conscience multiplie par environ 4,7 les odds de décès. C’est un facteur majeur du modèle."




"Les tests de Wald confirment la significativité de AGE, URG_NURG et CONSC, et montrent des effets borderline pour TA_SYS et PH.

Le test du rapport de vraisemblance (LR) confirme également l’importance de AGE, TA_SYS, URG_NURG et CONSC.

PH n’est pas significatif au LR test (p = 0.17), mais son effet reste cohérent et pertinent cliniquement."


"Null deviance : 296.38

Residual deviance : 217.06 → Forte réduction de la déviance → le modèle explique bien la variabilité du décès.

AIC = 229.06 → C’est le plus faible obtenu durant la procédure stepwise → modèle optimal selon AIC."


"AUC = 0.842 → Très bonne capacité discriminante. → Le modèle distingue bien les survivants des décédés."



"Sensibilité (détection des décès) = 28 / (28 + 40) ≈ 41 %

Spécificité = 181 / (181 + 7) ≈ 96 %

➡️ Le modèle identifie très bien les survivants, mais manque de sensibilité pour détecter tous les décès (classique avec un seuil 0.5)."



"Le modèle logistique final met en évidence plusieurs facteurs significativement associés au risque de décès en soins intensifs. L’âge, l’admission en urgence et l’altération de la conscience sont des déterminants majeurs, avec des odds-ratios élevés et des p-values très significatives. Le pH et la tension systolique montrent des effets cohérents sur le plan physiopathologique, bien que leur significativité statistique soit borderline.

Le modèle présente une bonne qualité d’ajustement (réduction importante de la déviance, AIC optimal) et une excellente capacité discriminante (AUC = 0.842). La matrice de confusion montre une très bonne spécificité mais une sensibilité perfectible, suggérant qu’un ajustement du seuil de classification pourrait être envisagé selon l’objectif clinique."
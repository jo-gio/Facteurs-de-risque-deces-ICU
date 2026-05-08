# Regression Logistique ----
# Chargement des packages ----
install.packages("ROCR")
library(ROCR)
#install.packages("summarytools") #view(dfSummary(data))
library(summarytools)
#install.packages("gtsummary") # tbl_summary(data)
library(gtsummary)
library(ggplot2)
library(GGally)


# Importation des données et passage en facteurs ----
# prema <- read.table(file = "prema.txt", header = TRUE)
# prema$CONSIS = factor(prema$CONSIS, label = c("mou","moyen","ferme")) # on va modifier avec les bonnes valeurs
# prema$CONTR = factor(prema$CONTR, label = c("oui","non")) # par ex ici petite erreur
# table(prema$CONTR)


# ..... étape à terminer mais ici on va utiliser le tableau déjà nettoyé
load("prema.RData")


# Première étape : stats descriptives ----
summary(prema)
tbl_summary(prema)
view(dfSummary(prema)) # on regarde si pas de valeurs manquantes, est-ce qu'on prend la variable telle quelle ou est-ce qu'on regroupe


# Quanti/quali -> test de Student pour comparer par ex: l'âge et oui/non prématuré : boite à moustache ----
boxplot(prema$AGE ~ prema$PREMATURE)
t.test(prema$AGE ~ prema$PREMATURE)
wilcox.test(prema$AGE ~ prema$PREMATURE)

ggplot(prema, aes(x = AGE, fill = PREMATURE)) + geom_density(alpha = 0.4)
plot(prema$PREMATURE, prema$DIAB)
chisq.test(prema$PREMATURE, prema$DIAB)$expected

# Quali/quali -> chi-2 : histogramme ----

# On fait un tableau qui fait toutes les comparaisons vs OUI/NON prématuré ----
tbl_summary(prema, by = PREMATURE) %>%
  add_p()

# on peut prendre un p-value plus grande lors de la phase exploratoire

# Estimation de coefficients de régression logistique ----
model1 <- glm(PREMATURE ~ ., family = "binomial", data = prema)
summary(model1)

# Sélection des variables ----
model2 <- step(model1)
summary(model2)



# Quantification des effets ----
tbl_regression(model2, exponentiate = TRUE) # attention à l'interprétation , 95% Ci= intervalle de confiance, peut être très grand
plot(prema$PREMATURE, prema$GEMEL)
ggcoef_model(model2, exponentiate = T)

ggcoef_compare(list("modèle complet" = model1, "modèle réduit" = model2),
               exponentiate = T)

# Prédictions ----
xbeta = 6.553388 - 0.105517 * 31 + 0.492030 * 3 + 0.016205 * 100 - 2.398824 +
  0.232827 * 1 - 1.424097 - 0.535413
xbeta
exp(xbeta) / (1 + exp(xbeta)) # donc pour cette femme-là, proba naissance prématurée = 90%

prema$pi_hat = predict(model2, prema, type = "response")
pi_hat

boxplot(pi_hat ~ prema$PREMATURE)
ggplot(prema, aes(x = pi_hat, fill = PREMATURE)) + geom_density(alpha = 0.5) #aire sous la courbe, attention faux-pos et faux-neg

y_hat = as.factor(ifelse(pi_hat > 0.5, "predit pos", "predit neg"))
y_hat
MatConf = table(prema$PREMATURE, y_hat)
MatConf
taux = prop.table(MatConf, margin = 1)

# va falloir trouver un seuil de décision


# Adéquation du modèle ----

sum(is.na(pi_hat))

# NECESSITE LE PACKAGE ROCR !
#predictions de la classe d'affectation pour differents seuils
pred = prediction(pi_hat[!is.na(prema$DIAB)], prema$PREMATURE[!is.na(prema$DIAB)])
#calcul des coordonnees de la courbe ROC
perf2 = performance(pred, "tpr", "fpr")
#trace courbe ROC
plot(perf2)
#Aire sous la courbe
perf = performance(pred, "auc")


residuals(model2)
plot(residuals(model2))
res = residuals(model2)
names(res)

prema[abs(res)>2, ] #ça devrait m'afficher le pi_hat

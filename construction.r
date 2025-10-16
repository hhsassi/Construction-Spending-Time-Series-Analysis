# Installer les packages nécessaires
install.packages(c("readxl", "forecast", "tseries", "ggplot2"))

library(readxl)
library(tseries)
library(ggplot2)
library(forecast)

# Importer les fichiers Excel
construction <- read_excel("C:/Users/Hassen/Desktop/construction spending S C3.xlsx")
View(construction)


#Nettoyage Du Dataset
# Supprimer les 6 premières lignes
construction <- construction[-c(1:6), ]
# 2. Réinitialiser les noms de colonnes à partir de la première ligne restante
colnames(construction) <- as.character(unlist(construction[1, ]))
construction <- construction[-c(1), ]

# 3. Supprimer la première colonne maintenant qu'elle est utilisée comme en-têtes
construction <- construction[, -3]

# supprimer la 1 ere colonne :
construction <- construction[, -1]
#Verifier le type de la colonne
typeof(construction$Value)
# Transformer en numeric
construction$Value <- as.numeric(construction$Value)


#Création de la série temporelle
CONS.ts=ts(construction$Value,start=c(2002,1),freq=12)

# représentation et interprétation des séries
plot(CONS.ts)
#Interpreter visu serie

#decomposition de la serie 
decomp_const <- decompose(CONS.ts)

plot(decomp_const)

#Ajustement de la tendance 

# 1. Extraire les temps et les valeurs numériques
temps <- as.numeric(time(CONS.ts))
valeurs <- as.numeric(CONS.ts)
#-----correction------#
L=length(CONS.ts)
# creation de la variable temps
t=1:L
#-----correction------#

# 3. Régression linéaire sur le temps
M1 <- lm(CONS.ts ~ t)
summary(M1)
# 4. Plot standard avec plot.default
plot.default(temps, valeurs, type = "l", col = "blue", 
             main = "Série + Ajustement linéaire", 
             xlab = "Temps", ylab = "Production")

# 5. Ajouter la droite de régression
lines(temps, fitted(M1), col = "red", lwd = 2)

# 6. Légende
legend("topleft", legend = c("Série", "Régression linéaire"), 
       col = c("blue", "red"), lty = 1, lwd = 2)

# Interpretation :


# Ajustement quadratique:
# X_t=a+b*t+c*t^2+e_t
# 1. Vecteur temps (numérique)
temps <- as.numeric(time(CONS.ts))
valeurs <- as.numeric(CONS.ts)

# 2. Temps au carré
t2 <- t^2

# 3. Ajustement quadratique
M2 <- lm(CONS.ts ~ t + t2)
summary(M2)
# 4. Tracer la série originale
plot.default(temps, valeurs, type = "l", col = "blue", 
             main = "Série + Ajustement quadratique", 
             xlab = "Temps", ylab = "Production")

# 5. Ajouter la courbe ajustée (quadratique)
lines(temps, fitted(M2), col = "darkgreen", lwd = 2)

# 6. Ajouter une légende
legend("topleft", legend = c("Série", "Régression quadratique"), 
       col = c("blue", "darkgreen"), lty = 1, lwd = 2)
#----------------------ordre3-----------------------#
# 2. Temps au carré
t3 <- t^3

# 3. Ajustement quadratique
M3 <- lm(CONS.ts ~ t + t2+t3)
summary(M3)
#----------------------ordre4-----------------------#
# 2. Temps au carré
t4 <- t^4

# 3. Ajustement quadratique
M4 <- lm(CONS.ts ~ t + t2+t3+t4)
summary(M4)
#---------------------ordre5------------------------#
# 2. Temps au carré
t5 <- t^5

# 3. Ajustement quadratique
M5<- lm(CONS.ts ~ t + t2+t3+t4+t5)
summary(M5)
#----------------------ordre3-----------------------#
plot(t, CONS.ts, type = "l", col = "black", lwd = 2,
     main = "Ajustement de la Tendance",
     ylab = "Valeurs", xlab = "Temps")

lines(t, fitted(M5), col = "blue", lwd = 2)

legend("topleft", legend = c("Série Observée", "Ajustement Modèle"),
       col = c("black", "blue"), lty = 1, lwd = 2)

#Interpretation :


# Comparaison des deux modeles :
# En conclusion, le modèle quadratique est préférable pour modéliser la tendance de la série. Il permet une 
#représentation plus fidèle de l’évolution de la production alimentaire dans le temps, notamment grâce à sa 
#capacité à représenter des courbures dans la tendance, ce que le modèle linéaire ne peut pas faire.

# Ajustement de la saisonnalité 

# combinaison cos et sin
# S_t=Sum_{i=1}^6 alpha_i*sin(2*pi*i*t/12)
# +Sum_{i=1}^6 beta_i*cos(2*pi*i*t/12)
# Création des matrices
L
t
Mcos=matrix(0,L,6)
Msin=matrix(0,L,6)
for (i in 1:6){
  Mcos[,i]=cos(2*pi*i*t/12)
  Msin[,i]=sin(2*pi*i*t/12)
}
# Créer un data.frame complet pour le modèle
# Modèle avec polynôme d'ordre 5 + composantes saisonnières
MLS <- lm(CONS.ts ~ t + I(t^2) + I(t^3) + I(t^4) + I(t^5) + Mcos + Msin)

summary(MLS)

# Résumé du modèle
#summary(MLS)
#MLS=lm(CONS.ts~t+I(t^5)+Mcos+Msin)
#summary(MLS)

#amélioration du modèle
# supp des variables non significatives
# Msin6( pvalue=0.54>0.3)
MLS1 <- lm(CONS.ts ~ t + I(t^2) + I(t^3) + I(t^4) + I(t^5) + Mcos[,c(1,2)] + Msin[,c(1,2,3,5)])
summary(MLS1)
AIC(MLS)
AIC(MLS1)
#----------------------------------------------- visualisation ------------------------------------------------------------#
plot(t, CONS.ts, type = "l", col = "black", lwd = 2,
     main = "Ajustement de la Tendance et Saisonnalité",
     ylab = "Valeurs", xlab = "Temps")

lines(t, fitted(MLS1), col = "blue", lwd = 2)

legend("topleft", legend = c("Série Observée", "Ajustement Modèle"),
       col = c("black", "blue"), lty = 1, lwd = 2)
#----------------------------------------------- visualisation ------------------------------------------------------------#




# Ajustement de la composante saisonnière
# par seasonal dummy
install.packages("forecast")
library(forecast)
MLS3=lm(CONS.ts~ t + I(t^2) + I(t^3) + I(t^4) + I(t^5)+seasonaldummy(CONS.ts))
summary(MLS3)

AIC(MLS)
AIC(MLS1)
AIC(MLS3)

#ajustement du changement structurel 
install.packages("strucchange")
library(strucchange)
  CONS.pt_repture=breakpoints(CONS.ts~t)
CONS.pt_repture
#points de rupture apres reduction d'echelle 
CONS.pt_repture_log=breakpoints(log(CONS.ts)~t)
CONS.pt_repture_log

index <- 1:length(CONS.ts)

# Segmentation manuelle basée sur :
# - visuel : position 1 à ~35 (≈1975)
# - breakpoints : 323 (1998) et 431 (2007)

# Nouvelle segmentation basée sur les ruptures détectées automatiquement
part0 <- ifelse(index <= 41, 1, 0)                # Segment 1 : avant 2005
part1 <- ifelse(index > 41 & index <= 96, 1, 0)   # Segment 2 : 2005 à 2009
part2 <- ifelse(index > 96 & index <= 223, 1, 0)  # Segment 3 : 2009 à 2020
part3 <- ifelse(index > 223, 1, 0)                # Segment 4 : après 2020


M2Final=lm(log(CONS.ts)~part0*t+part1*t+part2*t+part3*t)
summary(M2Final)
#96% est expliquee

# Série ajustée
M2Final.ts <- ts(fitted(M2Final), start = c(2002, 1), frequency = 12)

# Tracer la série
plot(log(CONS.ts), main = "Modèle avec 3 ruptures (visuelle + automatiques)", col = "black")
lines(M2Final.ts, col = "red", lwd = 2)

#ajout de la composante saisonniere
M_final_season <- lm(log(CONS.ts) ~ part0*t + part1*t + part2*t + part3*t + seasonaldummy(log(CONS.ts)))
summary(M_final_season)

#explique 98%

M_final_season.ts <- ts(fitted(M_final_season), start = c(2002, 1), frequency = 12)
plot(log(CONS.ts), main = "Modèle final : ruptures + saisonnalité", col = "black")
lines(M_final_season.ts, col = "red", lwd = 2)




#test de stationnarite 
#H0 : la serie est non stationnaire
#H1 : la serie est stationnaire 
#donc :
#p-value > 0.05 : on accepte H0 : la serie est non stationnaire
#p-value < 0.05 : on rejete H0 : la serie est stationnaire
#Comment rendre une serie est stationnaire ?
## methode 1 : differenciation 
# realiser la differenciation avec le log et on verifie une autre fois si la serie devient stationnaire 
# il faut memoriser le nombre de differenciation pour l'integrer dans le modele arima
#Application :
#test de stationnarit� :Dickey-Fuller
library(tseries)
adf.test(CONS.ts)
#p-value = p-value = 0.4012 > 0.05 : on accepte H0 la serie non stationnaire

#stationnarisation : differenciation 
CONS1.ts=diff(CONS.ts)
plot(CONS1.ts)

#pour verifier si la serie differenci� est stationnaire ou non on va tester une autre fois 
adf.test(CONS1.ts)
# p-value = 0.01 < 0.05 : on rejette H0 : la serie est stationnaire 
# la serie devient stationnaire avec une seule differenciation donc l'ordre de differenciation = 1


#choix du modele avec acf et pacf
acf(CONS1.ts, main = "ACF de la série différenciée")
pacf(CONS1.ts, main = "PACF de la série différenciée")
#application du modele ARMA
mod_arma <- Arima(CONS1.ts, order = c(1, 0, 1))  # ARMA(1,1), donc d = 0
summary(mod_arma)

# Afficher les résidus
checkresiduals(mod_arma)

#Modele ARIMA
mod_arima <- Arima(CONS.ts, order = c(1, 1, 1))  # ARIMA(1,1,1), donc d = 1
summary(mod_arima)

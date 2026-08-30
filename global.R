####################################################################
# GLOBAL.R
# Chargement des packages, des donnees et entrainement du modele.
# Ce fichier est source automatiquement par Shiny avant ui.R et server.R
# et son contenu est partage par toutes les pages de l'application.
####################################################################

packages <- c("shiny", "shinydashboard", "randomForest", "dplyr", "shinyjs")

installed <- rownames(installed.packages())
for (p in packages) {
  if (!(p %in% installed)) install.packages(p, dependencies = TRUE)
}

library(shiny)
library(shinydashboard)
library(randomForest)
library(dplyr)
library(shinyjs)

# ---- Chargement et preparation des donnees ----
# IMPORTANT : placez "credit_risk_dataset.csv" a la racine du projet,
# au meme niveau que app.R / global.R

df_raw <- read.csv("credit_risk_dataset.csv", stringsAsFactors = FALSE)

df <- df_raw %>%
  mutate(
    person_emp_length = ifelse(is.na(person_emp_length),
                                median(person_emp_length, na.rm = TRUE),
                                person_emp_length),
    loan_int_rate = ifelse(is.na(loan_int_rate),
                            median(loan_int_rate, na.rm = TRUE),
                            loan_int_rate),
    person_home_ownership = as.factor(person_home_ownership),
    loan_intent = as.factor(loan_intent),
    cb_person_default_on_file = as.factor(cb_person_default_on_file),
    loan_status = as.factor(loan_status)
  ) %>%
  filter(person_age < 100, person_emp_length < 60) %>%
  na.omit()

# ---- Entrainement du modele (Random Forest) ----
set.seed(123)
n <- nrow(df)
train_idx <- sample(seq_len(n), size = 0.8 * n)
train_data <- df[train_idx, ]
test_data  <- df[-train_idx, ]

model_rf <- randomForest(
  loan_status ~ person_age + person_income + person_home_ownership +
    person_emp_length + loan_intent + loan_amnt + loan_int_rate +
    loan_percent_income + cb_person_default_on_file + cb_person_cred_hist_length,
  data = train_data,
  ntree = 200,
  importance = TRUE
)

pred_test <- predict(model_rf, newdata = test_data)
conf_mat <- table(Reel = test_data$loan_status, Predit = pred_test)
accuracy <- sum(diag(conf_mat)) / sum(conf_mat)

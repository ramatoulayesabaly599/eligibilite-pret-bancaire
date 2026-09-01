####################################################################
# APP.R
# Point d'entree de l'application. Assemble les pages definies dans
# pages/ (chacune dans son propre fichier) et lance l'app Shiny.
#
# NOTE : global.R est normalement auto-charge par Shiny, mais UNIQUEMENT
# si l'app est lancee via shiny::runApp() sur le dossier (ou le bouton
# "Run App" de RStudio). Pour que app.R fonctionne aussi avec
# Rscript app.R ou source("app.R"), on le charge explicitement ici.
####################################################################

# ---- Chargement des donnees, du modele et des packages (partage) ----
source("global.R")

# ---- Chargement des pages (chacune dans un fichier separe) ----
source("pages/simulation.R")
source("pages/performance.R")
source("pages/donnees.R")
source("pages/assistant.R")
source("pages/apropos.R")

# ---- INTERFACE UTILISATEUR ----
ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(title = "Eligibilite Pret Bancaire"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Simulation Client", tabName = "simulation", icon = icon("user-check")),
      menuItem("Performance du modele", tabName = "performance", icon = icon("chart-line")),
      menuItem("Donnees",

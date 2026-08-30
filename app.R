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
source("pages/apropos.R")

# ---- INTERFACE UTILISATEUR ----
ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(title = "Eligibilite Pret Bancaire"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Simulation Client", tabName = "simulation", icon = icon("user-check")),
      menuItem("Performance du modele", tabName = "performance", icon = icon("chart-line")),
      menuItem("A propos", tabName = "apropos", icon = icon("info-circle"))
    )
  ),

  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$script(src = "https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"),
      tags$style(HTML("
        .result-box { padding: 25px; border-radius: 10px; text-align: center; font-size: 22px; font-weight: bold; margin-top: 20px; }
        .approved { background-color: #d4edda; color: #155724; border: 2px solid #28a745; }
        .refused { background-color: #f8d7da; color: #721c24; border: 2px solid #dc3545; }
      "))
    ),

    # Chaque page (definie dans son propre fichier) est assemblee ici
    tabItems(
      simulation_ui,
      performance_ui,
      apropos_ui
    )
  )
)

# ---- LOGIQUE SERVEUR ----
# Chaque page a sa propre fonction serveur, appelee ici
server <- function(input, output, session) {
  simulation_server(input, output, session)
  performance_server(input, output, session)
  apropos_server(input, output, session)
}

# ---- LANCEMENT DE L'APPLICATION ----
shinyApp(ui = ui, server = server)

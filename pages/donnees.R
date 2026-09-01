####################################################################
# PAGE : DONNEES
# Affiche le jeu de donnees complet (credit_risk_dataset.csv)
####################################################################

# ---- UI de la page ----
donnees_ui <- tabItem(
  tabName = "donnees",
  fluidRow(
    box(title = "Jeu de donnees (credit_risk_dataset.csv)", status = "primary",
        solidHeader = TRUE, width = 12,
        p(paste0("Nombre total de clients : ", nrow(df))),
        DT::dataTableOutput("table_donnees")
    )
  )
)

# ---- Logique serveur de la page ----
donnees_server <- function(input, output, session) {
  output$table_donnees <- DT::renderDataTable({
    DT::datatable(
      df,
      options = list(pageLength = 15, scrollX = TRUE),
      rownames = FALSE
    )
  })
}

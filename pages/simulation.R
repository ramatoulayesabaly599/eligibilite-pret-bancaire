####################################################################
# PAGE : SIMULATION CLIENT
# Formulaire de saisie + prediction d'eligibilite + confettis/alerte
####################################################################

# ---- UI de la page ----
simulation_ui <- tabItem(
  tabName = "simulation",
  fluidRow(
    box(title = "Informations du client", status = "primary", solidHeader = TRUE,
        width = 5, collapsible = TRUE,

        numericInput("person_age", "Age du client", value = 30, min = 18, max = 100),
        numericInput("person_income", "Revenu annuel ($)", value = 50000, min = 0, step = 1000),
        selectInput("person_home_ownership", "Statut de logement",
                    choices = c("RENT", "OWN", "MORTGAGE", "OTHER")),
        numericInput("person_emp_length", "Anciennete emploi (annees)", value = 5, min = 0, max = 60),
        selectInput("loan_intent", "Objet du pret",
                    choices = c("PERSONAL", "EDUCATION", "MEDICAL", "VENTURE",
                                "HOMEIMPROVEMENT", "DEBTCONSOLIDATION")),
        numericInput("loan_amnt", "Montant du pret demande ($)", value = 10000, min = 0, step = 500),
        numericInput("loan_int_rate", "Taux d'interet (%)", value = 11, min = 0, max = 40, step = 0.1),
        numericInput("loan_percent_income", "Pret en % du revenu", value = 0.2, min = 0, max = 1, step = 0.01),
        selectInput("cb_person_default_on_file", "Anterieur de defaut de paiement",
                    choices = c("N", "Y")),
        numericInput("cb_person_cred_hist_length", "Historique de credit (annees)", value = 4, min = 0, max = 40),

        actionButton("predict_btn", "Evaluer la demande",
                     icon = icon("magnifying-glass-dollar"),
                     class = "btn-primary btn-lg", width = "100%")
    ),

    box(title = "Resultat de la simulation", status = "info", solidHeader = TRUE,
        width = 7,
        uiOutput("resultat_ui"),
        br(),
        plotOutput("proba_plot", height = "250px")
    )
  )
)

# ---- Logique serveur de la page ----
simulation_server <- function(input, output, session) {

  prediction_result <- eventReactive(input$predict_btn, {
    new_client <- data.frame(
      person_age = input$person_age,
      person_income = input$person_income,
      person_home_ownership = factor(input$person_home_ownership,
                                      levels = levels(df$person_home_ownership)),
      person_emp_length = input$person_emp_length,
      loan_intent = factor(input$loan_intent, levels = levels(df$loan_intent)),
      loan_amnt = input$loan_amnt,
      loan_int_rate = input$loan_int_rate,
      loan_percent_income = input$loan_percent_income,
      cb_person_default_on_file = factor(input$cb_person_default_on_file,
                                          levels = levels(df$cb_person_default_on_file)),
      cb_person_cred_hist_length = input$cb_person_cred_hist_length
    )

    pred_class <- predict(model_rf, newdata = new_client, type = "response")
    pred_proba <- predict(model_rf, newdata = new_client, type = "prob")

    list(classe = pred_class, proba = pred_proba)
  })

  output$resultat_ui <- renderUI({
    req(prediction_result())
    res <- prediction_result()
    eligible <- as.character(res$classe) == "0"

    if (eligible) {
      runjs("confetti({particleCount: 200, spread: 100, origin: {y: 0.6}});")
      div(class = "result-box approved",
          icon("champagne-glasses"), " Felicitations ! Client ELIGIBLE au pret bancaire ",
          br(), tags$span(style = "font-size:16px; font-weight:normal;",
                           paste0("Probabilite de remboursement : ",
                                  round(res$proba[, "0"] * 100, 1), "%")))
    } else {
      div(class = "result-box refused",
          icon("triangle-exclamation"), " Attention : Client NON ELIGIBLE (risque de defaut eleve) ",
          br(), tags$span(style = "font-size:16px; font-weight:normal;",
                           paste0("Probabilite de defaut de paiement : ",
                                  round(res$proba[, "1"] * 100, 1), "%")))
    }
  })

  output$proba_plot <- renderPlot({
    req(prediction_result())
    res <- prediction_result()
    proba_df <- data.frame(
      Classe = c("Eligible (remboursement)", "Non eligible (defaut)"),
      Probabilite = c(res$proba[, "0"], res$proba[, "1"])
    )
    barplot(proba_df$Probabilite, names.arg = proba_df$Classe,
            col = c("#28a745", "#dc3545"), ylim = c(0, 1),
            main = "Probabilites predites", ylab = "Probabilite")
  })
}

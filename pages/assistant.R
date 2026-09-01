####################################################################
# PAGE : ASSISTANT (IA hors-ligne, questions predefinies)
# Repond automatiquement a des questions sur le jeu de donnees,
# sans aucune connexion internet (tout est calcule localement en R).
####################################################################

# ---- UI de la page ----
assistant_ui <- tabItem(
  tabName = "assistant",
  fluidRow(
    box(title = "Assistant - Questions sur le jeu de donnees", status = "primary",
        solidHeader = TRUE, width = 12,
        p("Cet assistant repond a des questions predefinies sur le jeu de donnees, ",
          "sans connexion internet (calcul 100% local)."),
        textInput("question_utilisateur", label = NULL,
                  placeholder = "Ex : Quel est l'age moyen des clients ?",
                  width = "100%"),
        actionButton("poser_question", "Poser la question",
                     icon = icon("robot"), class = "btn-primary"),
        br(), br(),
        uiOutput("reponse_assistant"),
        hr(),
        h5("Exemples de questions que vous pouvez poser :"),
        tags$ul(
          tags$li("Quel est l'age moyen des clients ?"),
          tags$li("Quel est le revenu moyen ?"),
          tags$li("Quel est le taux de defaut ?"),
          tags$li("Quel est le montant moyen des prets ?"),
          tags$li("Quel est le taux d'interet moyen ?"),
          tags$li("Combien de clients dans la base ?"),
          tags$li("Quelle est la variable la plus importante ?"),
          tags$li("Quel est l'objet de pret le plus courant ?"),
          tags$li("Combien de clients ont deja fait defaut ?")
        )
    )
  )
)

# ---- Logique serveur de la page ----
assistant_server <- function(input, output, session) {

  reponse_reactive <- eventReactive(input$poser_question, {
    q <- tolower(input$question_utilisateur)

    if (q == "" || is.na(q)) {
      return("Merci de taper une question dans le champ ci-dessus.")
    }

    # ---- Base de regles (mots-cles -> reponse calculee) ----
    if (grepl("age moyen|age median|quel age", q)) {
      paste0("L'age moyen des clients est de ", round(mean(df$person_age), 1),
             " ans (age median : ", round(median(df$person_age), 1), " ans).")

    } else if (grepl("revenu moyen|revenu median|salaire moyen", q)) {
      paste0("Le revenu annuel moyen des clients est de ",
             format(round(mean(df$person_income)), big.mark = " "),
             " $ (revenu median : ", format(round(median(df$person_income)), big.mark = " "), " $).")

    } else if (grepl("taux de defaut|risque de defaut|pourcentage de defaut", q)) {
      taux <- round(mean(df$loan_status == "1") * 100, 1)
      paste0("Le taux de defaut observe dans la base est de ", taux, "% des clients.")

    } else if (grepl("combien de client.*defaut|clients.*deja fait defaut|anterieur.*defaut", q)) {
      n_defaut <- sum(df$cb_person_default_on_file == "Y")
      pct <- round(n_defaut / nrow(df) * 100, 1)
      paste0(n_defaut, " clients (", pct, "% de la base) ont un anterieur de defaut de paiement enregistre.")

    } else if (grepl("montant moyen|pret moyen|montant median", q)) {
      paste0("Le montant moyen des prets demandes est de ",
             format(round(mean(df$loan_amnt)), big.mark = " "),
             " $ (montant median : ", format(round(median(df$loan_amnt)), big.mark = " "), " $).")

    } else if (grepl("taux d.interet moyen|taux moyen", q)) {
      paste0("Le taux d'interet moyen applique aux prets est de ",
             round(mean(df$loan_int_rate, na.rm = TRUE), 2), "%.")

    } else if (grepl("combien de client|nombre de client|taille de la base|combien de ligne", q)) {
      paste0("La base contient ", nrow(df), " clients (apres nettoyage des donnees).")

    } else if (grepl("variable.*importante|plus importante|facteur.*important", q)) {
      imp <- importance(model_rf)
      var_top <- rownames(imp)[which.max(imp[, "MeanDecreaseGini"])]
      paste0("D'apres le modele Random Forest, la variable la plus importante pour predire ",
             "l'eligibilite est : ", var_top, ".")

    } else if (grepl("objet de pret|intention.*pret|raison.*pret", q)) {
      top_intent <- names(sort(table(df$loan_intent), decreasing = TRUE))[1]
      paste0("L'objet de pret le plus frequent chez les clients est : ", top_intent, ".")

    } else if (grepl("statut.*logement|logement le plus", q)) {
      top_home <- names(sort(table(df$person_home_ownership), decreasing = TRUE))[1]
      paste0("Le statut de logement le plus courant est : ", top_home, ".")

    } else if (grepl("precision.*modele|accuracy|performance.*modele", q)) {
      paste0("La precision (accuracy) du modele Random Forest est de ",
             round(accuracy * 100, 1), "% sur les donnees de test.")

    } else if (grepl("historique de credit moyen|anciennete credit", q)) {
      paste0("L'historique de credit moyen des clients est de ",
             round(mean(df$cb_person_cred_hist_length), 1), " ans.")

    } else if (grepl("anciennete.*emploi|emploi moyen", q)) {
      paste0("L'anciennete moyenne dans l'emploi actuel est de ",
             round(mean(df$person_emp_length, na.rm = TRUE), 1), " ans.")

    } else {
      paste0("Je n'ai pas de reponse predefinie pour cette question. ",
             "Essayez l'une des questions listees ci-dessous, ou reformulez ",
             "en utilisant des mots comme : age, revenu, defaut, pret, taux, ",
             "clients, variable importante, precision.")
    }
  })

  output$reponse_assistant <- renderUI({
    req(reponse_reactive())
    div(style = "padding: 15px; background-color: #e7f3ff; border-left: 4px solid #0d6efd; border-radius: 5px;",
        icon("robot"), strong(" Reponse : "), reponse_reactive())
  })
}

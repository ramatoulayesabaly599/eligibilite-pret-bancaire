# Deployer votre tableau de bord R (Shiny, multi-fichiers) sur shinyapps.io

## 1. Structure du dossier (a respecter exactement)
```
mon-dossier/
├── app.R                        <- point d'entree, assemble les pages
├── global.R                     <- donnees + entrainement du modele (partage)
├── credit_risk_dataset.csv      <- VOTRE fichier de donnees
└── pages/
    ├── simulation.R             <- page "Simulation client"
    ├── performance.R            <- page "Performance du modele"
    └── apropos.R                <- page "A propos"
```
Shiny charge automatiquement `global.R` avant `app.R`. Les fichiers dans
`pages/` sont ensuite explicitement charges via `source()` dans `app.R`.

## 2. Preparer le dossier
Ajoutez `credit_risk_dataset.csv` a la racine (au meme niveau que `app.R`
et `global.R`, PAS dans `pages/`).

## 3. Creer un compte shinyapps.io
https://www.shinyapps.io/ (gratuit, 500h actives/mois)

## 4. Installer et configurer rsconnect (dans RStudio)
```r
install.packages("rsconnect")
library(rsconnect)

# Account > Tokens > Show sur shinyapps.io pour recuperer ces valeurs
rsconnect::setAccountInfo(
  name   = "VOTRE_NOM_UTILISATEUR",
  token  = "VOTRE_TOKEN",
  secret = "VOTRE_SECRET"
)
```

## 5. Deployer
Important : deployez le DOSSIER ENTIER (avec `pages/` et le CSV inclus),
pas seulement `app.R` :
```r
rsconnect::deployApp(
  appDir = "chemin/vers/mon-dossier",
  appName = "eligibilite-pret-bancaire"
)
```

## 6. Recuperer le lien
`https://VOTRE_NOM_UTILISATEUR.shinyapps.io/eligibilite-pret-bancaire/`

## Navigation entre les pages
La navigation se fait via le menu lateral (sidebar) du dashboard :
"Simulation Client", "Performance du modele", "A propos" — chacune
correspondant a un fichier separe dans `pages/`.

## Notes
- Le modele s'entraine une seule fois au demarrage de l'app (dans `global.R`),
  et reste disponible pour toutes les pages sans recalcul
- Vous pouvez ajouter d'autres pages facilement : creez un nouveau fichier
  dans `pages/`, definissez `xxx_ui` (un `tabItem`) et `xxx_server`
  (une fonction), puis ajoutez-les dans `app.R` (menuItem, tabItems, server)

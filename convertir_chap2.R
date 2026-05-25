# ============================================================
# Script de conversion LaTeX (.Rnw) -> Quarto (.qmd)
# Recueil d'exercices ACT2000 - CHAPITRE 2
# Distributions d'échantillonnage (24 exercices)
# ============================================================

dossier_source <- "C:/Users/RYZ7/Documents/ACT2000/ACT2000-exercices-master/ACT2000-exercices-master"

fichier_test <- file.path(dossier_source, "echantillonnage.Rnw")
contenu <- readLines(fichier_test, encoding = "UTF-8")

debuts <- grep("\\\\begin\\{exercice\\}", contenu)
fins <- grep("\\\\end\\{exercice\\}", contenu)

# ============================================================
# Fonction pour convertir chunks R Rnw -> Quarto
# ============================================================

convertir_chunks_r <- function(texte) {
  lignes <- strsplit(texte, "\n")[[1]]
  resultat <- character()
  i <- 1
  
  while (i <= length(lignes)) {
    ligne <- lignes[i]
    
    if (grepl("^<<", ligne)) {
      options_str <- gsub("<<|>>=", "", ligne)
      is_figure_chunk <- FALSE
      temp_i <- i + 1
      while (temp_i <= length(lignes) && !grepl("^@", lignes[temp_i])) {
        if (grepl("plot|curve|hist|barplot", lignes[temp_i])) {
          is_figure_chunk <- TRUE
          break
        }
        temp_i <- temp_i + 1
      }
      
      if (is_figure_chunk) {
        resultat <- c(resultat, "```{r}")
      } else {
        resultat <- c(resultat, "```{r}")
      }
      
      if (grepl("echo=FALSE", options_str)) {
        resultat <- c(resultat, "#| echo: false")
      }
      if (grepl("fig=TRUE", options_str)) {
        resultat <- c(resultat, "#| fig-width: 6")
        resultat <- c(resultat, "#| fig-height: 6")
      }
      
      resultat <- c(resultat, "")
      
      i <- i + 1
      while (i <= length(lignes) && !grepl("^@", lignes[i])) {
        resultat <- c(resultat, lignes[i])
        i <- i + 1
      }
      
      resultat <- c(resultat, "```")
      resultat <- c(resultat, "")
    } else {
      resultat <- c(resultat, ligne)
    }
    
    i <- i + 1
  }
  
  return(paste(resultat, collapse = "\n"))
}

# ============================================================
# Fonction de conversion LaTeX -> Quarto
# ============================================================

latex_vers_quarto <- function(texte) {
  
  if (length(texte) == 0) return("")
  if (length(texte) == 1) {
    texte <- strsplit(texte, "\n")[[1]]
  }
  
  texte_combined <- paste(texte, collapse = "\n")
  texte_combined <- convertir_chunks_r(texte_combined)
  texte <- strsplit(texte_combined, "\n")[[1]]
  
  # --- Transformer les listes ---
  resultat <- character()
  dans_liste <- FALSE
  compteur_item <- 1
  buffer_item <- ""
  
  vider_buffer <- function() {
    if (nchar(buffer_item) > 0) {
      resultat <<- c(resultat, buffer_item, "")
      buffer_item <<- ""
    }
  }
  
  for (i in 1:length(texte)) {
    ligne <- texte[i]
    
    if (grepl("\\\\begin\\{(enumerate|inparaenum|itemize)\\}", ligne)) {
      dans_liste <- TRUE
      compteur_item <- 1
      buffer_item <- ""
    } else if (grepl("\\\\end\\{(enumerate|inparaenum|itemize)\\}", ligne)) {
      vider_buffer()
      dans_liste <- FALSE
    } else if (dans_liste && grepl("\\\\item", ligne)) {
      vider_buffer()
      lettre <- letters[compteur_item]
      ligne_modifiee <- gsub("\\\\item ?", paste0("**", lettre, ")** "), ligne)
      buffer_item <- ligne_modifiee
      compteur_item <- compteur_item + 1
    } else if (dans_liste) {
      ligne_propre <- trimws(ligne)
      if (nchar(ligne_propre) > 0) {
        buffer_item <- paste(buffer_item, ligne_propre)
      }
    } else {
      resultat <- c(resultat, ligne)
    }
  }
  
  texte <- paste(resultat, collapse = "\n")
  
  # --- Nettoyage des formules ---
  texte <- gsub("\\$\n", "$", texte)
  texte <- gsub("\n\\$", "$", texte)
  
  # --- Environnements mathématiques ---
  texte <- gsub("\\\\begin\\{displaymath\\}", "$$", texte)
  texte <- gsub("\\\\end\\{displaymath\\}",   "$$", texte)
  texte <- gsub("\\\\begin\\{equation\\*?\\}", "$$", texte)
  texte <- gsub("\\\\end\\{equation\\*?\\}",   "$$", texte)
  texte <- gsub("\\\\begin\\{align\\*?\\}", "$$\n\\\\begin{aligned}", texte)
  texte <- gsub("\\\\end\\{align\\*?\\}",   "\\\\end{aligned}\n$$", texte)
  
  # --- Commandes de texte ---
  texte <- gsub("\\\\mbox\\{", "\\\\text{", texte)
  texte <- gsub("\\\\emph\\{([^}]*)\\}", "*\\1*", texte)
  texte <- gsub("~", " ", texte)
  texte <- gsub("%[^\n]*", "", texte)
  texte <- gsub("(^|\n) +", "\\1", texte)
  
  # --- Nettoyage commandes LaTeX personnalisées ---
  texte <- gsub("\\\\intertext\\{", "\\\\text{", texte)
  texte <- gsub("\\\\nombre\\{([^}]*)\\}", "\\1", texte)
  texte <- gsub("\\\\abs", "|", texte)
  texte <- gsub("\\\\Sexpr\\{([^}]*)\\}", "[valeur]", texte)
  
  # --- Retirer les commandes exercice ---
  texte <- gsub("\\\\begin\\{exercice\\} ?", "", texte)
  texte <- gsub("\\\\end\\{exercice\\}",     "", texte)
  
  # --- Environnements figure ---
  texte <- gsub("\\\\begin\\{figure\\}", "", texte)
  texte <- gsub("\\\\end\\{figure\\}", "", texte)
  texte <- gsub("\\\\centering", "", texte)
  texte <- gsub("\\\\caption\\{([^}]*)\\}", ": \\1", texte)
  texte <- gsub("\\\\label\\{[^}]*\\}", "", texte)
  
  return(texte)
}

# ============================================================
# Boucle sur tous les exercices
# ============================================================

num_chap <- 2
tous_les_exercices <- character()
toutes_les_solutions <- character()

for (i in 1:length(debuts)) {
  
  exo <- contenu[debuts[i]:fins[i]]
  
  ligne_rep_debut <- grep("\\\\begin\\{rep\\}", exo)
  ligne_rep_fin   <- grep("\\\\end\\{rep\\}", exo)
  ligne_sol_debut <- grep("\\\\begin\\{sol\\}", exo)
  ligne_sol_fin   <- grep("\\\\end\\{sol\\}", exo)
  
  # Vérifier que tout existe
  if (length(ligne_rep_debut) == 0 || length(ligne_rep_fin) == 0 || 
      length(ligne_sol_debut) == 0 || length(ligne_sol_fin) == 0) {
    cat("⚠️  Exo", i, ": structure incomplète, PASSAGE\n")
    next
  }
  
  # Extraire les sections
  enonce   <- exo[2:(ligne_rep_debut - 1)]
  reponse  <- exo[(ligne_rep_debut + 1):(ligne_rep_fin - 1)]
  solution <- exo[(ligne_sol_debut + 1):(ligne_sol_fin - 1)]
  
  # Convertir
  enonce_q   <- latex_vers_quarto(enonce)
  reponse_q  <- latex_vers_quarto(reponse)
  solution_q <- latex_vers_quarto(solution)
  
  # Nettoyer références
  enonce_q <- gsub("\\\\ref\\{[^}]*\\}", "**[à compléter]**", enonce_q)
  solution_q <- gsub("\\\\ref\\{[^}]*\\}", "**[à compléter]**", solution_q)
  
  id_ex  <- paste0("sec-ex-",  num_chap, "-", i)
  id_sol <- paste0("sec-sol-", num_chap, "-", i)
  
  # Bloc exercice
  bloc_exo <- paste0(
    "## Exercice ", num_chap, ".", i, " {#", id_ex, " .unnumbered}\n\n",
    enonce_q, "\n\n",
    "::: {.callout-tip collapse=\"true\" title=\"Éléments de réponse\"}\n",
    reponse_q, "\n",
    ":::\n\n",
    "[📖 Voir la solution complète](../solutions/sol_chap", num_chap, ".qmd#", id_sol, ")\n\n"
  )
  
  # Bloc solution
  bloc_sol <- paste0(
    "## Solution ", num_chap, ".", i, " {#", id_sol, " .unnumbered}\n",
    "\n",
    "[← Retour à l'énoncé](../chapitres/Chap", num_chap, ".qmd#", id_ex, ")\n",
    "\n",
    solution_q, "\n",
    "\n"
  )
  
  tous_les_exercices <- c(tous_les_exercices, bloc_exo)
  toutes_les_solutions <- c(toutes_les_solutions, bloc_sol)
  
  cat("✅ Exo", i, "converti\n")
}

cat("\n✅ Conversion terminée :", length(debuts), "exercices traités.\n\n")

# ============================================================
# Écrire les fichiers .qmd
# ============================================================

contenu_chap2 <- paste0(
  "---\n",
  "title: \"Distributions d'échantillonnage\"\n",
  "---\n",
  "\n",
  paste(tous_les_exercices, collapse = "")
)

writeLines(contenu_chap2, "chapitres/Chap2.qmd")

contenu_sol2 <- paste0(
  "---\n",
  "title: \"Solutions — Distributions d'échantillonnage\"\n",
  "---\n",
  "\n",
  paste(toutes_les_solutions, collapse = "")
)

writeLines(contenu_sol2, "solutions/sol_chap2.qmd")

cat("✅ Fichiers écrits :\n")
cat("   - chapitres/Chap2.qmd\n")
cat("   - solutions/sol_chap2.qmd\n")
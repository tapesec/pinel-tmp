# frozen_string_literal: true

# Calcul le taux marginal d’imposition
class PrelevementsSociaux
  TAUX_PRELEVEMENT_SOCIAUX = 17.2

  def cout_prelevements_sociaux(revenu)
    (TAUX_PRELEVEMENT_SOCIAUX / 100.to_f * revenu).to_i
  end
end

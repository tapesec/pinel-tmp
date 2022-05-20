# frozen_string_literal: true

# Class qui permet de calculer les intérets d’un pret
class SimulateurPret
  def initialize(montant_initial, taux, duree_en_mois, mensualite = 0)
    @capital = montant_initial
    @taux = taux
    @duree_en_mois = duree_en_mois
    @mensualite = mensualite
  end

  def total_interet_annee(annee)
    tableau_amortissement = echeancier
    tableau_amortissement[annee - 1].reduce(0) do |interet, mensualite|
      interet + mensualite[:part_interet]
    end
  end

  def echeancier
    echeancier = []
    array_of_months.each_with_object({ capital_restant: @capital }) do |mois, acc|
      interet_mois_courant = calcul_interet_mois_courant(acc[:capital_restant])
      capital_mensuel = part_capital_mensuel(interet_mois_courant)
      acc[:capital_restant] -= capital_mensuel
      annee = annee_echeancier(mois)
      echeance = echeance(acc[:capital_restant], interet_mois_courant, capital_mensuel, mois)
      echeancier[annee] = [] if echeancier[annee].nil?
      echeancier[annee].push(echeance)
    end
    echeancier
  end

  def generate_echeancier
    echeancier = []
    array_of_months.each_with_object({ capital_restant: @capital }) do |mois, acc|
      interet_mois_courant = calcul_interet_mois_courant(acc[:capital_restant])
      capital_mensuel = mensualite - interet_mois_courant
      acc[:capital_restant] -= capital_mensuel
      annee = annee_echeancier(mois)
      echeance = echeance(acc[:capital_restant], interet_mois_courant, capital_mensuel, mois)
      echeancier[annee] = [] if echeancier[annee].nil?
      echeancier[annee].push(echeance)
    end
    echeancier
  end

  private

  def mensualite
    tp = (@taux / 100.to_f) / 12.to_f
    ((@capital * tp * (1 + tp)**@duree_en_mois) / (((1 + tp)**@duree_en_mois) - 1)).round(2)
  end

  def nouveau_capital(capital, capital_mensuel)
    (capital - capital_mensuel).round(2)
  end

  def array_of_months
    Array.new(@duree_en_mois) { |i| i }
  end

  def calcul_interet_mois_courant(capital)
    ((@taux / 12.to_f) * (capital / 100)).round(2)
  end

  def echeance(capital_restant, part_interet, part_capital, mois)
    { capital_restant_du: capital_restant.round(2), part_interet:, part_capital:, mensualite: (part_interet + part_capital).round(2), mois: mois + 1 }
  end

  def annee_echeancier(mois)
    (mois / 12).floor
  end

  def part_capital_mensuel(interet_mois_courant)
    (@mensualite - interet_mois_courant).round(2)
  end

  def taux_periodique; end
end

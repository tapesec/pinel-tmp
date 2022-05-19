# frozen_string_literal: true

# Estime les impots à payer pour le foyer
class SimulateImpotRevenu
  def execute(revenu_annuel, nombre_parts, _deduction_emploi_domicile, deduction_epargne)
    foyer_fiscal = FoyerFiscal.new(nombre_parts)

    declaration_sans_per = DeclarationRevenu.new
    declaration_sans_per.ajoute_revenu_annuel(revenu_annuel)
    impot_sans_deduc_per = ImpotsRevenu.new(foyer_fiscal, declaration_sans_per)
    a_payer_sans_deduc_per = impot_sans_deduc_per.montant_a_payer

    declaration_avec_per = DeclarationRevenu.new
    declaration_avec_per.ajoute_revenu_annuel(revenu_annuel)
    declaration_avec_per.declare_versements_per(deduction_epargne)
    impot_avec_deduc_per = ImpotsRevenu.new(foyer_fiscal, declaration_avec_per)
    a_payer_avec_deduc_per = impot_avec_deduc_per.montant_a_payer

    { a_payer: a_payer_avec_deduc_per,
      economie_per: a_payer_sans_deduc_per - a_payer_avec_deduc_per,
      taux_marginal_imposition: impot_avec_deduc_per.tmi_in_percent,
      versement_per_max_utile: impot_avec_deduc_per.plafond_versement_per_deduc }
  end
end

# frozen_string_literal: true

#     What I'm suposed to do ?
#         Input params :
#         Charge :
#         Prêt
#         - Total emprunt
#         - mensualités
#         - durée (mois)
#         Gestion locative
#         - Charges
#         - Frais gestion
#         - Entrée / sortie
#         Assurance
#         - PNO
#         Impôt
#         - Taxe foncière
#         Revenue :
#         - Loyer (Montant de référence du loyer)
#         - Crédit impôts
#         Durée simulation (années)
#         Output param
#         - Participation moyenne mensuelle
#         - Estimation du bien à la vente (dans 12 ans)
#         - Capital restant dû
#         - Capital net - participation
#         - Loyers encaissés
#         - Economie fiscale

# Calcul fonctionnel :
#     Pour chaque année
#         Cout du prêt + assurance + charges + taxe foncière + frais de gestion (variance possible: durée vacance locative + frais entrée / sortie)
#         -
#         Montant des loyers encaissés + crédit impôt (variance assurée: crédit impôt?, prix du loyer ?) TODO demander à Saniyé
#         =
#         Participation
#     fin pour
#
#
#     Calcul charges
#         frais gestion + frais de copropriété + PNO + taxe foncière
#
#     Calcul frais financiers
#         intérets prêt + assurance déces_invalidités + frais garantie et dossier bancaire
#
#     Calcul revenu fonciers
#         loyers - (total_charges + frais financiers)
#
#     Calcul impot sur revenu fonciers
#         Calcul revenu fonciers * TAUX_IMPOT_PS(17.2%) + Calucl revenu fonciers * TAUX_IMPOT_IR(tranche marginale)
#
#     Calcul prix de revient
#         Prix achat logement + TVA (238 000) + frais notaire
#
class SimulatePinel
  def run
    # # prêt
    # # total_pret = 250_250
    # mensualite = 1006.20
    # assurance_pret_elodie = 15.99
    # assurance_pret_lionnel = 18.34
    # duree_pret = 300
    # assurance_prevoyance_elodie = 2.66
    # assurance_prevoyance_lionnel = 3.34
    # cotisations_bancaires = 6.45
    # # gestion locative
    # charge = 126 # comprend la taxe foncière
    # frais_gestion_locative = 4.5 / loyer_hc * 100 + 3.72
    # # assurance PNO
    # assurance_pno = 144 / 12
    # taxe_fonciere = 615
    #
    # # revenu
    # loyer_hc = 615
    # charges = 126
    # # reduction epargne
    # per_elodie = 360 * 12
    #
    prix_achat = 238_000
    frais_notaire = 6000

    # declaration revenu
    revenu_annuel_foyer = 116_500
    parts_foyer = 3

    # Pinel
    montant_credit = 250_000
    echeance = 1006
    taux_interet = 1.15
    cout_assurance_annuelle = (15.99 + 18.34) * 12

    # Revenu foncier
    loyer_hc = 615
    taxe_fonciere = 615
    assurance_pno = 144
    frais_gestion_locative = 4.5 / loyer_hc * 100 + 3.72
    frais_dossier = 6000
    charges = 126

    simulation = { loyer_percu: 0, economie_fiscal: 0, participation: 0, capital_restant_du: 0 }

    [*1..13].each_with_object(simulation) do |acc, current_year|
      declaration244 = Declaration2044.new
      declaration_revenu = DeclarationRevenu.new
      foyer_fiscal = FoyerFiscal.new(3)
      if current_year == 1
        declaration244.ded_interets_emprunt(frais_dossier + (cout_assurance_annuelle / 4))
        declaration_revenu.ajoute_revenu_annuel(116_500)
        impot_current_year = ImpotsRevenu.new(foyer_fiscal, declaration_revenu)
        impot_current_year.ajoute_declaration2044(declaration244)
        acc[:capital_restant_du] = montant_credit
      else
        # TODO: compute
        initial_interet = acc[:capital_restant_du] * (taux_interet / 12)
        [*1..12].reduce(initial_interet) do |interet, month|
          acc[:capital_restant_du] - (echeance - interet) * (taux_interet / 12)
        end
        declaration244.ded_interets_emprunt(#TODO compute interet emprunt)
      end
    end
  end
end

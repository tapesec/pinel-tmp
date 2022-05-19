# frozen_string_literal: true

# Déclare les loyers perçus et les charges à déduire
# A remplir chaque année
class Declaration2044
  attr_reader :loyers_percus, :charges_gestion_locative, :assurance_pno, :travaux_entretien_rep, :taxe_fonciere, :charges_coprop, :interets_emprunts

  def initialize
    @loyers_percus = 0
    @charges_gestion_locative = 0
    @assurance_pno = 0
    @travaux_entretien_rep = 0
    @taxe_fonciere = 0
    @charges_coprop = 0
    @interets_emprunts = 0
  end

  def ajoute_loyers_bruts(loyers)
    @loyers_percus = loyers
  end

  # frais agence locative, conseiller fiscal, comptable, avocats, huissiers, tiers pour faire de l’administratif
  def ded_gestion_locative(montant)
    @charges_gestion_locative = montant
  end

  def ded_assurance_pno(montant)
    @assurance_pno = montant
  end

  # TODO: comprendre ce que ça inclus exactement
  def ded_travaux_entretien_rep(montant)
    @travaux_entretien_rep = montant
  end

  def ded_taxe_fonciere_sans_ordure(montant)
    @taxe_fonciere = montant
  end

  # voir ligne 229 - 230
  # 229 permet de déduire les charges versés
  # 230 permet de faire le delta entre les charges déclarés l’année précédente et ce qui a servi à des frais réellement
  # déductible
  def ded_charges_coprop(montant)
    @charges_coprop = montant
  end

  # déduire les intérêts d’emprunt
  # commissions prise par la banque (frais de dossier)
  # contribution fond mutuelle ?
  # assurance emprunteur
  def ded_interets_emprunt(montant)
    @interets_emprunts = montant
  end

  # En fait jusqu’à - 10 700 euros, le déficit est directement deductible des revenus net imposable mais le déficit ne doit pas tenir compte
  # des intérets d’emprunts. Par soucis de simplicité pour ce simulateur nous partons du principe que la première année, on génère directement
  # du déficit foncier
  # Plus de détail dans l’ebook Pinel page 50
  def revenu_foncier_imposable
    @loyers_percus - @charges_gestion_locative - @assurance_pno - @travaux_entretien_rep - @taxe_fonciere - @charges_coprop - @interets_emprunts
  end

  def deficit_foncier_reportable
    revenu_foncier_imposable.negative?
  end
end

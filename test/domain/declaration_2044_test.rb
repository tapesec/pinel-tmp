# frozen_string_literal: true

require 'test_helper'

class Declaration2044Test < ActiveSupport::TestCase
  test 'Doit retourner les revenus fonciers imposable' do
    declaration2044 = Declaration2044.new
    declaration2044.ajoute_loyers_bruts(1000)
    declaration2044.ded_charges_coprop(100)
    declaration2044.ded_assurance_pno(100)
    declaration2044.ded_gestion_locative(100)
    declaration2044.ded_travaux_entretien_rep(100)
    declaration2044.ded_taxe_fonciere_sans_ordure(100)
    declaration2044.ded_interets_emprunt(100)
    assert_equal 400, declaration2044.revenu_foncier_imposable, 'Doit retourner la diff entre les loyers et les charges'
  end
  test 'Doit retourner un deficit foncier' do
    declaration2044 = Declaration2044.new
    declaration2044.ajoute_loyers_bruts(100)
    declaration2044.ded_charges_coprop(100)
    declaration2044.ded_assurance_pno(100)
    declaration2044.ded_gestion_locative(100)
    declaration2044.ded_travaux_entretien_rep(100)
    declaration2044.ded_taxe_fonciere_sans_ordure(100)
    declaration2044.ded_interets_emprunt(100)
    assert_equal(-500, declaration2044.revenu_foncier_imposable, 'Doit retourner la diff entre les loyers et les charges')
  end
end

# frozen_string_literal: true

require 'test_helper'

class ImpotsRevenuTest < ActiveSupport::TestCase
  def setup
    @tmi = [
      { revenu_min: 0, revenu_max: 1000, taux: 0, niveau: 1 },
      { revenu_min: 1000, revenu_max: 2000, taux: 10, niveau: 2 },
      { revenu_min: 2000, revenu_max: 3000, taux: 20, niveau: 3 },
      { revenu_min: 3000, revenu_max: 4000, taux: 30, niveau: 4 },
      { revenu_min: 4000, revenu_max: Float::INFINITY, taux: 40, niveau: 5 }
    ]
  end

  test 'Doit retourner la somme à payer pour une tranche complete' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      assert_tranches = [{ niveau: 1, a_payer: 0 }, { niveau: 2, a_payer: 100 }, { niveau: 3, a_payer: 200 },
                         { niveau: 4, a_payer: 300 }]
      assert_tranches.each do |tranche|
        a_payer = impots_revenu.a_payer_pour_tranche_complete(tranche[:niveau])
        assert_equal tranche[:a_payer], a_payer, "Doit payer #{tranche[:a_payer]} pour la tranche #{tranche[:niveau]}"
      end
    end
  end

  test 'Ne doit pas payer d’impots si revenu dans premier palier' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(500)
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      assert_equal 0, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
    end
  end

  test 'Doit retourner la bonne somme à payer pour la tranche niveau 2' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(2000)
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      assert_equal 80, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
    end
  end

  test 'Doit retourner la bonne somme à payer pour la tranche niveau 3' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(3000)
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      devrait_payer = [1, 2].reduce(0) { |sum, tranche| sum + impots_revenu.a_payer_pour_tranche_complete(tranche) }
      devrait_payer += 140
      assert_equal devrait_payer, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
    end
  end

  test 'Doit retourner la bonne somme à payer pour la tranche niveau 4' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(4000)
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      devrait_payer = [1, 2, 3].reduce(0) { |sum, tranche| sum + impots_revenu.a_payer_pour_tranche_complete(tranche) }
      devrait_payer += 180
      assert_equal devrait_payer, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
    end
  end

  test 'Doit retourner la bonne somme à payer pour la tranche niveau 5 (niveau max)' do
    ImpotsRevenu.stub_const(:TRANCHES_MARGINALES, @tmi) do
      foyer_fiscal = FoyerFiscal.new(1)
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(10_000)
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      devrait_payer = [1, 2, 3, 4].reduce(0) { |sum, tranche| sum + impots_revenu.a_payer_pour_tranche_complete(tranche) }
      devrait_payer += 2000
      assert_equal devrait_payer, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
    end
  end

  test 'Doit retourner la somme à payer après application du plafond du Quotient Familial' do
    foyer_fiscal = FoyerFiscal.new(3)
    declaration = DeclarationRevenu.new
    declaration.ajoute_revenu_annuel(117_600)
    impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
    assert_equal 16_408, impots_revenu.montant_a_payer, 'Doit retourner la somme à payer'
  end

  test 'Doit retourner la somme à payer après deduction du crédit d’impôt du PER' do
    foyer_fiscal = FoyerFiscal.new(1)
    declaration = DeclarationRevenu.new
    declaration.ajoute_revenu_annuel(50_000)
    impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
    declaration_avec_per = DeclarationRevenu.new
    declaration_avec_per.ajoute_revenu_annuel(50_000)
    declaration_avec_per.declare_versements_per(8000)
    impots_revenu_avec_per = ImpotsRevenu.new(foyer_fiscal, declaration_avec_per)
    assert_equal 7420, impots_revenu.montant_a_payer, 'Doit retourner l’impot a payer avant deduction per'
    assert_equal 6070, impots_revenu_avec_per.montant_a_payer, 'Doit retourner l’impot à payer apres deduction per'
  end

  test 'Doit retourner le bon taux marginal d’imposition pour un revenu donnée' do
    [{ revenu: 50_000, parts: 1, expected: 30 }, { revenu: 100_000, parts: 2, expected: 30 }, { revenu: 170_000, parts: 3, expected: 41 }].each do |elem|
      foyer_fiscal = FoyerFiscal.new(elem[:parts])
      declaration = DeclarationRevenu.new
      declaration.ajoute_revenu_annuel(elem[:revenu])
      impots_revenu = ImpotsRevenu.new(foyer_fiscal, declaration)
      assert_equal elem[:expected], impots_revenu.tmi_in_percent, 'le TMI est incorrect'
    end
  end

  # test 'Doit retourner la reduction d’impot du au PER et la plafond max' do
  #   [{ part: 1, revenu: 50_000, versement: 15_000, expected_credit_impot: 1350, expected_plafond: 1350, expected_versement_utile: 4500 },
  #    { part: 2, revenu: 100_000, versement: 15_000, expected_credit_impot: 1350, expected_plafond: 1350, expected_versement_utile: 4500 },
  #    { part: 3, revenu: 170_000, versement: 15_000, expected_credit_impot: 3670, expected_plafond: 3670, expected_versement_utile: 10_800 }].each do |arrange|
  #     foyer_fiscal = FoyerFiscal.new(arrange[:part])
  #     foyer_fiscal.ajoute_revenu_annuel(arrange[:revenu])
  #     impots_revenu = ImpotsRevenu.new(foyer_fiscal)
  #     impots_revenu.declare_versements_per(arrange[:versement])
  #     reduction_per = impots_revenu.calcul_reduction_per
  #     p reduction_per
  #     assert_equal arrange[:expected_versement_utile], reduction_per[:versement_max_utile], "Doit retourner les versements max à effectuer pour optimiser (#{reduction_per[:versement_max_utile]})"
  #     assert_equal arrange[:expected_credit_impot], reduction_per[:credit_impot_epargne], "Doit économiser 4500 euros d’impot (#{reduction_per[:credit_impot_epargne]})"
  #     assert_equal arrange[:expected_plafond], reduction_per[:credit_impot_epargne_max], "Doit retourner le plafond de reduction max obtenable (#{reduction_per[:credit_impot_epargne_max]})"
  #   end
  # end

  # test 'Ne doit pas faire plus de reduction d’impot dû au PER si plafond dépassé' do
  #   foyer_fiscal = FoyerFiscal.new(3)
  #   foyer_fiscal.ajoute_revenu_annuel(170_000)
  #   impots_revenu = ImpotsRevenu.new(foyer_fiscal)
  #   impots_revenu.declare_versements_per(50_000)
  #   reduction_per = impots_revenu.calcul_reduction_per
  #   assert_equal 15_300, reduction_per[:credit_impot_epargne], 'Ne doit pas dépasser le plofond'
  # end
end

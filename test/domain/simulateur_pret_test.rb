# frozen_string_literal: true

require 'test_helper'

class SimulateurPretTest < ActiveSupport::TestCase
  test 'Doit retourner les intérets à payer pour une année donnée' do
    simulateur = SimulateurPret.new(100_000, 1.5, 300, 399.93)
    assert_equal 1324.4, simulateur.total_interet_annee(4), 'Erreur sur les intérêts de l’année'
  end

  test 'Doit retourner un echéancier cohérent' do
    simulateur = SimulateurPret.new(100_000, 1.5, 300, 399.93)
    assert_equal 399.43, simulateur.echeancier[24][11][:part_capital], 'Dernière écheance incorrect'
  end

  test 'Doit construire la structure de l’échéancier correctement' do
    simulateur = SimulateurPret.new(100_000, 1.5, 300, 399.93)
    p simulateur.echeancier
    assert_equal 25, simulateur.echeancier.length, 'Doit contenir 25 ans'
    assert_equal 12, simulateur.echeancier[24].length, 'Doit contenir 12 mois'
  end

  test 'Doit arroundir à l’entier inférieur' do
    assert_equal 14, 14.6.floor, 'test'
  end

  test 'Doit génerer un échéancier' do
    simulateur = SimulateurPret.new(100_000, 1, 300)
    p simulateur.generate_echeancier
  end

  test 'Doit calculer le montant fixe d’une échéance' do
    simulateur = SimulateurPret.new(100_000, 1.1, 300)
    p simulateur.generate_echeancier
    assert_equal 381.42, simulateur.generate_echeancier[0][0][:mensualite], 'Pas le bon échéancier'
  end
end

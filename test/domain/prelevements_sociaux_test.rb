# frozen_string_literal: true

require 'test_helper'

class PrelevementsSociauxTest < ActiveSupport::TestCase
  test 'Doit calculer le cout des prélèments sociaux pour un revenu donné' do
    revenu = 10_000
    ps = PrelevementsSociaux.new
    assert_equal(1719, ps.cout_prelevements_sociaux(revenu), 'Doit retourner 17.2% de la somme')
  end
end

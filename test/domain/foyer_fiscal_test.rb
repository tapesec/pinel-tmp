# frozen_string_literal: true

require 'test_helper'

class FoyerFiscalTest < ActiveSupport::TestCase
  test 'Doit retourner le nombre de part d’un foyer' do
    foyer_fiscal = FoyerFiscal.new(3)
    assert_equal 3, foyer_fiscal.nombre_parts
  end
end

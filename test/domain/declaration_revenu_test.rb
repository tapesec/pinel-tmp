# frozen_string_literal: true

require 'test_helper'

class DeclarationRevenuTest < ActiveSupport::TestCase
  test 'Doit contenir les revenus du foyers' do
    declaration = DeclarationRevenu.new
    declaration.ajoute_revenu_annuel(80_000)
    assert_equal 80_000, declaration.revenu_foyer
  end
end

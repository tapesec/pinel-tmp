# frozen_string_literal: true

# Represente la declaration revenu
class DeclarationRevenu
  attr_reader :revenu_foyer, :versements_per

  def initialize
    @revenu_foyer = 0
    @versements_per = 0
  end

  def ajoute_revenu_annuel(revenus)
    @revenu_foyer = revenus
  end

  def declare_versements_per(versements)
    @versements_per = versements
  end
end

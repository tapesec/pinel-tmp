# frozen_string_literal: true

# Represente les revenus associé à un même décalaration d’impôts
class FoyerFiscal
  attr_reader :nombre_parts, :revenu_foyer

  POURCENT_DEDUCTION_FORFAITAIRE = 10
  def initialize(nombre_parts)
    @nombre_parts = nombre_parts
    @revenu_foyer = 0
  end

  def revenu_net_imposable
    @revenu_foyer - (POURCENT_DEDUCTION_FORFAITAIRE / 100.to_f * @revenu_foyer).to_i
  end
end

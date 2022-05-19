# frozen_string_literal: true

# Calcul le taux marginal d’imposition
class ImpotsRevenu
  attr_reader :foyer_fiscal, :versements_per, :declaration_impot, :declaration2044

  REDUCTION_PAR_DEMI_PART = 1592
  BASE_COUPLE_FISCAL = 2
  TRANCHES_MARGINALES = [
    { revenu_min: 0, revenu_max: 10_225, taux: 0, niveau: 1 },
    { revenu_min: 10_226, revenu_max: 26_070, taux: 11, niveau: 2 },
    { revenu_min: 26_071, revenu_max: 74_545, taux: 30, niveau: 3 },
    { revenu_min: 74_545, revenu_max: 160_336, taux: 41, niveau: 4 },
    { revenu_min: 160_337, revenu_max: Float::INFINITY, taux: 45, niveau: 5 }
  ].freeze
  POURCENT_DEDUCTION_FORFAITAIRE = 10
  PASS = 41_136
  CREDIT_IMPOT_MAX_EPARGNE = ((PASS * 8) / 10.to_f).to_i

  def initialize(foyer_fiscal, declaration_impot)
    @foyer_fiscal = foyer_fiscal
    @declaration_impot = declaration_impot
    @versements_per = 0
  end

  def ajoute_declaration2044(declaration)
    @declaration2044 = declaration
  end

  def montant_a_payer
    resultat = calcul_tmi_et_a_payer
    resultat[:a_payer]
  end

  def plafond_versement_per_deduc
    dix_pourcent_revenu_ref = (rni_sans_deduction_per / 10.to_f).to_i
    plafond_revenu_vs_max_epargne = dix_pourcent_revenu_ref < CREDIT_IMPOT_MAX_EPARGNE ? dix_pourcent_revenu_ref : CREDIT_IMPOT_MAX_EPARGNE
    (PASS / 10.to_f).to_i > plafond_revenu_vs_max_epargne ? (PASS / 10.to_f).to_i : plafond_revenu_vs_max_epargne
  end

  def tmi_in_percent
    resultat = calcul_tmi_et_a_payer
    resultat[:tmi]
  end

  def a_payer_pour_tranche_complete(niveau_tranche)
    tranche = TRANCHES_MARGINALES.find do |t|
      t[:niveau] == niveau_tranche
    end
    impot_tranche_complete(tranche)
  end

  def revenu_net_imposable
    revenu_foncier_imposable = @declaration2044.nil? ? 0 : @declaration2044.revenu_foncier_imposable
    @declaration_impot.revenu_foyer - (POURCENT_DEDUCTION_FORFAITAIRE / 100.to_f * @declaration_impot.revenu_foyer).to_i - versement_per_deductible + revenu_foncier_imposable
  end

  def rni_sans_deduction_per
    @declaration_impot.revenu_foyer - (POURCENT_DEDUCTION_FORFAITAIRE / 100.to_f * @declaration_impot.revenu_foyer).to_i
  end

  private

  def calcul_tmi_et_a_payer
    a_payer = base_calcul_tranches_ir(calcul_quotient_familial(@foyer_fiscal.nombre_parts), @foyer_fiscal.nombre_parts)
    tmi = calcul_tmi(calcul_quotient_familial(@foyer_fiscal.nombre_parts))
    if @foyer_fiscal.nombre_parts <= BASE_COUPLE_FISCAL
      { a_payer:, tmi: }
    else
      a_payer_avec_plafond_qf = calcul_ir_avec_plafond_qf(calcul_quotient_familial(BASE_COUPLE_FISCAL))
      tmi_avec_plafond_qf = calcul_tmi(calcul_quotient_familial(BASE_COUPLE_FISCAL))
      a_payer >= a_payer_avec_plafond_qf ? { a_payer:, tmi: } : { a_payer: a_payer_avec_plafond_qf, tmi: tmi_avec_plafond_qf }
    end
  end

  def calcul_tmi(revenu)
    tranche = TRANCHES_MARGINALES.find do |t|
      t[:revenu_min] < revenu && t[:revenu_max] > revenu
    end
    tranche[:taux]
  end

  def calcul_quotient_familial(nombre_parts)
    (revenu_net_imposable / nombre_parts.to_f).to_i
  end

  def calcul_ir_avec_plafond_qf(revenu)
    a_payer_base_couple_fiscal = base_calcul_tranches_ir(revenu, BASE_COUPLE_FISCAL)
    reduction_max_plafond_qf = (@foyer_fiscal.nombre_parts - BASE_COUPLE_FISCAL) * (REDUCTION_PAR_DEMI_PART * 2)
    a_payer_base_couple_fiscal - reduction_max_plafond_qf
  end

  def versement_per_deductible
    @declaration_impot.versements_per > plafond_versement_per_deduc ? plafond_versement_per_deduc : @declaration_impot.versements_per
  end

  def base_calcul_tranches_ir(revenu, nombre_parts)
    resultat = TRANCHES_MARGINALES.reduce(0) do |a_payer, current_tranche|
      if revenu_in_current_tranche(revenu, current_tranche)
        a_payer + impot_of_current_tranche(current_tranche[:taux], revenu, current_tranche[:revenu_min])
      elsif revenu_au_dessus_tranche(revenu, current_tranche)
        a_payer + impot_tranche_complete(current_tranche)
      else
        a_payer + 0
      end
    end
    (resultat * nombre_parts).to_i
  end

  def revenu_au_dessus_tranche(revenu, current_tranche)
    revenu > current_tranche[:revenu_max]
  end

  def revenu_in_current_tranche(revenu, current_tranche)
    revenu > current_tranche[:revenu_min] && revenu < current_tranche[:revenu_max]
  end

  def impot_of_current_tranche(percent, revenu, tranche_min)
    current_tranche_revenu = revenu - tranche_min
    (percent / 100.to_f * current_tranche_revenu.to_f).to_i
  end

  def impot_tranche_complete(tranche)
    base_calcul = tranche[:revenu_max] - tranche[:revenu_min]
    (tranche[:taux] / 100.to_f * base_calcul).to_i
  end
end

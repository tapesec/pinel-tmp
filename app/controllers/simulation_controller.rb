# frozen_string_literal: true

class SimulationController < ApplicationController
  def index
    query = request.query_parameters
    simulation = SimulateImpotRevenu.new
    result = simulation.execute(query[:revenu_annuel].to_i, query[:nombre_parts].to_i, query[:deduction_travail_domicile], query[:deduction_epargne].to_i)
    render json: result
  end
end

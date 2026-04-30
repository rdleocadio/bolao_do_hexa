class BracketsController < ApplicationController
  before_action :authenticate_user!

  def index
    @predictions_by_match_id = current_user.predictions.index_by(&:match_id)
    @second_phase_matches = Match.second_phase.order(:kickoff_at)
    @round_of_16_matches = Match.round_of_16.order(:kickoff_at)
    @quarterfinal_matches = Match.quarterfinal.order(:kickoff_at)
    @semifinal_matches = Match.semifinal.order(:kickoff_at)
    @third_place_match = Match.third_place.order(:kickoff_at).first
    @final_match = Match.final.order(:kickoff_at).first
  end
end

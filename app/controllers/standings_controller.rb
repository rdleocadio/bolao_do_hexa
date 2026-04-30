class StandingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @standings_by_group = AllGroupsStandingsCalculator.call
  end
end

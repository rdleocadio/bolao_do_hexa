class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])

    @predictions = @user.predictions
                        .joins(:match)
                        .includes(:match)
                        .where(
                          "matches.locked_at <= :now OR matches.kickoff_at <= :now",
                          now: Time.current
                        )
                        .order("matches.kickoff_at ASC")

    @total_points = @predictions.sum(&:points)

    @leagues = League.joins(:league_memberships)
                     .where(
                       league_memberships: {
                         user_id: @user.id,
                         status: LeagueMembership.statuses[:approved]
                       }
                     )
                     .includes(:owner, :league_memberships)
                     .distinct

    @league_positions = {}

    @leagues.each do |league|
      ranking = LeagueRankingCalculator.call(league)
      position = ranking.find_index { |entry| entry[:user].id == @user.id }
      @league_positions[league.id] = position.present? ? position + 1 : nil
    end

    @exact_scores_count = @predictions.count(&:exact_score?)
  end
end

class MatchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @matches = filtered_matches
    @predictions_by_match_id = predictions_by_match_id
    @available_groups = available_groups
  end

  private

  def filtered_matches
    matches = Match.includes(:predictions).ordered

    matches = matches.where(stage: params[:stage]) if params[:stage].present?
    matches = matches.where(group_code: params[:group]) if params[:group].present?

    if params[:status].present?
      matches = matches.to_a

      case params[:status]
      when "open"
        matches = matches.select { |match| !match.locked? && !match.finished? }
      when "closed"
        matches = matches.select { |match| match.locked? || match.finished? }
      end
    end

    if params[:without_prediction] == "1"
      predicted_match_ids = current_user.predictions.pluck(:match_id)

      matches = if matches.is_a?(Array)
                  matches.reject { |match| predicted_match_ids.include?(match.id) }
                else
                  matches.where.not(id: predicted_match_ids)
                end
    end

    matches
  end

  def predictions_by_match_id
    match_ids = @matches.map(&:id)

    current_user.predictions
                .where(match_id: match_ids)
                .index_by(&:match_id)
  end

  def available_groups
    Match.where.not(group_code: [nil, ""])
         .distinct
         .order(:group_code)
         .pluck(:group_code)
  end
end

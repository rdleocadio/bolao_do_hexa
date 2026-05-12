class Admin::GroupStandingOverridesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_override, only: [:edit, :update]

  def index
    @groups = Match.group_stage
                   .distinct
                   .pluck(:group_code)
                   .compact
                   .sort

    @selected_group = params[:group_code].presence || @groups.first

    @overrides = GroupStandingOverride
                   .where(group_code: @selected_group)
                   .order(:position)
  end

  def generate
    group_code = params[:group_code].presence

    unless group_code
      redirect_to admin_group_standing_overrides_path,
                  alert: "Selecione um grupo antes de gerar a classificação manual."
      return
    end

    standings = GroupStandingsCalculator
                  .new(group_code)
                  .automatic_standings

    GroupStandingOverride.where(group_code: group_code).delete_all

    standings.each_with_index do |standing, index|
      GroupStandingOverride.create!(
        group_code: group_code,
        team_name: standing.team,
        position: index + 1,
        played: standing.played,
        wins: standing.wins,
        draws: standing.draws,
        losses: standing.losses,
        goals_for: standing.goals_for,
        goals_against: standing.goals_against,
        goal_difference: standing.goal_difference,
        points: standing.points
      )
    end

    redirect_to admin_group_standing_overrides_path(group_code: group_code),
                notice: "Classificação manual gerada com sucesso."
  end

  def edit
  end

  def update
    if @override.update(override_params)
      redirect_to admin_group_standing_overrides_path(group_code: @override.group_code),
                  notice: "Classificação manual atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def reset
    group_code = params[:group_code].presence

    unless group_code
      redirect_to admin_group_standing_overrides_path,
                  alert: "Selecione um grupo antes de restaurar a classificação automática."
      return
    end

    GroupStandingOverride.where(group_code: group_code).delete_all

    redirect_to admin_group_standing_overrides_path(group_code: group_code),
                notice: "Classificação automática restaurada com sucesso."
  end

  private

  def set_override
    @override = GroupStandingOverride.find(params[:id])
  end

  def override_params
    params.require(:group_standing_override).permit(
      :position,
      :played,
      :wins,
      :draws,
      :losses,
      :goals_for,
      :goals_against,
      :goal_difference,
      :points,
      :admin_note
    )
  end
end

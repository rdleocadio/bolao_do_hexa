module Admin
  class MatchesController < Admin::BaseController
    before_action :set_match, only: [:edit, :update, :destroy, :lock_now, :reopen]

    def index
      @matches = Match.ordered
      @matches = @matches.where(stage: params[:stage]) if params[:stage].present?
      @matches = @matches.where(group_code: params[:group_code].upcase) if params[:group_code].present?
    end

    def new
      @match = Match.new
    end

    def create
      @match = Match.new(match_params)
      sync_team_names_from_records

      if @match.save
        redirect_to admin_matches_path, notice: "Jogo criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @match.assign_attributes(match_params)
      sync_team_names_from_records

      if @match.save
        redirect_to admin_matches_path, notice: "Jogo atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @match.destroy

      redirect_to admin_matches_path(index_filters), notice: "Jogo excluído com sucesso."
    end

    def bulk_destroy
      match_ids = Array(params[:match_ids]).reject(&:blank?)

      if match_ids.blank?
        redirect_to admin_matches_path(index_filters), alert: "Nenhum jogo selecionado para exclusão."
        return
      end

      Match.where(id: match_ids).destroy_all

      redirect_to admin_matches_path(index_filters), notice: "#{match_ids.count} jogo(s) excluído(s) com sucesso."
    end

    def lock_now
      @match.update!(locked_at: Time.current)
      redirect_to admin_matches_path(index_filters), notice: "Palpites travados para este jogo."
    end

    def reopen
      @match.update!(locked_at: nil)
      redirect_to admin_matches_path(index_filters), notice: "Palpites reabertos para este jogo."
    end

    def bulk_new
    end

    def bulk_create
      stage = params[:stage]
      quantity = params[:quantity].to_i
      interval_minutes = params[:interval_minutes].to_i
      kickoff_at = Time.zone.parse(params[:kickoff_at])

      if stage.blank? || quantity <= 0 || kickoff_at.blank?
        redirect_to bulk_new_admin_matches_path, alert: "Preencha fase, quantidade e data inicial."
        return
      end

      Match.transaction do
        quantity.times do |index|
          Match.create!(
            stage: stage,
            home_team: "A definir",
            away_team: "A definir",
            kickoff_at: kickoff_at + (interval_minutes * index).minutes
          )
        end
      end

      redirect_to admin_matches_path(stage: stage), notice: "#{quantity} jogos criados com sucesso."
    rescue ArgumentError, TypeError
      redirect_to bulk_new_admin_matches_path, alert: "Data inicial inválida."
    end

    def bulk_edit
      @stage = params[:stage]
      @group_code = params[:group_code]

      @matches = Match.ordered
      @matches = @matches.where(stage: @stage) if @stage.present?
      @matches = @matches.where(group_code: @group_code.upcase) if @group_code.present?
    end

    def bulk_update
      matches_params = params[:matches]

      if matches_params.blank?
        redirect_to bulk_edit_admin_matches_path, alert: "Nenhum jogo foi enviado para atualização."
        return
      end

      Match.transaction do
        matches_params.each do |id, attributes|
          match = Match.find(id)

          match.assign_attributes(
            home_team_id: blank_to_nil(attributes[:home_team_id]),
            away_team_id: blank_to_nil(attributes[:away_team_id]),
            home_score: blank_to_nil(attributes[:home_score]),
            away_score: blank_to_nil(attributes[:away_score]),
            kickoff_at: blank_to_nil(attributes[:kickoff_at]),
            locked_at: blank_to_nil(attributes[:locked_at])
          )

          match.home_team = match.home_team_record&.name || "A definir"
          match.away_team = match.away_team_record&.name || "A definir"

          match.save!
        end
      end

      redirect_to admin_matches_path, notice: "Jogos atualizados com sucesso."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      redirect_to bulk_edit_admin_matches_path(
        stage: params[:stage],
        group_code: params[:group_code]
      ), alert: "Não foi possível atualizar todos os jogos."
    end

    private

    def set_match
      @match = Match.find(params[:id])
    end

    def match_params
      params.require(:match).permit(
        :home_team_id,
        :away_team_id,
        :home_team,
        :away_team,
        :home_score,
        :away_score,
        :stage,
        :group_code,
        :kickoff_at,
        :locked_at,
        :penalty_winner
      )
    end

    def sync_team_names_from_records
      @match.home_team = @match.home_team_record&.name || "A definir"
      @match.away_team = @match.away_team_record&.name || "A definir"
    end

    def blank_to_nil(value)
      value.present? ? value : nil
    end

    def index_filters
      {
        stage: params[:stage],
        group_code: params[:group_code]
      }.compact_blank
    end
  end
end

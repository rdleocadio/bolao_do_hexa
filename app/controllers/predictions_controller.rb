class PredictionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prediction, only: [:update, :destroy]

  def create
    match = Match.find(create_prediction_params[:match_id])

    if match.locked? || match.finished?
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  alert: "O prazo para palpitar nesta partida já encerrou."
      return
    end

    @prediction = current_user.predictions.new(create_prediction_params)

    if @prediction.save
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  notice: "Palpite salvo com sucesso."
    else
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  alert: @prediction.errors.full_messages.to_sentence
    end
  end

  def update
    if @prediction.match.locked? || @prediction.match.finished?
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  alert: "O prazo para editar o palpite desta partida já encerrou."
      return
    end

    if @prediction.update(update_prediction_params)
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  notice: "Palpite atualizado com sucesso."
    else
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  alert: @prediction.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @prediction.match.locked? || @prediction.match.finished?
      redirect_to matches_path(stage: params[:stage], group: params[:group]),
                  alert: "O prazo para limpar este palpite já encerrou."
      return
    end

    @prediction.destroy

    redirect_to matches_path(stage: params[:stage], group: params[:group]),
                notice: "Palpite limpo com sucesso."
  end

  private

  def set_prediction
    @prediction = current_user.predictions.find(params[:id])
  end

  def create_prediction_params
    params.require(:prediction).permit(
      :match_id,
      :predicted_home_score,
      :predicted_away_score,
      :penalty_winner
    )
  end

  def update_prediction_params
    params.require(:prediction).permit(
      :predicted_home_score,
      :predicted_away_score,
      :penalty_winner
    )
  end
end

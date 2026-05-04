class PredictionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prediction, only: [:update, :destroy]

  def create
    match = Match.find(create_prediction_params[:match_id])

    if match.locked? || match.finished?
      redirect_to return_to_match_path(match),
                  alert: "O prazo para palpitar nesta partida já encerrou."
      return
    end

    @prediction = current_user.predictions.new(create_prediction_params)

    if @prediction.save
      redirect_to return_to_match_path(match),
                  notice: "Palpite salvo com sucesso."
    else
      redirect_to return_to_match_path(match),
                  alert: @prediction.errors.full_messages.to_sentence
    end
  end

  def update
    match = @prediction.match

    if match.locked? || match.finished?
      redirect_to return_to_match_path(match),
                  alert: "O prazo para editar o palpite desta partida já encerrou."
      return
    end

    if @prediction.update(update_prediction_params)
      redirect_to return_to_match_path(match),
                  notice: "Palpite atualizado com sucesso."
    else
      redirect_to return_to_match_path(match),
                  alert: @prediction.errors.full_messages.to_sentence
    end
  end

  def destroy
    match = @prediction.match

    if match.locked? || match.finished?
      redirect_to return_to_match_path(match),
                  alert: "O prazo para limpar este palpite já encerrou."
      return
    end

    @prediction.destroy

    redirect_to return_to_match_path(match),
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

  def return_to_match_path(match)
    base_path = params[:return_to].presence || matches_path

    "#{base_path}#match-#{match.id}"
  end
end

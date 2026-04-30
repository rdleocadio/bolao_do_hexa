class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :match

  validates :predicted_home_score, :predicted_away_score,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :user_id, uniqueness: { scope: :match_id }

  # =========================
  # REGRA DE PONTUAÇÃO
  # =========================
  def points
    return 0 unless match.finished?
    return 0 unless predicted_home_score.present? && predicted_away_score.present?

    if exact_score?
      5
    elsif correct_result_and_one_team_goals?
      4
    elsif correct_result?
      3
    else
      0
    end
  end

  # =========================
  # AUXILIARES
  # =========================

  # Placar exato
  def exact_score?
    predicted_home_score == match.home_score &&
      predicted_away_score == match.away_score
  end

  # Acertou resultado + gols de um dos times
  def correct_result_and_one_team_goals?
    correct_result? && (
      predicted_home_score == match.home_score ||
      predicted_away_score == match.away_score
    )
  end

  # Acertou vencedor ou empate
  def correct_result?
    predicted_result == official_result
  end

  # Resultado do palpite
  def predicted_result
    return :draw if predicted_home_score == predicted_away_score
    predicted_home_score > predicted_away_score ? :home : :away
  end

  # Resultado real
  def official_result
    return :draw if match.home_score == match.away_score
    match.home_score > match.away_score ? :home : :away
  end
end

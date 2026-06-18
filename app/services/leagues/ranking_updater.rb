module Leagues
  class RankingUpdater
    def initialize(league)
      @league = league
    end

    def call
      ranking = build_ranking

      ranking.each_with_index do |entry, index|
        LeagueRanking.find_or_initialize_by(
          league: @league,
          user: entry[:user]
        ).update!(
          points: entry[:points],
          exact_scores: entry[:exact_scores],
          partial_scores: entry[:partial_scores],
          winners: entry[:winners],
          misses: entry[:misses],
          position: index + 1
        )
      end
    end

    private

    def build_ranking
      users = @league.league_memberships
                     .approved
                     .includes(:user)
                     .map(&:user)

      predictions = Prediction
                    .includes(:match)
                    .where(user: users)
                    .group_by(&:user_id)

      users.map do |user|
        calculate_user_score(user, predictions[user.id] || [])
      end.sort_by do |entry|
        [
          -entry[:points],
          -entry[:exact_scores],
          -entry[:partial_scores],
          -entry[:winners],
          entry[:misses]
        ]
      end
    end

    def calculate_user_score(user, predictions)
      exact_scores = 0
      partial_scores = 0
      winners = 0
      misses = 0
      points = 0

      predictions.each do |prediction|
        match = prediction.match

        next unless match.present?
        next unless match.finished?
        next if match.home_score.nil? || match.away_score.nil?
        next if prediction.predicted_home_score.nil? || prediction.predicted_away_score.nil?

        home_prediction = prediction.predicted_home_score
        away_prediction = prediction.predicted_away_score
        home_real = match.home_score
        away_real = match.away_score

        if exact_score?(home_prediction, away_prediction, home_real, away_real)
          exact_scores += 1
          points += 5
        elsif partial_score?(home_prediction, away_prediction, home_real, away_real)
          partial_scores += 1
          points += 4
        elsif winner_or_draw?(home_prediction, away_prediction, home_real, away_real)
          winners += 1
          points += 3
        else
          misses += 1
        end
      end

      {
        user: user,
        points: points,
        exact_scores: exact_scores,
        partial_scores: partial_scores,
        winners: winners,
        misses: misses
      }
    end

    def exact_score?(home_prediction, away_prediction, home_real, away_real)
      home_prediction == home_real && away_prediction == away_real
    end

    def partial_score?(home_prediction, away_prediction, home_real, away_real)
      winner_or_draw?(home_prediction, away_prediction, home_real, away_real) &&
        (home_prediction == home_real || away_prediction == away_real)
    end

    def winner_or_draw?(home_prediction, away_prediction, home_real, away_real)
      match_result(home_prediction, away_prediction) == match_result(home_real, away_real)
    end

    def match_result(home_score, away_score)
      return :home if home_score > away_score
      return :away if away_score > home_score

      :draw
    end
  end
end

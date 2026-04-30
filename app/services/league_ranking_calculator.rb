class LeagueRankingCalculator
  def self.call(league)
    approved_users = User.joins(:league_memberships)
                         .where(league_memberships: {
                           league_id: league.id,
                           status: LeagueMembership.statuses[:approved]
                         })
                         .distinct
                         .includes(predictions: :match)

    ranking = approved_users.map do |user|
      finished_predictions = user.predictions.select do |prediction|
        prediction.match&.finished?
      end

      {
        user: user,
        points: finished_predictions.sum(&:points),
        exact_scores: finished_predictions.count(&:exact_score?)
      }
    end

    ranking.sort_by do |entry|
      [
        -entry[:points],
        -entry[:exact_scores],
        entry[:user].name.to_s
      ]
    end
  end
end

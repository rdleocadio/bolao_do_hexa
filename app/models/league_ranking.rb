class LeagueRanking < ApplicationRecord
  belongs_to :league
  belongs_to :user

  validates :league_id, uniqueness: { scope: :user_id }
end

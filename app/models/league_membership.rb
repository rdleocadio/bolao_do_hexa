class LeagueMembership < ApplicationRecord
  belongs_to :user
  belongs_to :league

  enum :role, { member: 0, owner: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :user_id, uniqueness: { scope: :league_id }
end

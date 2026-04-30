class Team < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  def flag_url
    "flags/#{code}.png"
  end
end

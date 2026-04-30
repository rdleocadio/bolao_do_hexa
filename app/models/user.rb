class User < ApplicationRecord
  has_many :owned_leagues, class_name: "League", foreign_key: "owner_id", dependent: :destroy
  has_many :league_memberships, dependent: :destroy
  has_many :leagues, through: :league_memberships
  has_many :predictions, dependent: :destroy

  has_one_attached :avatar

  after_create :join_canario_league

  validates :name, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private

  def join_canario_league
    league = League.find_by(name: "Liga do Canário")
    return unless league

    LeagueMembership.find_or_create_by!(
      user: self,
      league: league
    ) do |membership|
      membership.status = "approved" if membership.respond_to?(:status=)
    end
  end
end

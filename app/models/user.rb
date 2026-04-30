class User < ApplicationRecord
  has_many :owned_leagues, class_name: "League", foreign_key: "owner_id", dependent: :destroy
  has_many :league_memberships, dependent: :destroy
  has_many :leagues, through: :league_memberships
  has_many :predictions, dependent: :destroy

  has_one_attached :avatar

  validates :name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

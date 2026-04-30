class League < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :league_memberships, dependent: :destroy
  has_many :users, through: :league_memberships

  has_one_attached :image

  before_validation :generate_code, on: :create

  validates :name, presence: true,
                 uniqueness: { case_sensitive: false, message: "já está em uso" }
  validates :code, presence: true, uniqueness: true

  def private?
    private
  end

  def public?
    !private?
  end

  def pending_memberships
    league_memberships.pending.includes(:user)
  end

  def approved_memberships
    league_memberships.approved.includes(:user)
  end

  private

  def generate_code
    return if code.present?

    self.code = loop do
      random_code = SecureRandom.alphanumeric(8).upcase
      break random_code unless League.exists?(code: random_code)
    end
  end
end

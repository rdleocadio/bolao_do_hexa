class GroupStandingOverride < ApplicationRecord
  validates :group_code, presence: true
  validates :team_name, presence: true

  validates :position,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :team_name,
            uniqueness: {
              scope: :group_code,
              message: "já possui ajuste manual para este grupo"
            }
end

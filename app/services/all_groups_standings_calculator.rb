class AllGroupsStandingsCalculator
  def self.call
    new.call
  end

  def call
    group_codes.index_with do |group_code|
      GroupStandingsCalculator.call(group_code)
    end
  end

  private

  def group_codes
    Match.where(stage: :group_stage)
         .distinct
         .order(:group_code)
         .pluck(:group_code)
         .compact
  end
end

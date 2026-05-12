class CreateGroupStandingOverrides < ActiveRecord::Migration[7.1]
  def change
    create_table :group_standing_overrides do |t|
      t.string :group_code
      t.string :team_name
      t.integer :position
      t.integer :played
      t.integer :wins
      t.integer :draws
      t.integer :losses
      t.integer :goals_for
      t.integer :goals_against
      t.integer :goal_difference
      t.integer :points
      t.text :admin_note

      t.timestamps
    end
  end
end

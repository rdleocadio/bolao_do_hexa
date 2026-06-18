class CreateLeagueRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :league_rankings do |t|
      t.references :league, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :points, null: false, default: 0
      t.integer :exact_scores, null: false, default: 0
      t.integer :partial_scores, null: false, default: 0
      t.integer :winners, null: false, default: 0
      t.integer :misses, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :league_rankings, [:league_id, :user_id], unique: true
    add_index :league_rankings, [:league_id, :position]
  end
end

class InitSchema < ActiveRecord::Migration[7.1]
  def change
    enable_extension "plpgsql"

    # ===== USERS =====
    create_table :users do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :name
      t.boolean :admin, default: false, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true

    # ===== LEAGUES =====
    create_table :leagues do |t|
      t.string :name
      t.string :code
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.boolean :private, default: false, null: false

      t.timestamps
    end

    add_index :leagues, "lower(name)", unique: true

    # ===== LEAGUE MEMBERSHIPS =====
    create_table :league_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :league, null: false, foreign_key: true
      t.integer :role
      t.integer :status

      t.timestamps
    end

    # ===== TEAMS =====
    create_table :teams do |t|
      t.string :name
      t.string :code
      t.string :confederation

      t.timestamps
    end

    # ===== MATCHES =====
    create_table :matches do |t|
      t.string :home_team
      t.string :away_team
      t.integer :home_score
      t.integer :away_score
      t.integer :stage
      t.string :group_code
      t.datetime :kickoff_at
      t.datetime :locked_at

      t.string :penalty_winner

      t.string :source_home_type
      t.integer :source_home_value
      t.string :source_away_type
      t.integer :source_away_value

      t.references :home_team, foreign_key: { to_table: :teams }
      t.references :away_team, foreign_key: { to_table: :teams }

      t.timestamps
    end

    # ===== PREDICTIONS =====
    create_table :predictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.integer :predicted_home_score
      t.integer :predicted_away_score
      t.string :penalty_winner

      t.timestamps
    end

    # ===== ACTIVE STORAGE =====
    create_table :active_storage_blobs do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.text :metadata
      t.string :service_name, null: false
      t.bigint :byte_size, null: false
      t.string :checksum
      t.datetime :created_at, null: false

      t.index :key, unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string :name, null: false
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.bigint :blob_id, null: false
      t.datetime :created_at, null: false

      t.index [:blob_id]
      t.index [:record_type, :record_id, :name, :blob_id],
              unique: true,
              name: "index_active_storage_attachments_uniqueness"
    end

    create_table :active_storage_variant_records do |t|
      t.bigint :blob_id, null: false
      t.string :variation_digest, null: false

      t.index [:blob_id, :variation_digest],
              unique: true,
              name: "index_active_storage_variant_records_uniqueness"
    end

    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end

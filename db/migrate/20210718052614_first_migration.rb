class FirstMigration < ActiveRecord::Migration[6.0]
  def change
    create_table :servers do |t|
      t.string :discord_id, index: { unique: true }, null: false

      t.timestamps
    end

    create_table :channels do |t|
      t.references :server, null: false
      t.string :discord_id, index: { unique: true }, null: false

      t.timestamps
    end

    create_table :polls_models do |t|
      t.references :server, null: false
      t.string :name, index: { unique: true }, null: false

      t.timestamps
    end

    create_table :polls_instances do |t|
      t.references :channel, null: false
      t.string :discord_id, index: { unique: true }, null: false

      t.timestamps
    end

    create_table :voters do |t|
      t.string :discord_id, index: { unique: true }, null: false
      t.string :name, null: false

      t.timestamps
    end

    create_table :games do |t|
      t.references :server, null: false
      t.string :name, null: false
      t.boolean :favored, null: false, default: false

      t.timestamps
    end

    create_table :votes do |t|
      t.references :poll_instances, null: false
      t.references :voters, null: false
      t.references :games, null: false

      t.timestamps
    end

    create_join_table :poll_instances, :games
    add_index :games_poll_instances, [:poll_instance_id, :game_id], unique: true
  end
end

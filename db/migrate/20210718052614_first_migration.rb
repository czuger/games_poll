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


    create_table :poll_models do |t|
      t.references :server, null: false, index: false
      t.string :name, null: false
      t.string :title, null: false

      t.timestamps
    end
    add_index :poll_models, [:server_id, :name], unique: true


    create_table :poll_models_choices do |t|
      t.references :poll_model, null: false, index: false
      t.bigint :choice_id, null: false, index: false
      t.string :choice_type, null: false, index: false

      t.integer :emoji, null: false

      t.timestamps
    end
    add_index :poll_models_choices, [:poll_model_id, :choice_id, :choice_type], unique: true,
              name: :poll_models_choices_unique_index


    create_table :poll_instances do |t|
      t.references :poll_model, null: false
      t.references :channel, null: false
      t.string :discord_id, index: { unique: true }, null: false

      t.timestamps
    end


    create_table :poll_schedules do |t|
      t.references :poll_model, null: false
      t.integer :day, null: false

      t.timestamps
    end
    add_index :poll_schedules, [:poll_model_id, :day], unique: true


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

    create_table :orga_choices do |t|
      t.references :server, null: false
      t.string :name, null: false
      t.boolean :before, null: false, default: true
      t.boolean :other_game_action, null: false, default: false

      t.timestamps
    end

    create_table :votes do |t|
      t.references :poll_instance, null: false, index: false
      t.references :voter, null: false, index: false
      t.bigint :choice_id, null: false, index: false
      t.string :choice_type, null: false, index: false

      t.timestamps
    end
    add_index :votes, [:poll_instance_id, :choice_id, :choice_type, :voter_id], unique: true,
              name: :votes_unique_index



    # create_join_table :poll_instances, :games
    # add_index :games_poll_instances, [:poll_instance_id, :game_id], unique: true
  end
end

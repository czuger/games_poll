class DiscordMessageIdNullableInPolls < ActiveRecord::Migration[6.0]
  def up
    change_column :polls, :title, :string, null: false
    change_column :polls, :discord_message_id, :string, null: true
    change_column :polls, :channel_id, :integer, null: true

    add_foreign_key :polls, :channels
    add_reference :polls, :server, foreign_key: true, null: false

    add_index :polls, [:server_id, :name], unique: true
    remove_index :polls, :channel_id
  end

  def down
    change_column :polls, :title, :string, null: true
    change_column :polls, :discord_message_id, :string, null: false

    change_column :polls, :channel_id, :integer, null: false
    remove_foreign_key :polls, :channels

    remove_index :polls, column: [:server_id, :name]
    remove_reference :polls, :server

    add_index :polls, :channel_id
  end
end

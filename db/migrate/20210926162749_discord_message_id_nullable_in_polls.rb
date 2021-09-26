class DiscordMessageIdNullableInPolls < ActiveRecord::Migration[6.0]
  def change
    change_column :polls, :discord_message_id, :string, null: true
  end
end

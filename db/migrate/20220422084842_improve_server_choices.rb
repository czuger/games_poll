class ImproveServerChoices < ActiveRecord::Migration[6.0]
  def change
    remove_column :poll_choices, :emoji, :integer, null: true

    add_column :server_choices, :first_row, :boolean, null: false, default: true
    add_column :server_choices, :emoji, :string, null: true
    add_column :server_choices, :button_style, :string, null: true
    add_column :server_choices, :run_command, :string, null: true

    remove_column :server_choices, :before, :boolean, null: true
    remove_column :server_choices, :other_game_action, :boolean, null: true
  end
end

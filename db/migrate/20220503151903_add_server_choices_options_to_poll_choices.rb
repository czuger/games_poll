class AddServerChoicesOptionsToPollChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :poll_choices, :first_row, :boolean, null: false, default: true
    add_column :poll_choices, :emoji, :string, null: true
    add_column :poll_choices, :button_style, :string, null: true
    add_column :poll_choices, :run_command, :string, null: true
    add_column :poll_choices, :name, :string, null: true
  end
end

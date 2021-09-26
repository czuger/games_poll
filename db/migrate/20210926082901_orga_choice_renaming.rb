class OrgaChoiceRenaming < ActiveRecord::Migration[6.0]
  def change
    rename_table :orga_choices, :server_choices

    rename_column :add_other_games, :poll_instance_id, :poll_id
    rename_column :poll_choices, :poll_instance_id, :poll_id
    rename_column :votes, :poll_instance_id, :poll_id

    remove_column :polls, :poll_model_id
  end
end

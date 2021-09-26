class PollsSimplification < ActiveRecord::Migration[6.0]
  def change
    rename_table :poll_instance_choices, :poll_choices
    rename_table :poll_instances, :polls

    add_column :polls, :name, :string
    add_column :polls, :title, :string
    add_column :polls, :schedule_day, :int, size: 1

    drop_table :poll_models
    drop_table :poll_schedules
  end
end

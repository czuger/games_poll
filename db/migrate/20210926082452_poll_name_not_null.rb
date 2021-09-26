class PollNameNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column :polls, :name, :string, null: false
  end
end

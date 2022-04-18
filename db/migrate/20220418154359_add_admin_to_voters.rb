class AddAdminToVoters < ActiveRecord::Migration[6.0]
  def change
    add_column :voters, :admin, :boolean, default: false, null: false
  end
end

class CreateVoteHistory < ActiveRecord::Migration[6.0]
  def change
    create_table :vote_histories do |t|
      t.references :voter, null: false, index: false
      t.references :game, null: false, index: false

      t.timestamps
    end
  end
end

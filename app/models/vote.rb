class Vote < ActiveRecord::Base
  belongs_to :voter
  belongs_to :poll_instance
  belongs_to :game
end
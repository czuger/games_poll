require 'minitest/autorun'
require 'active_record'

require_relative '../app/commands/games/insert'
require_relative '../app/commands/games/all'

require_relative '../app/commands/polls/add'
require_relative '../app/commands/games/insert'

require 'pp'

class BaseTests < MiniTest::Test
  def setup
    db_config = YAML.load_file( 'db/config.yml' )
    ActiveRecord::Base.establish_connection(db_config['test'])

    ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')

    clear_database
    # ActiveRecord::BaseTests.logger = Logger.new STDOUT
  end

  def teardown
    clear_database
  end

  private

  def clear_database
    PollChoice.delete_all
    Poll.delete_all

    Game.delete_all
    Server.delete_all
  end
end
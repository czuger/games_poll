require 'minitest/autorun'
require 'active_record'
require_relative '../app/commands/games/insert'

class TestGames < MiniTest::Unit::TestCase

  def setup
    db_config = YAML.load_file( 'db/config.yml' )
    ActiveRecord::Base.establish_connection(db_config['test'])
    ActiveRecord::Base.logger = Logger.new STDOUT
  end

  def test_gi
    Commands::Games::Insert.gi(1)
  end

end
require 'minitest/autorun'
require 'active_record'
require_relative '../app/commands/polls/add'
require_relative '../app/commands/games/insert'
require 'pp'

class TestPolls < MiniTest::Unit::TestCase

  def setup
    db_config = YAML.load_file( 'db/config.yml' )
    ActiveRecord::Base.establish_connection(db_config['test'])

    PollChoice.delete_all
    Poll.delete_all
    Game.delete_all
    Server.delete_all

    # ActiveRecord::Base.logger = Logger.new STDOUT
  end

  def test_pa
    Commands::Games::Insert.gi(1)
    Commands::Polls::Add.pa(1, 1, 'gp!pa MyPoll')

    # p Server.first
    # pp Poll.first
    assert Poll.first.name == 'MyPoll'

    # p Server.first.server_choices.count
    # pp Poll.first.poll_choices
    assert Poll.first.poll_choices.count == 6+3
  end

end
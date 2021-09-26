require_relative 'base_tests'

class TestPolls < BaseTests

  def test_pa
    Commands::Games::Insert.gi(1)
    Commands::Polls::Add.pa(1,  'gp!pa MyPoll')

    # p Server.first
    # pp Poll.first
    assert Poll.first.name == 'MyPoll'

    # p Server.first.server_choices.count
    # pp Poll.first.poll_choices
    assert Poll.first.poll_choices.count == 6+3
  end

  def test_pa_not_created_if_existing
    Commands::Games::Insert.gi(1)

    Commands::Polls::Add.pa(1,  'gp!pa MyPoll')
    result = Commands::Polls::Add.pa(1,  'gp!pa MyPoll')

    # p result
    assert result == 'Poll MyPoll already exists'
  end

end
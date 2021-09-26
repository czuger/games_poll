require_relative 'base_tests'

class TestGames < BaseTests

  def test_gi
    Commands::Games::Insert.gi(1)

    # p Server.first
    assert Server.first.discord_id == '1'

    # p Server.first.server_choices.count
    # p Server.first.games.count

    assert Server.first.games.count == 23+6
    assert Server.first.server_choices.count == 3
  end

  def test_ga
    Commands::Games::All.ga(1, 'dummy my game')

    # p Server.first
    assert Server.first.discord_id == '1'

    # p Server.first.games.last

    assert Server.first.games.last.name == 'my game'
  end

end
require_relative "../lib/reachy/game.rb"
require "test/unit"

class TestReachy < Test::Unit::TestCase

  def test_me
    round1_hash = {"wind" => nil, "number" => 0, "bonus" => 0, "riichi" => 0, "scores" => { "Joshua" => 35000, "Kenta" => 35000, "Thao" => 35000 }}
    round2_hash = {"wind" => 'E', "number" => 1, "bonus" => 0, "riichi" => 0, "scores" => { "Joshua" => 33400, "Kenta" => 39800, "Thao" => 31800 }}
    game_hash  = { "filename" => "test1",
                   "created_at" => "2016-11-05T14:05:00-07:00",
                   "last_updated" => "2016-11-05T14:05:00-07:00",
                   "mode" => 3,
                   "players" => ["Joshua", "Kenta", "Thao"],
                   "scoreboard" => [round1_hash, round2_hash] }
    g = Game.new(game_hash)
    g.write_data
    g.print_scoreboard
    assert_equal(1+1, 2)
  end

end

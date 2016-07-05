require_relative 'defines'

##############################################
# TODO: Score result class
# ... the definition of hardcode
##############################################

class Score

  # Hash of tsumo scores
  @@tsumo_h = {
    "dealer" => {
      "han_1" => {
        "fu_20" => 400,
        "fu_30" => 500,
        "fu_40" => 700,
        "fu_50" => 800,
        "fu_60" => 1000,
        "fu_70" => 1200
      },
      "han_2" => {
        "fu_20" => 700,
        "fu_30" => 1000,
        "fu_40" => 1300,
        "fu_50" => 1600,
        "fu_60" => 2000,
        "fu_70" => 2300
      },
      "han_3" => {
        "fu_20" => 1300,
        "fu_30" => 2000,
        "fu_40" => 2600,
        "fu_50" => 3200,
        "fu_60" => 3900
      },
      "han_4" => {
        "fu_20" => 2600,
        "fu_30" => 3900
      },
      "mangan"          => 4000,
      "haneman"         => 6000,
      "baiman"          => 8000,
      "sanbaiman"       => 12000,
      "yakuman"         => 16000,
      #"double_yakuman"  => 32000
    },
    "nondealer" => {
      "han_1" => {
        "fu_20" => { "dealer" => 400, "nondealer" => 200 },
        "fu_30" => { "dealer" => 500, "nondealer" => 300 },
        "fu_40" => { "dealer" => 700, "nondealer" => 400 },
        "fu_50" => { "dealer" => 800, "nondealer" => 400 },
        "fu_60" => { "dealer" => 1000, "nondealer" => 500 },
        "fu_70" => { "dealer" => 1200, "nondealer" => 600 }
      },
      "han_2" => {
        "fu_20" => { "dealer" => 700, "nondealer" => 400 },
        "fu_30" => { "dealer" => 1000, "nondealer" => 500 },
        "fu_40" => { "dealer" => 1300, "nondealer" => 700 },
        "fu_50" => { "dealer" => 1600, "nondealer" => 800 },
        "fu_60" => { "dealer" => 2000, "nondealer" => 1000 },
        "fu_70" => { "dealer" => 2300, "nondealer" => 1200 }
      },
      "han_3" => {
        "fu_20" => { "dealer" => 1300, "nondealer" => 700 },
        "fu_30" => { "dealer" => 2000, "nondealer" => 1000 },
        "fu_40" => { "dealer" => 2600, "nondealer" => 1300 },
        "fu_50" => { "dealer" => 3200, "nondealer" => 1600 },
        "fu_60" => { "dealer" => 3900, "nondealer" => 2000 }
      },
      "han_4" => {
        "fu_20" => { "dealer" => 2600, "nondealer" => 1300 },
        "fu_30" => { "dealer" => 3900, "nondealer" => 2000 }
      },
      "mangan"          => { "dealer" => 4000, "nondealer" => 2000 },
      "haneman"         => { "dealer" => 6000, "nondealer" => 3000 },
      "baiman"          => { "dealer" => 8000, "nondealer" => 4000 },
      "sanbaiman"       => { "dealer" => 12000, "nondealer" => 6000 },
      "yakuman"         => { "dealer" => 16000, "nondealer" => 8000 },
      #"double_yakuman"  => { "dealer" => 32000, "nondealer" => 16000 }
    }
  }

  # Hash of ron scores
  @@ron_h = {
    "dealer" => {
      "han_1" => {
        "fu_20" => 1000,
        "fu_30" => 1500,
        "fu_40" => 2000,
        "fu_50" => 2400,
        "fu_60" => 2900,
        "fu_70" => 3400
      },
      "han_2" => {
        "fu_20" => 2000,
        "fu_30" => 2900,
        "fu_40" => 3900,
        "fu_50" => 4800,
        "fu_60" => 5800,
        "fu_70" => 6800
      },
      "han_3" => {
        "fu_20" => 3900,
        "fu_30" => 5800,
        "fu_40" => 7700,
        "fu_50" => 9600,
        "fu_60" => 11600
      },
      "han_4" => {
        "fu_20" => 7700,
        "fu_30" => 11600
      },
      "mangan"          => 12000,
      "haneman"         => 18000,
      "baiman"          => 24000,
      "sanbaiman"       => 36000,
      "yakuman"         => 48000,
      #"double_yakuman"  => 96000
    },
    "nondealer" => {
      "han_1" => {
        "fu_20" => 700,
        "fu_30" => 1000,
        "fu_40" => 1300,
        "fu_50" => 1600,
        "fu_60" => 2000,
        "fu_70" => 2300
      },
      "han_2" => {
        "fu_20" => 1300,
        "fu_30" => 2000,
        "fu_40" => 2600,
        "fu_50" => 3200,
        "fu_60" => 3900,
        "fu_70" => 4500
      },
      "han_3" => {
        "fu_20" => 2600,
        "fu_30" => 3900,
        "fu_40" => 5200,
        "fu_50" => 6300,
        "fu_60" => 7700
      },
      "han_4" => {
        "fu_20" => 5200,
        "fu_30" => 7700
      },
      "mangan"          => 8000,
      "haneman"         => 12000,
      "baiman"          => 16000,
      "sanbaiman"       => 24000,
      "yakuman"         => 32000,
      #"double_yakuman"  => 64000
    }
  }

  # Hash of chombo scores
  @@chombo_h = {
    "dealer" => 4000,
    "nondealer" => { "dealer" => 4000, "nondealer" => 2000 }
  }

  # Initialize Score table
  def initialize
    #nothing to do here..yet
  end

  # Convert han, fu input to hash keys
  def to_keys(han,fu)
    keys = []
    if ((han<3 && fu>70) || (han==3 && fu>60) || (han==4 && fu>30) || (han==5))
      keys = ["mangan"]
    elsif (han==6 || han==7)
      keys = ["haneman"]
    elsif (han==8 || han==9 || han==10)
      keys = ["baiman"]
    elsif (han==11 || han==12)
      keys = ["sanbaiman"]
    elsif (han==13)
      keys = ["yakuman"]
    else
      keys << "han_" + han.to_s
      keys << "fu_" + fu.to_s
    end
    return keys
  end

  # Get Tsumo settlements
  # Param: dealer - bool indicating if dealer won
  #        hand   - list of hand value (e.g. ["mangan"], [2,60])
  def get_tsumo(dealer,hand)
  end

  # Get Ron settlements
  # Param: dealer - bool indicating if dealer won
  #        hand   - list of hand value (e.g. ["mangan"], [2,60])
  def get_ron(han,fu,dealer)
  end

  # Get Chombo settlements
  def get_chombo(dealer)
  end

end

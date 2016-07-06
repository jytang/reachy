require_relative 'defines'
require_relative 'scoretable'

##############################################
# TODO: Scoring module
##############################################

module Scoring

  # Convert han, fu input to hash keys
  def Scoring.to_keys(han,fu)
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
  #        hand   - list representing hand value (e.g. ["mangan"], [2,60])
  def Scoring.get_tsumo(dealer,hand)
  end

  # Get Ron settlements
  # Param: dealer - bool indicating if dealer won
  #        hand   - list representing hand value (e.g. ["mangan"], [2,60])
  def Scoring.get_ron(han,fu,dealer)
  end

  # Get Chombo settlements
  def Scoring.get_chombo(dealer)
  end

end

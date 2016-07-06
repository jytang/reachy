require_relative 'defines'
require_relative 'scoretable'

##############################################
# TODO: Scoring module
##############################################

module Scoring

  # Point constants
  P_BONUS   = 300
  P_RIICHI  = 1000
  P_TENPAI  = 3000

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
    keys_h = if hand.first.instance_of?(String) then hand
             else Scoring.to_keys(hand[0],hand[1]) end
    if dealer
      val = if keys_h[1] then H_TSUMO["dealer"][keys_h[0]][keys_h[1]]
            else H_TSUMO["dealer"][keys_h[0]] end
      return { "nondealer" => val }
    else
      val = if keys_h[1] then H_TSUMO["nondealer"][keys_h[0]][keys_h[1]]
            else H_TSUMO["nondealer"][keys_h[0]] end
      return val
    end
  end

  # Get Ron settlements
  # Param: dealer - bool indicating if dealer won
  #        hand   - list representing hand value (e.g. ["mangan"], [2,60])
  def Scoring.get_ron(dealer,hand)
  end

  # Get Chombo settlements
  # Param: dealer - bool indicating if dealer chombo
  def Scoring.get_chombo(dealer)
    if dealer
      return { "nondealer" => H_CHOMBO["dealer"] }
    else
      return H_CHOMBO["nondealer"]
    end
  end

end

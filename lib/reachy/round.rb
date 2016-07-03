COL_SPACING = 15

##############################################
# TODO: Round record class
##############################################
class Round

  attr_reader   :name           # Name of round (e.g. E1B2R1)
  attr_reader   :wind           # Round wind
  attr_reader   :number         # Round number
  attr_reader   :bonus          # Bonus sticks at beginning of round
  attr_accessor :riichi         # Riichi sticks available before round ends
  attr_accessor :scores         # Hash of <player's name> => <score>

  # Initialize round
  # Param: round - hash of round data
  # Populate Round object with info from hash
  def initialize(round)
  end

  # Create a deep copy
  def clone
    return Marshal.load(Marshal.dump(self))
  end

  # Add riichi stick declared by player
  def add_riichi(player)
  end

  # Print single line round scores
  def print_scores
  end

  # Print bonus and riichi sticks summary
  def print_sticks
  end

end


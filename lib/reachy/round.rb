##############################################
# TODO: Round record class
##############################################
class Round

  attr_accessor :name           # Name of round (e.g. E1B2R1)
  attr_reader   :wind           # Round wind
  attr_reader   :bonus          # Bonus sticks at beginning of round
  attr_accessor :riichi         # Riichi sticks available before round ends
  attr_accessor :scores         # Hash of <player's name> => <score>

  # Initialize round
  def initialize(round)
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


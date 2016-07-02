##############################################
# TODO: Scoreboard record class
##############################################
class Game

  attr_reader   :filename         # Name of JSON file
  attr_reader   :created_at       # Timestamp at creation
  attr_accessor :last_updated     # Timestamp at last updated
  attr_reader   :mode             # Game mode
  attr_reader   :players          # List of player names
  attr_accessor :scoreboard       # List of round records

  # Initialize game
  def initialize(db)
  end

  # Read from file
  def read_data
  end

  # Write to file
  def write_data
  end

  # Add new round result
  def add_round(round)
  end

  # Remove latest round
  def remove_last_round
  end

  # Add riichi stick declared by player
  def add_riichi(player)
  end

  # Print entire scoreboard
  def print_scoreboard
  end

  # Print last round scores
  # Round       Joshua    Kenta     Thao
  # E1B1R2      33400     39800     31800
  def print_last_round
  end

  # Print 1-line summary of game
  # game1: 3P (E1B1R1) ~ Joshua, Kenta, Thao ~ 2016-11-05 14:05:00
  def to_string
  end

end

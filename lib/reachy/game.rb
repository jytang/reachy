require 'json'
require 'date'
require 'pp'

require_relative 'round'

##############################################
# Scoreboard record class
##############################################
class Game

  attr_reader   :filename         # Name of JSON file
  attr_reader   :created_at       # Timestamp at creation
  attr_accessor :last_updated     # Timestamp at last updated
  attr_reader   :mode             # Game mode
  attr_reader   :players          # List of player names
  attr_accessor :scoreboard       # List of round records

  # Initialize game
  # Param: db - hash of game data
  # Populate Game object with info from hash
  def initialize(db)
    @filename = db["filename"]
    @created_at = DateTime.parse(db["created_at"])
    @last_updated = DateTime.parse(db["last_updated"])
    @mode = db["mode"]
    @players = db["players"]
    @scoreboard = []
    db["scoreboard"].each do |round|
      @scoreboard << Round.new(round)
    end
  end

  # Read JSON database file and delegate to initialize() to repopulate object
  def read_data
    file = File.read("../data/" + @filename + ".json")
    db = JSON.parse(file)
    self.initialize(db)
  end

  # Write Game object to JSON database file
  def write_data
    hash = self.instance_variables.each_with_object({}) \
      { |var, h| h[var.to_s.delete("@")] = self.instance_variable_get(var) }
    File.open("../data/" + @filename + ".json", "w") do |f|
      f.write(JSON.pretty_generate(hash))
    end
  end

  # Add new round result
  # Param: round - hash of new round record
  # Append given round to scoreboard
  def add_round(round)
    @scoreboard << round
    self.write_data
  end

  # Remove latest round from scoreboard
  def remove_last_round
    @scoreboard.pop
    self.write_data
  end

  # Add riichi stick declared by player
  # Param: player - string of player's name
  def add_riichi(player)
    @scoreboard.last.add_riichi(player)
  end

  # Print scoreboard header
  # Round       Joshua    Kenta     Thao
  def print_header
    #maxlen = [@players.max_by(&:length).length, 5].max
    printf "%-#{COL_SPACING}s", "Round"
    @players.each do |p|
      printf "%-#{COL_SPACING}s", p
    end
    puts nil
  end

  # Print entire scoreboard
  def print_scoreboard
    self.print_header
    @scoreboard.each do |r|
      r.print_scores
    end
  end

  # Print last round scores
  # Round       Joshua    Kenta     Thao
  # E1B1R2      33400     39800     31800
  def print_last_round
    self.print_header
    @scoreboard.last.print_scores
  end

  # Print 1-line game title
  # game1: 3P (E1B1R1) ~ Joshua, Kenta, Thao ~ 2016-11-05T14:05:00-07:00
  def print_title
    printf "%s: %dP (%s) ~ %s ~ %s", @filename, @mode, @scoreboard.last.name,
      @players.join(", "), @last_updated
  end

end

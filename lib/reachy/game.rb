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

  # Initialize game from given hash
  # Param: db - hash of game data
  def initialize(db)
    self.populate(db)
  end

  # Populate Game object with info from hash
  # Param: db - hash of game data
  def populate(db)
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

  # Return Hash object representing Game object
  def to_h
    hash = self.instance_variables.each_with_object({}) \
      { |var, h| h[var.to_s.delete("@")] = self.instance_variable_get(var) }
    hash["scoreboard"] = []
    @scoreboard.each do |r|
      hash["scoreboard"] << r.to_h
    end
    return hash
  end

  # Read JSON database file and repopulate object
  def read_data
    filepath = File.expand_path("../../../data/" + @filename + ".json", __FILE__)
    file = File.read(filepath)
    db = JSON.parse(file)
    self.populate(db)
  end

  # Write Game object to JSON database file
  def write_data
    @last_updated = DateTime.now
    hash = self.to_h
    filepath = File.expand_path("../../../data/" + @filename + ".json", __FILE__)
    File.open(filepath, "w") do |f|
      f.write(JSON.pretty_generate(hash))
    end
  end

  # TODO: consider changing this function for easier usage
  # Add new round result
  def add_round(type, dealer, winner, loser, hand)
    new_round = @scoreboard.last.clone

    new_round.update_round(type, dealer, winner, loser, hand)

    @scoreboard << new_round
    self.write_data
  end

  # Remove latest round from scoreboard
  def remove_last_round
    if @scoreboard.length > 1
      @scoreboard.pop
      self.write_data
    else
      printf "Error: Current game already in initial state. " \
        "No round deleted.\n"
    end
  end

  # Add riichi stick declared by player
  # Param: player - string of player's name
  # Return: true if successful, else false
  def add_riichi(player)
    if @players.map(&:downcase).include? player
      return @scoreboard.last.add_riichi(player)
    else
      printf "Error: \"%s\" not in current game's players list\n", player
      return false
    end
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
    self.print_title
    (COL_SPACING * (@mode+1)).times { printf "-" }
    puts nil
    self.print_header
    @scoreboard.each do |r|
      r.print_scores
    end
    puts nil
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
    puts nil
  end

  # Print last round sticks
  def print_last_round_sticks
    @scoreboard.last.print_sticks
  end

end

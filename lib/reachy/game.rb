require 'json'
require 'date'
require 'pp'

require_relative 'round'

##############################################
# Scoreboard record class
##############################################
module Reachy
  class Game

    attr_reader   :filename         # Name of JSON file
    attr_reader   :created_at       # Timestamp at creation
    attr_accessor :last_updated     # Timestamp at last updated
    attr_reader   :mode             # Game mode
    attr_reader   :players          # List of player names
    attr_accessor :scoreboard       # List of round records

    # Initialize game from given hash
    # Param: filename - name of json file
    #        ondisk   - whether Game object exists on disk
    #        players  - array of player names associatied with this game
    def initialize(filename, ondisk=true, players=[])
      if ondisk
        # Game object exists on disk. Read it from file.
        self.read_data(filename)
      else
        # Create new Game object with starting values.
        @filename = filename
        @created_at = DateTime.now
        @last_updated = DateTime.now
        @mode = players.length
        @players = players
        self.initialize_scoreboard
        self.write_data
      end
      @plist = @players.map {|x| x.downcase}
    end

    # Populate @scoreboard with starting Round objects
    def initialize_scoreboard
      # Make initial scores e.g. { "joshua" => 35000, "kenta" => 35000, "thao" => 35000 }
      start_score = mode == 3 ? 35000 : 25000
      init_scores = Hash[ @players.map{ |p| [p.downcase, start_score] } ]
      init_round = {"name" => "",
                    "wind" => nil,
                    "number" => 0,
                    "bonus" => 0,
                    "riichi" => 0,
                    "scores" => init_scores}
      @scoreboard = [Round.new(init_round)]
      self.clone_last_round(true)
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
      hash = {}
      self.instance_variables.each do |var|
        hash[var.to_s[1..-1]] = self.instance_variable_get(var)
      end
      hash["scoreboard"] = []
      @scoreboard.each do |r|
        hash["scoreboard"] << r.to_h
      end
      return hash
    end

    # Read JSON database file and repopulate object
    def read_data(filename)
      filepath = File.expand_path("../../../data/" + filename, __FILE__)
      file = File.read(filepath)
      db = JSON.parse(file)
      self.populate(db)
    end

    # Write Game object to JSON database file
    def write_data
      @last_updated = DateTime.now
      hash = self.to_h
      filepath = File.expand_path("../../../data/" + @filename, __FILE__)
      File.open(filepath, "w") do |f|
        f.write(JSON.pretty_generate(hash))
      end
    end

    # Add new round result
    def add_round(type, dealer, winner, loser, hand)
      if not @scoreboard.last.update_round(type, dealer, winner, loser, hand)
        printf "  An error occurred while updating round score.\n" \
               "  Please check your input (winner, hand) and try again.\n\n"
        return
      end
      self.clone_last_round
      self.write_data
    end

    # Clone last round as next round and add to scoreboard
    # Param: to_next  - bool indicating whether to move to next round (optional)
    def clone_last_round(to_next=false)
      new_round = @scoreboard.last.clone
      if (to_next || new_round.name == "") then new_round.next_round end
      new_round.update_name
      @scoreboard << new_round
    end

    # Remove latest round from scoreboard
    def remove_last_round
      if @scoreboard.length > 2
        @scoreboard.pop
        @scoreboard.pop
        self.clone_last_round
        self.write_data
      else
        printf "Error: Current game already in initial state. " \
          "No round deleted.\n"
      end
    end

    # Move data file of this game to trash
    def delete_from_disk
      FileUtils.mv(File.expand_path("../../../data/" + @filename, __FILE__),
                   File.expand_path("../../../data/trash/" + @filename, __FILE__))
    end

    # Validate players input
    # Param: players  - list of players to check
    # Return: true if all players in list are in this game, else false
    def validate_players(players)
      flag = true
      players.each do |p|
        if not @plist.include?(p)
          printf "Error: Player \"%s\" not in current list of players\n", p
          flag = false
        end
      end
      return flag
    end

    # Add riichi stick declared by player
    # Param: player - string of player's name
    # Return: true if successful, else false
    def add_riichi(player)
      if @players.map(&:downcase).include? player
        ret = @scoreboard.last.add_riichi(player)
        if ret then self.write_data end
        return ret
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
      @scoreboard[0..-2].each do |r|     # ignores last round - it's ongoing
        r.print_scores
      end
      # print ongoing round
      @scoreboard.last.print_scores(true)
      puts nil
    end

    # Print last round scores
    # Round       Joshua    Kenta     Thao
    # E1B1R2      33400     39800     31800
    def print_last_round
      self.print_header
      @scoreboard[-2].print_scores
    end

    # Print 1-line game title
    # game1: 3P (E1B1R1) ~ Joshua, Kenta, Thao ~ 2016-11-05T14:05:00-07:00
    def print_title
      printf "%s: %dP (%s) ~ %s ~ %s", @filename, @mode, @scoreboard[-2].name,
        @players.join(", "), @last_updated
      puts nil
    end

    # Print current round sticks
    def print_current_sticks
      @scoreboard.last.print_sticks
    end

  end
end

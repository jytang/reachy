require_relative 'score'

##############################################
# Round record class
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
  def initialize(db)
    @wind = db["wind"]
    @number = db["number"]
    @bonus = db["bonus"]
    @riichi = db["riichi"]
    @name = @wind ? (@wind + @number.to_s) : "0"
    if @bonus > 0 then @name += "B" + @bonus.to_s end
    if @riichi > 0 then @name += "R" + @riichi.to_s end
    @scores = db["scores"]
  end

  # XXX: Need to be verified
  # Return a deep copy of this Round object
  def clone
    return Marshal.load(Marshal.dump(self))
  end

  # Return Hash object representing Round object
  def to_h
    hash = self.instance_variables.each_with_object({}) \
      { |var, h| h[var.to_s.delete("@")] = self.instance_variable_get(var) }
    return hash
  end

  # Add riichi stick declared by player
  # Param: player - string of player's name
  # Return: true if successful, else false
  # Note: - round name should not be changed
  #       - do not write to file here
  def add_riichi(player)
    if @scores[player] >= 1000
      @riichi += 1
      @scores[player] -= 1000
      return true
    else
      puts "Unable to declare riichi: not enough points"
      return false
    end
  end

  # TODO: Update round data from given input
  # Param: type   - round result type (tsumo/ron/tenpai/noten/chombo)
  #        dealer - string of dealer's name
  #        winner - list containing winner's name or players in tenpai
  #        loser  - string of player who dealt into winning hand or chombo
  #        hand   - list of hand value (e.g. ["mangan"], [2,60])
  # Return: true if successful, else false
  # Usage: This round is a clone of previous round, so just update its values
  # Note:
  def update_round(type,dealer,winner,loser,hand)
    # Verify inputs
    if (dealer == nil)
      puts "Error: Missing dealer's name"
      return false
    end
    if (hand.empty? && type != T_CHOMBO && type != T_NOTEN)
      puts "Error: Missing hand value"
      return false
    end

    case type
    # Tsumo type: loser = []
    when T_TSUMO
    # Ron type
    when T_RON
    # Tenpai type: loser = []
    when T_TENPAI
    # Noten type: winner = [], loser = [], hand = []
    when T_NOTEN
    # Chombo type: winner = [], hand = []
    when T_CHOMBO
    # Error case
    else
      printf "Invalid type: %s\n", type
      puts nil
      return false
    end
    return true
  end

  # Print single line round scores
  def print_scores
    printf "%-#{COL_SPACING}s", @name
    @scores.each do |key,val|
      printf "%-#{COL_SPACING}d", val
    end
    puts nil
  end

  # Print bonus and riichi sticks summary
  def print_sticks
    printf "  %-#{COL_SPACING}s: %d\n", "Bonus sticks", @bonus
    printf "  %-#{COL_SPACING}s: %d\n", "Riichi sticks", @riichi
  end

end


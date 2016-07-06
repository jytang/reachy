require_relative 'scoring'

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
    if @scores[player] >= Scoring::P_RIICHI
      @riichi += 1
      @scores[player] -= Scoring::P_RIICHI
      return true
    else
      puts "Unable to declare riichi: not enough points"
      return false
    end
  end

  # Update wind and round number to next round
  # Return: list of [wind, round number] or [] if max West wind reached
  def next_round
    if @number == @mode
      if @wind == "W"
        printf "Already in last possible round (West %d)!\n", @number
        return []
      else
        @wind = (@wind == "E" ? "S" : "W")
        @number = 1
      end
    else
      @number += 1
    end
    return [@wind, @number]
  end

  # Give bonus and riichi points to player
  # Param: winner - string of player's name to award points to
  #        loser  - string of player's name who pays for bonus points
  # Return: true if successful, else false
  def award_bonus(winner,loser)
    if @scores.include?(winner) && @scores.include?(loser)
      @scores[winner] += @bonus*Scoring::P_BONUS
      @scores[loser] -= @bonus*Scoring::P_BONUS
      @bonus = 0
      @scores[winner] += @riichi*Scoring::P_RIICHI
      @riichi = 0
      @name = self.next_round.join
      return true
    else
      printf "Error: \"%s\" and/or \"%s\" not in current list of players\n",
        winner, loser
      return false
    end
  end

  # TODO: Update round data from given input
  # Param: type   - round result type (tsumo/ron/tenpai/noten/chombo)
  #        dealer - string of dealer's name
  #        winner - list containing winner's name or players in tenpai
  #        loser  - string of player who dealt into winning hand or chombo
  #        hand   - list of list of hand values (e.g. [["mangan"], [2,60]])
  # Return: true if successful, else false
  # Usage: This round is a clone of previous round, so just update its values.
  #        Multiple ron winners: - winner and hand lists must match
  #                              - first winner in list gets bonus/riichi points
  def update_round(type,dealer,winner,loser,hand)
    # Verify inputs
    if (dealer == nil)
      puts "Error: Missing dealer's name"
      return false
    end
    if ((hand.empty? || hand.first.empty?) && type!=T_CHOMBO && type!=T_NOTEN)
      puts "Error: Missing hand value"
      return false
    end

    dealer_flag = winner.include?(dealer)

    # Handle each round type
    case type

    when T_TSUMO
      # Tsumo type: loser = []
      if not self.award_bonus(winner.first) then return false end
      # TODO: update individual scores

    when T_RON
      # Ron type
      if not self.award_bonus(winner.first) then return false end
      # TODO: update individual scores - beware of multiples

    when T_TENPAI
      # Tenpai type: loser = []
      if winner.include?(dealer)
        @name = self.next_round.join + @name[2..-1]
        @bonus += 1
        @name[3] = @bonus.to_s
      end
      if winner.length == @mode
        lose_count = 4 - winner.length
        paym = Scoring::P_TENPAI / lose_count
        recv = (Scoring::P_TENPAI * (@mode==4 ? lose_count : lose_count-1)) /
          winner.length
        @scores.each do |k,v|
          if winner.include?(k)
            @scores[k] += recv
          else
            @scores[k] -= paym
          end
        end
      end

    when T_NOTEN
      # Noten type: winner = [], loser = [], hand = []
      @name = self.next_round.join + @name[2..-1]

    when T_CHOMBO
      # Chombo type: winner = [], hand = []
      dealer_flag = loser.include?(dealer)
      score_h = Scoring.get_chombo(dealer_flag)
      @scores.each do |k,v|
        if dealer_flag
          if k != dealer
            @scores[k] += score_h["nondealer"]
          else
            @scores[k] -= score_h["nondealer"]*(@mode-1)
          end
        else
          if loser.include?(k)
            @scores[k] -= (score_h["dealer"] + score_h["nondealer"]*(@mode-2))
          else
            @scores[k] += score_h[k==dealer ? "dealer" : "nondealer"]
          end
        end
      end

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


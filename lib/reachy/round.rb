require_relative 'scoring'

##############################################
# Round record class
##############################################
class Round

  attr_reader   :name           # Name of round (e.g. E1B2R1)
  attr_reader   :mode           # Game mode
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
    @mode = @scores.length
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
    hash.delete("name")
    hash.delete("mode")
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
    if not @wind
      @wind = "E"
      @number = 1
    elsif @number == @mode
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
  #        loser  - list of players who pay for bonus points
  #        dealer - bool indicating whether winner was dealer
  # Return: true if successful, else false
  def award_bonus(winner,loser,dealer)
    if @scores.include?(winner)
      @scores[winner] += @bonus*Scoring::P_BONUS
      share_count = loser.length
      if share_count>1 then share_count += (@mode==3 ? 1 : 0) end
      bonus_paym = (@bonus*Scoring::P_BONUS)/share_count
      loser.each do |l|
        if @scores.include?(l)
          @scores[l] -= bonus_paym
        else
          printf "Error: \"%s\" not in current list of players\n", l
        end
      end
      if not dealer then @bonus = 0 end
      @scores[winner] += @riichi*Scoring::P_RIICHI
      @riichi = 0
      return true
    else
      printf "Error: \"%s\" not in current list of players\n", winner
      return false
    end
  end

  # Update round data from given input
  # Param: type   - round result type (tsumo/ron/tenpai/noten/chombo)
  #        dealer - string of dealer's name
  #        winner - list of winner's name or players in tenpai
  #        loser  - list of players who chombo or did not win
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
    if (hand.empty? || hand.first.empty?) && (type==T_TSUMO || type==T_RON)
      puts "Error: Missing hand value"
      return false
    end

    dealer_flag = winner.include?(dealer)

    # Handle each round type
    case type

    when T_TSUMO
      # Tsumo type: loser = everyone else
      if not self.award_bonus(winner.first,loser,dealer_flag) then return false end
      if dealer_flag
        @bonus += 1
        @name = @wind + @number.to_s + "B" + @bonus.to_s
      else
        @name = self.next_round.join
      end
      # Hand validation: should be taken care of at input
      #if hand.first.instance_of?(String) && not L_HANDS.include?(hand.first)
      #  printf "\"%s\" is not a valid hand value!\n", hand.first
      #  return false
      #end
      score_h = Scoring.get_tsumo(dealer_flag, hand.first)
      @winner.each do |w|
        @scores[w] += if dealer_flag then score_h["nondealer"]*(@mode-1)
                      else (score_h["dealer"]+score_h["nondealer"]*(@mode-2)) end
      end
      @loser.each do |l|
        @scores[l] -= score_h[l==dealer ? "dealer" : "nondealer"]
      end

    when T_RON
      # Ron type - can have multiple winners off of same loser
      if not self.award_bonus(winner.first,loser,dealer_flag) then return false end
      if dealer_flag
        @bonus += 1
        @name[3] = @bonus.to_s
      else
        @name = self.next_round.join + @name[2..-1]
      end
      winner.zip(hand).each do |w,h|
        paym = Scoring.get_ron((w==dealer),h)
        @scores[w] += paym
        @scores[loser.first] -= paym
      end

    when T_TENPAI
      # Tenpai type: loser = noten folks
      if dealer_flag
        @bonus += 1
        @name[3] = @bonus.to_s
      else
        @name = self.next_round.join + @name[2..-1]
      end
      if winner.length == @mode
        lose_count = 4 - winner.length
        paym = Scoring::P_TENPAI / lose_count
        recv = (Scoring::P_TENPAI * (@mode==4 ? lose_count : lose_count-1)) /
          winner.length
        winner.each do |w|
          @scores[w] += recv
        end
        loser.each do |l|
          @scores[l] -= paym
        end
      end

    when T_NOTEN
      # Noten type: ignore all other params
      @name = self.next_round.join + @name[2..-1]

    when T_CHOMBO
      # Chombo type: loser = chombo player, winner = everyone else
      dealer_flag = loser.include?(dealer)
      score_h = Scoring.get_chombo(dealer_flag)
      @scores[loser.first] -= if dealer_flag then score_h["nondealer"]*(@mode-1)
                              else (score_h["dealer"] + score_h["nondealer"]*(@mode-2)) end
      winner.each do |w|
        @scores[w] += score_h[w==dealer ? "dealer" : "nondealer"]
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


require_relative 'scoring'

##############################################
# Round record class
##############################################
module Reachy
  class Round

    attr_reader   :name           # Name of round (e.g. E1B2R1)
    attr_reader   :mode           # Game mode
    attr_reader   :wind           # Round wind
    attr_reader   :number         # Round number
    attr_reader   :bonus          # Current bonus sticks
    attr_accessor :riichi         # Current riichi sticks
    attr_accessor :scores         # Hash of <player's name> => <score>

    # Initialize round
    # Param: round - hash of round data
    # Populate Round object with info from hash
    def initialize(db)
      @name = db["name"]
      @wind = db["wind"]
      @number = db["number"]
      @bonus = db["bonus"]
      @riichi = db["riichi"]
      @scores = db["scores"]
      @mode = @scores.length
    end

    # Return a deep copy of this Round object
    def clone
      return Marshal.load(Marshal.dump(self))
    end

    # Return Hash object representing Round object
    def to_h
      hash = {}
      self.instance_variables.each do |var|
        hash[var.to_s[1..-1]] = self.instance_variable_get(var)
      end
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
        @bonus = 0 if not dealer
        @scores[winner] += @riichi*Scoring::P_RIICHI
        @riichi = 0
        return true
      else
        printf "Error: \"%s\" not in current list of players\n", winner
        return false
      end
    end

    # Update round name
    def update_name
      @name = @wind ? (@wind + @number.to_s) : ""
      @name += "B" + @bonus.to_s if @bonus > 0
      @name += "R" + @riichi.to_s if @riichi > 0
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
        losers = @scores.keys
        losers -= winner
        return false if not self.award_bonus(winner.first,losers,dealer_flag)
        if dealer_flag then @bonus += 1 else self.next_round end
        score_h = Scoring.get_tsumo(dealer_flag, hand.first)
        winner.each do |w|
          @scores[w] += if dealer_flag then score_h["nondealer"]*(@mode-1)
                        else (score_h["dealer"]+score_h["nondealer"]*(@mode-2)) end
        end
        losers.each do |l|
          @scores[l] -= score_h[l==dealer ? "dealer" : "nondealer"]
        end

      when T_RON
        # Ron type - can have multiple winners off of same loser
        return false if not self.award_bonus(winner.first,loser,dealer_flag)
        if dealer_flag then @bonus += 1 else self.next_round end
        winner.zip(hand).each do |w,h|
          paym = Scoring.get_ron((w==dealer),h)
          @scores[w] += paym
          @scores[loser.first] -= paym
        end

      when T_TENPAI
        # Tenpai type: losers = all - winners
        losers = @scores.keys
        losers -= winner
        if winner.length < @mode
          if dealer_flag then @bonus += 1 else self.next_round end
          total = @mode==4 ? Scoring::P_TENPAI_4 : Scoring::P_TENPAI_3
          paym = total / losers.length
          recv = total / winner.length
          winner.each do |w|
            @scores[w] += recv
          end
          losers.each do |l|
            @scores[l] -= paym
          end
        end

      when T_NOTEN
        # Noten type: ignore all other params
        self.next_round

      when T_CHOMBO
        # Chombo type: loser = chombo player, winner = everyone else
        winners = @scores.keys
        winners -= loser
        dealer_flag = loser.include?(dealer)
        score_h = Scoring.get_chombo(dealer_flag)
        @scores[loser.first] -= if dealer_flag then score_h["nondealer"]*(@mode-1)
                                else (score_h["dealer"] + score_h["nondealer"]*(@mode-2)) end
        winners.each do |w|
          @scores[w] += score_h[w==dealer ? "dealer" : "nondealer"]
        end

      else
        printf "Invalid round result type\n", type
        puts nil
        return false
      end

      return true
    end

    # Print single line round scores
    def print_scores(ongoing=false)
      round_name = @name
      round_name += "*" if ongoing
      printf "%-#{COL_SPACING}s", round_name
      @scores.each do |key,val|
        printf "%-#{COL_SPACING}d", val
      end
      puts nil
    end

    # Print bonus and riichi sticks summary
    def print_sticks
      printf "  %-#{COL_SPACING}s: %d\n", "Bonus sticks", @bonus
      printf "  %-#{COL_SPACING}s: %d\n", "Riichi sticks", @riichi
      puts nil
    end

  end
end

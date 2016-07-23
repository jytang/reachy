require_relative 'game'
require_relative 'round'
require_relative 'util'

##############################################
# Game menu and specific game interactions
##############################################
module Reachy

  # Game menu for a particular game
  def self.game_menu
    loop do
      game = @games[@selected_game_index]
      puts "(Enter \"x\" to go back to main menu.)\n"
      puts nil
      printf "*** Game \"%s\" Options:\n" \
        "  1) Add next round result\n" \
        "  2) Declare riichi\n" \
        "  3) View current scoreboard\n" \
        "  4) Remove last round entry\n" \
        "  5) Delete current game\n" \
        "  6) Choose a different game\n" \
        "  7) Add new game\n", game.filename
      choice = prompt_ch "---> Enter your choice: "
      puts nil
      case choice
      when "x"
        puts nil
        return # to main menu
      when "1"
        puts "\n[Add next round result]"
        puts nil
        add_round(game)
      when "2"
        puts "\n[Declare riichi]"
        puts nil
        declare_riichi(game)
      when "3"
        puts "\n[View current scoreboard]"
        puts nil
        game.print_scoreboard
        puts "(Press any key to continue)"
        STDIN.getch
      when "4"
        puts "\n[Remove last round entry]"
        puts nil
        remove_last_round(game)
      when "5"
        puts "\n[Delete current game]"
        puts nil
        return if confirm_delete(game) # main menu if current game deleted
      when "6"
        puts "\n[Choose a different game]"
        puts nil
        view_game
      when "7"
        puts "\n[Add new game]"
        puts nil
        add_game
      when ""
        puts "\nEnter a choice... >_>"
        puts nil
      else
        printf "\nInvalid choice: %s\n", choice
        puts nil
      end
    end
  end

  # Add a new round to the current game. Sub menu option 1.
  def self.add_round(game)
    puts "(Enter \"x\" to return to game options.)"
    puts nil
    dealer = prompt "---> Dealer's name: "
    return if dealer == "x"
    puts nil

    loop do
      printf "*** Round result type:\n" \
        "  1) Tsumo\n" \
        "  2) Ron\n" \
        "  3) Tenpai\n" \
        "  4) Noten\n" \
        "  5) Chombo\n" \
        "  6) Round reset\n"
      choice = prompt "---> Select round result: "
      case choice
      when "x"
        puts nil
        return
      when "1"
        # Tsumo
        type = T_TSUMO
        winner = prompt "---> Winner's name: "
        return if winner == "x"
        winner = winner.split
        if winner.length > 1
          puts "  Assuming \"%s\" is the winner, ignoring remaining players.",
            winner.first
          winner = [winner.first]
        end
        next if not game.validate_players(winner)

        hand = prompt "---> Hand value (e.g. \"2 30\" or \"mangan\"): "
        return if hand == "x"
        hand = validate_hand(hand)

        loser = []  # Round::update_round will set loser = all - winner
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "2"
        # Ron
        type = T_RON
        puts nil
        winner = prompt "---> Winner(s) (first winner gets bonus and riichi sticks): "
        return if winner == "x"
        winner = winner.split
        next if not game.validate_players(winner)

        hand = prompt "---> Hand value(s) (e.g. \"2 30 yakuman\" or \"mangan\"): "
        puts nil
        return if hand == "x"
        hand = validate_hand(hand)
        if hand.length != winner.length
          printf "The number of winners and winning hands do not match. " \
                 "Please try again.\n\n"
        end

        loser = prompt "---> Player who dealt into winning hand(s): "
        return if loser == "x"
        loser = loser.split
        if loser.length > 1
          puts "  Assuming \"%s\" is the player who dealt into winning hand.",
            loser.first
          loser = [loser.first]
        end
        next if not game.validate_players(loser)
        if winner.include? loser.first
          puts "Loser can't be a winner..."
          next
        end

        game.add_round(type, dealer, winner, loser, hand)
        break
      when "3"
        # Tenpai
        type = T_TENPAI
        winner = prompt "---> Player(s) in tenpai (separated by space): "
        return if winner == "x"
        winner = winner.split
        next if not game.validate_players(winner)

        loser = []  # Round::update_round will set losers = all - winners
        hand = []
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "4"
        # Noten
        type = T_NOTEN
        winner = []
        loser = []
        hand = []
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "5"
        # Chombo
        type = T_CHOMBO
        loser = prompt "---> Player who chombo'd: "
        return if loser == "x"
        loser = loser.split
        if loser.length > 1
          puts "  Assuming \"%s\" is the player who dealt into winning hand.",
            loser.first
          loser = [loser.first]
        end
        next if not game.validate_players(loser)

        winner = [] # Round::update_round will set winners = all - loser
        hand = []
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "6"
        # Round reset
        type = T_RESET
        winner = []
        loser = []
        hand = []
        game.add_round(type, dealer, winner, loser, hand)
        puts "*** Round reset."
        puts nil
        break
      when ""
        puts "Enter a choice... >_>"
        puts nil
      else
        printf "Invalid choice: %s\n", choice
        puts nil
      end
    end

    puts "*** Game scoreboard updated."
    puts nil
    game.print_scoreboard
  end

  # Update riichi sticks. Sub menu option 2.
  def self.declare_riichi(game)
    puts "(Enter \"x\" to return to game options.)"
    puts nil
    player = prompt "---> Player(s) who declared riichi: "
    player = player.split
    return if not game.validate_players(player)

    player.each do |p|
      if game.add_riichi(p)
        printf "\n*** Riichi stick added by %s.\n", p
        game.print_current_sticks
      end
    end
  end

  # Remove last round from scoreboard. Sub menu option 3.
  def self.remove_last_round(game)
    printf "---> Removing last round entry:\n"
    game.print_last_round
    conf = prompt "  Are you sure? (y/N) "
    if conf == "y"
      game.remove_last_round
      puts nil
      puts "*** Game scoreboard updated."
      puts nil
      game.print_scoreboard
      return true
    else
      puts "You changed your mind? Fine.\n\n"
      return false
    end
  end
end

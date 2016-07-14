require_relative 'game'
require_relative 'round'
require_relative 'util'
require_relative 'game_menu'

##############################################
# Main menu and top level interactions
##############################################
module Reachy

  # Main menu
  def self.main_menu
    loop do
      puts "*** Main menu:\n" \
        "  1) View or update existing game scoreboard\n" \
        "  2) Add new game\n" \
        "  3) Delete existing game\n" \
        "  4) Display all scoreboards"
      choice = prompt_ch "---> Enter your choice: "
      case choice
      when "1"
        puts "\n[View or update existing game scoreboard]"
        puts nil
        game_menu if view_game
      when "2"
        puts "\n[Add new game]"
        puts nil
        game_menu if add_game
      when "3"
        puts "\n[Delete existing game]"
        puts nil
        delete_game
      when "4"
        puts "\n[Display all scoreboards]"
        puts nil
        display_all_scoreboards
      when ""
        puts "\nEnter a choice... >_>"
        puts nil
      else
        printf "\nInvalid choice: %s\n", choice
        puts nil
      end
    end
  end

  # View/update an existing game. Main menu option 1.
  def self.view_game
    loop do
      puts "(Enter \"x\" to go back to main menu.)"
      puts nil
      puts "*** Choose existing game:"
      return if not display_all_games

      choice = prompt "---> Enter your choice: "
      case choice
      when "x"
        puts nil
        return false # to main menu
      when ""
        puts "Enter a choice... >_>"
        puts nil
      else
        # Check that choice consists only of digits and within @games bounds
        if /\A\d+\z/.match(choice) and choice.to_i <= @games.length and choice.to_i > 0
          # Print scoreboard for this game
          @games[choice.to_i - 1].print_scoreboard
          @selected_game_index = choice.to_i - 1
          return true # to main menu
        else
          printf "Invalid choice: %s\n", choice
          puts nil
        end
      end
    end
  end

  # Add a game. Main menu option 2.
  def self.add_game
    puts "(Enter \"x\" to go back to previous menu.)"
    puts nil

    # Ask for unique game name.
    unique = false
    until unique do
      name = prompt "---> Game name: "
      return false if name == "x"
      unique = true
      @games.each do |game|
        if game.filename == name
          unique = false
          printf "Already exists a game of name: %s!\n", name
          break
        end
      end
    end

    # Ask for number of players
    good = false
    until good do
      nump = prompt "---> Number of players (3 or 4): "
      return false if nump == "x"
      nump = nump.to_i
      if nump == 3 or nump == 4
        good = true
      else
        puts "Invalid number of players"
      end
    end

    # Ask for unique player handles
    good = false
    until good do
      players = prompt "---> Player names (separated by spaces, in ESWN order): "
      return false if nump == "x"
      players = players.split
      if players.length == nump and players.uniq.length == players.length
        good = true
      else
        printf "Must input %d unique player handles\n", nump
      end
    end

    newgame = Game.new(name, false, players)

    # Add to @games array and go to its menu.
    @games << newgame
    puts "\n*** New game created! Scoreboard:"
    puts nil
    newgame.print_scoreboard
    @selected_game_index = @games.length - 1 # last entry is the new game
    return true
  end

  # Delete a game. Main menu option 3.
  def self.delete_game
    loop do
      puts "(Enter \"x\" to go back to main menu.)"
      puts nil
      puts "*** Choose existing game to delete:"
      return if not display_all_games
      choice = prompt "---> Enter your choice: "
      case choice
      when "x"
        return # to main menu
      when ""
        puts "\nEnter a choice... >_>"
      else
        # Check that choice consists only of digits and within @games bounds
        if /\A\d+\z/.match(choice) and choice.to_i <= @games.length and choice.to_i > 0
          # Ask for confirmation
          chosen_game = @games[choice.to_i - 1]
          puts nil
          confirm_delete(chosen_game)
          return # to main menu
        else
          printf "Invalid choice: %s\n", choice
          puts nil
        end
      end
    end
  end

  # Display all scoreboards. Main menu option 4.
  def self.display_all_scoreboards
    @games.each do |game|
      game.print_scoreboard
    end
  end

end

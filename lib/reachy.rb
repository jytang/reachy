#!/usr/bin/ruby

require 'rubygems'
require 'date'
require 'fileutils'
require 'io/console'

require_relative 'reachy/game'
require_relative 'reachy/util'

##############################################
# Main driver functionality
##############################################
module Reachy

  # Display initial screen (complete with banner, list of games)
  def self.start_screen
    # Display banner
    File.open(File.expand_path("../banner", __FILE__), "r"){ |file| puts file.read }
    puts nil

    # Display all games in db
    read_all_games
    puts "*** Current existing game(s) in database:"
    display_all_games
    puts nil

    # Display main menu options
    main_menu
  end

  # Main menu
  def self.main_menu
    loop do
      puts "*** Main menu:\n" \
        "  1) View or update existing game scoreboard\n" \
        "  2) Add new game\n" \
        "  3) Delete existing game\n" \
        "  4) Display all scoreboards"
      choice = prompt "---> Enter your choice: "
      case choice
      when "1"
        puts "\n[View or update existing game scoreboard]"
        puts nil
        if view_game
          game_menu
        end
      when "2"
        puts "\n[Add new game]"
        puts nil
        if add_game
          game_menu
        end
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
      display_all_games

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
      if name == "x"
        puts nil
        return false
      end # previous menu
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
      if nump == "x"
        puts nil
        return false
      end # previous menu
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
      players = prompt "---> Player names (separated by spaces): "
      if nump == "x"
        puts nil
        return false
      end # previous menu
      players = players.split
      if players.length == nump and players.uniq.length == players.length
        good = true
      else
        printf "Must input %d unique player handles\n", nump
      end
    end

    # Make initial scoreboard e.g. { "joshua" => 35000, "kenta" => 35000, "thao" => 35000 }
    start_score = nump == 3 ? 35000 : 25000
    init_scoreboard = Hash[ *players.collect { |p| [p.downcase, start_score] }.flatten]
    # Make new game object (TODO: do less hard coding)
    init_round = {"wind" => nil,
                  "number" => 0,
                  "bonus" => 0,
                  "riichi" => 0,
                  "scores" => init_scoreboard}
    now_stamp = DateTime.now.to_s
    game_hash = {"filename" => name,
                 "created_at" => now_stamp,
                 "last_updated" => now_stamp,
                 "mode" => nump,
                 "players" => players,
                 "scoreboard" => [init_round]}
    newgame = Game.new(game_hash)
    newgame.write_data

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
      display_all_games
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

  def self.confirm_delete(chosen_game)
    printf "---> Deleting game \"%s\". This action cannot be undone.\n", chosen_game.filename
    conf = prompt "  Are you sure? (y/N) "
    if conf == "y"
      # Move associated json file to trash.
      filename = chosen_game.filename + ".json"
      FileUtils.mv(File.expand_path("../../data/" + filename, __FILE__),
                   File.expand_path("../../data/trash/" + filename, __FILE__))

      # Delete from @games array
      @games.delete(chosen_game)
      printf "*** Game \"%s\" deleted from database.\n\n", chosen_game.filename
      return true
    else
      puts "You changed your mind? Fine.\n\n"
      return false
    end
  end

  # Display all scoreboards. Main menu option 4.
  def self.display_all_scoreboards
    @games.each do |game|
      game.print_scoreboard
    end
  end

  # Game menu for a particular game
  # TODO: support EOF in sub-menu
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
      choice = prompt "---> Enter your choice: "
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
        puts "\n(Press any key to continue)"
        STDIN.getch
      when "4"
        puts "\n[Remove last round entry]"
        puts nil
        remove_last_round(game)
      when "5"
        puts "\n[Delete current game]"
        puts nil
        if confirm_delete(game) then return end # main menu if current game deleted
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

  # Validate hand input
  # Param: hand - string of hand value input
  # Return: reformated hand value or empty list if input invalid
  def self.validate_hand(hand)
    split_hand = hand.split
    hand = []
    i = 0
    flag = true
    while i < split_hand.length   # Did this C-style AKA imperatively.. how to ruby
      if split_hand[i].match(/^\d+$/)
        if split_hand[i+1].match(/^\d+$/)
          hand << [split_hand[i].to_i, split_hand[i+1].to_i]
          i += 2
        else
          flag = false
          hand = []
          break
        end
      elsif L_HANDS.include?(split_hand[i])
        hand << [split_hand[i]]
        i += 1
      else
        flag = false
        hand = []
        break
      end
    end
    if not flag
      printf "Hand value malformed: \"%s\"\n", hand
    end
    return hand
  end

  # Add a new round to the current game. Sub menu option 1.
  def self.add_round(game)
    puts "(Enter \"x\" to return to game options.)"
    puts nil
    dealer = prompt "---> Dealer's name: "
    if dealer == "x" then return end
    puts nil

    loop do
      printf "*** Round result type:\n" \
        "  1) Tsumo\n" \
        "  2) Ron\n" \
        "  3) Tenpai\n" \
        "  4) Noten\n" \
        "  5) Chombo\n"
      choice = prompt "---> Select round result: "
      case choice
      when "x"
        puts nil
        return
      when "1"
        # Tsumo
        type = T_TSUMO
        winner = prompt "---> Winner's name: "
        if winner == "x" then return end
        winner = [winner]
        hand = prompt "---> Hand value(s) (e.g. \"2 30\" or \"mangan\"): "
        if hand == "x" then return end
        hand = validate_hand(hand)
        loser = []  # Round::update_round will set loser = all - winner
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "2"
        # Ron
        type = T_RON
        puts nil
        winner = prompt "---> Winner(s): "
        if winner == "x" then return end
        winner = winner.split
        loser = prompt "---> Player who dealt into winning hand(s): "
        if loser == "x" then return end
        loser = [loser]
        # TODO: check that loser isn't a winner.
        hand = prompt "---> Hand value(s) (e.g. \"2 30\" or \"mangan\"): "
        puts nil
        if hand == "x" then return end
        hand = validate_hand(hand)
        game.add_round(type, dealer, winner, loser, hand)
        break
      when "3"
        # Tenpai
        type = T_TENPAI
        winner = prompt "---> Player(s) in tenpai (separated by space): "
        if winner == "x" then return end
        winner = winner.split
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
        if loser == "x" then return end
        loser = [loser]
        winner = [] # Round::update_round will set winners = all - loser
        hand = []
        game.add_round(type, dealer, winner, loser, hand)
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
  # TODO: EOF support here
  # Known bug: changes score of LAST round as well.
  # Proposed solution: add Round object for the current round before it is finished.
  #   i.e. game init should create two rounds "0" and "E1"
  #   then declare_riichi, add_round would simply update E1
  #   add_round would afterwards clone the round and append to scoreboard (as the NEXT round)
  def self.declare_riichi(game)
    puts "(Enter \"x\" to return to game options.)"
    puts nil
    player = prompt "---> Player who declared riichi: "
    if player == "x" then return end

    if game.add_riichi(player)
      printf "\n*** Riichi stick added by %s.\n", player
      game.print_last_round_sticks
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

  # Read all games in data dir, and store in @games array
  def self.read_all_games
    @games = []
    Dir.foreach(File.expand_path("../../data/", __FILE__)) do |filename|
      # Skip . and .. dir entries, and trash dir
      next if filename == '.' or filename == '..' or filename == "trash"

      # Create game objects
      file = File.read(File.expand_path("../../data/" + filename, __FILE__))
      db = JSON.parse(file)
      game = Game.new(db)
      @games << game
    end
  end

  # Print out all games in database
  def self.display_all_games
    @games.each_with_index do |game, index|
      printf "  %d) ", index + 1
      game.print_title
    end
  end
end

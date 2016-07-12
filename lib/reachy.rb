#!/usr/bin/ruby

require 'rubygems'
require 'date'
require 'fileutils'
require 'io/console'

require_relative 'reachy/game'

##############################################
# Main driver functionality
##############################################
module Reachy

  class << self

    # Display initial screen (complete with banner, list of games)
    def start_screen
      # Display banner
      File.open(File.expand_path("../banner", __FILE__), "r"){ |file| puts file.read }
      puts nil

      # Display all games in db
      self.read_all_games
      puts "*** Current existing game(s) in database:"
      self.display_all_games
      puts nil

      # Display main menu options
      self.main_menu
    end

    # Main menu
    def main_menu
      loop do
        puts "*** Main menu:\n" \
             "  1) View or update existing game scoreboard\n" \
             "  2) Add new game\n" \
             "  3) Delete existing game\n" \
             "  4) Display all scoreboards"
        print "---> Enter your choice: "
        choice = gets.strip
        case choice
        when "1"
          puts nil
          puts "View or update existing game scoreboard"
          self.view_game
          self.game_menu
        when "2"
          puts nil
          puts "Add new game"
          self.add_game
          self.game_menu
        when "3"
          puts nil
          puts "Delete existing game"
          self.delete_game
        when "4"
          puts nil
          puts "Display all scoreboards"
          self.display_all_scoreboards
        when ""
          puts "Enter a choice... >_>"
          puts nil
        else
          printf "Invalid choice: %s\n", choice
          puts nil
        end
      end
    end

    # View/update an existing game. Main menu option 1.
    def view_game
      loop do
        puts "(Enter \"x\" to go back to main menu.)"
        puts nil
        puts "*** Choose existing game:"
        self.display_all_games
        print "---> Enter your choice: "
        choice = gets.strip
        case choice
        when "x"
          return # to main menu
        when ""
          puts "Enter a choice... >_>"
          puts nil
        else
          # Check that choice consists only of digits and within @games bounds
          if /\A\d+\z/.match(choice) and choice.to_i <= @games.length and choice.to_i > 0
            # Print scoreboard for this game
            puts nil
            @games[choice.to_i - 1].print_scoreboard
            puts nil
            @selected_game_index = choice.to_i - 1
            return # to main menu
          else
            printf "Invalid choice: %s\n", choice
            puts nil
          end
        end
      end
    end

    # Add a game. Main menu option 2.
    def add_game
      puts "(Enter \"x\" to go back to main menu.)"
      puts nil

      # Ask for unique game name.
      unique = false
      until unique do
        print "---> Game name: "
        name = gets.strip
        if name == "x" then return end # main menu
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
        print "---> Number of players (3 or 4): "
        nump = gets.strip
        if nump == "x" then return end # main menu
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
        print "---> Player names (separated by spaces): "
        players = gets.strip
        if players == "x" then return end # main menu
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
      init_round = {"wind" => nil, "number" => 0, "bonus" => 0, "riichi" => 0, "scores" => init_scoreboard}
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
      puts "*** New game created! Scoreboard: "
      newgame.print_scoreboard
      @selected_game_index = @games.length - 1 # last entry is the new game
    end

    # Delete a game. Main menu option 3.
    def delete_game
      loop do
        puts "(Enter \"x\" to go back to main menu.)"
        puts nil
        puts "*** Choose existing game to delete:"
        self.display_all_games
        print "---> Enter your choice: "
        choice = gets.strip
        case choice
        when "x"
          return # to main menu
        when ""
          puts "Enter a choice... >_>"
          puts nil
        else
          # Check that choice consists only of digits and within @games bounds
          if /\A\d+\z/.match(choice) and choice.to_i <= @games.length and choice.to_i > 0
            # Ask for confirmation
            chosen_game = @games[choice.to_i - 1]
            puts nil
            self.confirm_delete(chosen_game)
            return # to main menu
          else
            printf "Invalid choice: %s\n", choice
            puts nil
          end
        end
      end
    end

    def confirm_delete(chosen_game)
      puts nil
      printf "---> Deleting game \"%s\". This action cannot be undone.\n", chosen_game.filename
      print "  Are you sure? (y/N) "
      conf = gets.strip.downcase
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
    def display_all_scoreboards
      @games.each do |game|
        game.print_scoreboard
        puts nil
      end
    end

    # Game menu for a particular game
    # TODO: support EOF in sub-menu
    def game_menu
      loop do
        game = @games[@selected_game_index]
        puts "(Enter \"x\" to go back to main menu.)"
        puts nil
        printf "*** Game \"%s\" Options:\n" \
             "  1) Add next round result\n" \
             "  2) Declare riichi\n" \
             "  3) View current scoreboard\n" \
             "  4) Remove last round entry\n" \
             "  5) Delete current game\n" \
             "  6) Choose a different game\n" \
             "  7) Add new game\n", game.filename
        print "---> Enter your choice: "
        choice = gets.strip
        case choice
        when "x"
          return # to main menu
        when "1"
          puts "\nAdd next round result"
          self.add_round(game)
        when "2"
          puts "\nDeclare riichi"
          self.declare_riichi(game)
        when "3"
          puts "\nView current scoreboard"
          game.print_scoreboard
          puts "\n(Press any key to continue)"
          STDIN.getch
        when "4"
          puts "\nRemove last round entry"
          self.remove_last_round(game)
        when "5"
          puts "\nDelete current game"
          if self.confirm_delete(game) then return end # main menu if current game deleted
        when "6"
          puts "\nChoose a different game"
          self.view_game
        when "7"
          puts "\nAdd new game"
          self.add_game
        when ""
          puts "Enter a choice... >_>"
          puts nil
        else
          printf "Invalid choice: %s\n", choice
          puts nil
        end
      end
    end

    # Add a new round to the current game. Sub menu option 1.
    def add_round(game)
        puts "(Enter \"x\" to return to game options.)"
        puts nil
        print "---> Dealer's name: "
        dealer = gets.strip.downcase
        if dealer == "x" then return end

        loop do
          printf "*** Round result type:\n" \
                 "  1) Tsumo\n" \
                 "  2) Ron\n" \
                 "  3) Tenpai\n" \
                 "  4) Noten\n" \
                 "  5) Chombo\n"
          print "---> Select round result: "
          choice = gets.strip
          case choice
          when "x"
            return
          when "1"
            # Tsumo
            type = T_TSUMO
            print "---> Winner's name: "
            winner = gets.strip.downcase
            if winner == "x" then next end
            winner = [winner]
            puts nil
            puts nil
            print "---> Hand value(s) (e.g. \"2 30\" or \"mangan\"): "
            hand = gets.strip
            if hand == "x" then next end
            # Only convert to integer if it is a number (^\d+$)
            # Result: [ [2, 30] ] or [ ["mangan"] ]
            hand = [hand.split.map{|num| num.to_i if num.match(/^\d+$/)}]
            loser = []  # Round::update_round will set loser = all - winner
            game.add_round(type, dealer, winner, loser, hand)
            break
          when "2"
            # Ron
            type = T_RON
            print "---> Winner(s): "
            winner = gets.strip.downcase
            if winner == "x" then next end
            winner = winner.split
            puts nil
            print "---> Player who dealt into winning hand(s): "
            loser = gets.strip.downcase
            if loser == "x" then next end
            loser = [loser]
            puts nil
            print "---> Hand value(s) (e.g. \"2 30\" or \"mangan\"): "
            hand = gets.strip
            if hand == "x" then next end

            # Two consecutive numbers constitute a hand, otherwise a named hand
            split_hand = hand.split
            hand = []
            i = 0
            while i < split_hand.length   # Did this C-style AKA imperatively.. how to ruby
              if split_hand[i].match(/^\d+$/)
                hand << [split_hand[i], split_hand[i+1]]
                i += 2
              else
                hand << [split_hand[i]]
                i += 1
              end
            end
            game.add_round(type, dealer, winner, loser, hand)
            break
          when "3"
            # Tenpai
            type = T_TENPAI
            print "---> Player(s) in tenpai (separated by space): "
            winner = gets.strip.downcase
            if winner == "x" then next end
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
            print "---> Player who chombo'd: "
            loser = gets.strip.downcase
            if loser == "x" then next end
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
        game.print_scoreboard
    end

    # Update riichi sticks. Sub menu option 2.
    # TODO: EOF support here
    # Known bug: changes score of LAST round as well.
    # Proposed solution: add Round object for the current round before it is finished.
    #   i.e. game init should create two rounds "0" and "E1"
    #   then declare_riichi, add_round would simply update E1
    #   add_round would afterwards clone the round and append to scoreboard (as the NEXT round)
    def declare_riichi(game)
      puts "(Enter \"x\" to return to game options.)"
      puts nil
      print "Player who declared riichi: "
      player = gets.strip.downcase
      if player == "x" then return end

      if game.add_riichi(player)
        printf "\n*** Riichi stick added for %s.\n", player
        game.print_last_round_sticks
      end
    end

    # Remove last round from scoreboard. Sub menu option 3.
    def remove_last_round(game)
      puts nil
      printf "---> Removing last round entry:\n"
      game.print_last_round
      print "  Are you sure? (y/N) "
      conf = gets.strip.downcase
      if conf == "y"
        game.remove_last_round
        printf "*** Game scoreboard updated."
        game.print_scoreboard
        return true
      else
        puts "You changed your mind? Fine.\n\n"
        return false
      end
    end

    # Read all games in data dir, and store in @games array
    def read_all_games
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
    def display_all_games
      @games.each_with_index do |game, index|
        printf "  %d) ", index + 1
        game.print_title
      end
    end

  end
end

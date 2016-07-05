#!/usr/bin/ruby

require 'rubygems'
require 'date'
require 'fileutils'

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
        when "2"
          puts nil
          puts "Add new game"
          self.add_game
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
            self.game_menu(choice.to_i - 1)
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

      # Make initial scoreboard e.g. { "Joshua" => 35000, "Kenta" => 35000, "Thao" => 35000 }
      start_score = nump == 3 ? 35000 : 25000
      init_scoreboard = Hash[ *players.collect { |p| [p, start_score] }.flatten]
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
      self.game_menu(@games.length - 1) # last entry is the new game
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
              printf "*** Game \"%s\" deleted from database.", chosen_game.filename
            else
              puts "You changed your mind? Fine."
            end
            puts nil
            return # to main menu
          else
            printf "Invalid choice: %s\n", choice
            puts nil
          end
        end
      end
    end

    # Display all scoreboards. Main menu option 4.
    def display_all_scoreboards
      @games.each do |game|
        game.print_scoreboard
        puts nil
      end
    end

    # TODO: Game menu for a particular game (i.e. SUB)
    def game_menu(index)
      printf "TODO: THE GAME MENU (SUB) FOR THE GAME: "
      @games[index].print_title
      puts nil
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

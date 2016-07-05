#!/usr/bin/ruby

require 'rubygems'

require_relative 'reachy/game'
require_relative 'reachy/round'

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
      puts "*** Main menu:\n" \
           "  1) View or update existing game scoreboard\n" \
           "  2) Add new game\n" \
           "  3) Delete existing game\n" \
           "  4) Display all scoreboards"
      loop do
        print "---> Enter your choice: "
        choice = gets.strip
        case choice
        when "1"
          puts "View or update existing game scoreboard"
          break
        when "2"
          puts "Add new game"
          break
        when "3"
          puts "Delete existing game"
          break
        when "4"
          puts "Display all scoreboards"
          break
        else
          printf "Invalid choice: %s\n", choice
        end
      end
    end

    # Game menu for a particular game
    def game_menu(index)
      puts "game menu"
    end

    # Read all games in data dir, and store in @games array
    def read_all_games
      @games = []
      Dir.foreach(File.expand_path("../../data/", __FILE__)) do |filename|
        # Skip . and .. dir entries
        next if filename == '.' or filename == '..'

        # Create game objects
        # TODO: Use read_data here when it's fixed.
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

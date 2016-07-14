#!/usr/bin/ruby

require 'rubygems'
require 'date'
require 'fileutils'
require 'io/console'

require_relative 'reachy/game'
require_relative 'reachy/util'
require_relative 'reachy/main_menu'

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
    if display_all_games then puts nil end

    # Display main menu options
    main_menu
  end

end

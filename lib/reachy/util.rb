require 'io/console'

require_relative 'defines'

##############################################
# Reachy utilities
##############################################
module Reachy

  # Prompt for user input with a message.
  # If EOF is entered, aborts program.
  # Param: message - string to display
  #        downcase - whether to downcase input
  # Return: User input
  # Note: always strips input!
  def self.prompt(message, downcase=true)
    print message
    input = gets
    goodbye if !input
    if downcase
      return input.strip.downcase
    else
      return input.strip
    end
  end

  # Prompt for one character, downcased.
  # If EOF is entered, aborts program.
  # Param: message - string to display
  # Return: User input character, downcased
  def self.prompt_ch(message)
    print message
    input = STDIN.getch
    goodbye if input == SIGINT_CH || input == EOF_CH
    print input
    return input.downcase
  end

  # Read all games in data dir, and store in @games array
  def self.read_all_games
    @games = []
    Dir.foreach(DATA_PATH) do |filename|
      # Skip . and .. dir entries, and trash dir
      next if filename == '.' or filename == '..' or filename == "trash"

      # Create game objects
      game = Game.new(filename)
      @games << game
    end
  end

  # Print out all games in database
  def self.display_all_games
    if @games.empty?
      puts "  No game currently in database. Please add a new game."
      puts nil
      return false
    end
    @games.each_with_index do |game, index|
      printf "  %d) ", index + 1
      game.print_title
    end
    return true
  end

  # Confirm game deletion
  def self.confirm_delete(chosen_game)
    printf "---> Deleting game \"%s\". This action cannot be undone.\n", chosen_game.filename
    conf = prompt "  Are you sure? (y/N) "
    if conf == "y"
      # Move associated json file to trash.
      chosen_game.delete_from_disk
      # Delete from @games array
      @games.delete(chosen_game)
      printf "*** Game \"%s\" deleted from database.\n\n", chosen_game.filename
      return true
    else
      puts "You changed your mind? Fine.\n\n"
      return false
    end
  end

  # Ensure that the data and data/trash directory exist, if not create them
  def self.ensure_data_dir
    if not File.directory?(ROOT_PATH)
      Dir.mkdir ROOT_PATH
    end
    if not File.directory?(DATA_PATH)
      Dir.mkdir DATA_PATH
    end
    if not File.directory?(TRASH_PATH)
      Dir.mkdir TRASH_PATH
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
        han = split_hand[i]
        fu = split_hand[i+1]
        if fu.match(/^\d+$/) && (fu.to_i==25 || fu.to_i%10 == 0)
          hand << [han.to_i, fu.to_i]
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

  # Display winners of every game
  def self.display_all_winners
    puts " Current winners:"
    puts " ----------------"
    @games.each do |game|
      high_score = game.scoreboard.last.scores.values.max
      winners = game.scoreboard.last.scores.select{ |player, score| score == high_score}
      printf "  * %s: %s - %d points\n", game.filename, winners.keys.join(", "), high_score
    end
    puts nil
  end

  # Call system cowsay if available
  def self.cowsay
    system("cowsay Bye!") if system("which cowsay >/dev/null 2>&1")
  end

  # Message to print when quitting program
  def self.goodbye
    puts "\n\n"
    printf "  -------------------------------\n" \
      "  |  Thanks for flying reachy!  |\n" \
      "  -------------------------------\n\n"
    display_all_winners
    cowsay
    exit 0
  end

end

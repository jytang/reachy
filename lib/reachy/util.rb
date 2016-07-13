module Reachy

  # Prompt for user input with a message.
  # If EOF is entered, aborts program.
  # Param: message - string to display
  # Return: User input
  # Note: strips and downcases input!
  def self.prompt(message)
    print message
    input = gets
    goodbye if !input
    return input.strip.downcase
  end

  # Display winners of every game
  def self.display_all_winners
    puts " Current winners:"
    puts " ----------------"
    @games.each do |game|
      winner, winner_score = game.scoreboard.last.scores.max_by{ |player, score| score}
      printf "  * %s: %s - %d points\n", game.filename, winner, winner_score
    end
    puts nil
  end

  def self.cowsay
    if system("which cowsay >/dev/null 2>&1")
      system("cowsay Bye!")
    end
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

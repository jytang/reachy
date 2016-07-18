##############################################
# Reachy constants
##############################################
module Reachy

  # Path
  APP_NAME  = "reachy"
  ROOT_PATH = Dir.home + "/." + APP_NAME + "/"
  DATA_PATH = ROOT_PATH + "data/"
  TRASH_PATH = DATA_PATH + "trash/"

  # Scoreboard formatting
  COL_SPACING = 15

  # Round result types
  T_TSUMO   = 1
  T_RON     = 2
  T_TENPAI  = 3
  T_NOTEN   = 4
  T_CHOMBO  = 5

  # List of named hand values
  L_HANDS   = ["mangan","haneman","baiman","sanbaiman","yakuman"]

  # Special characters
  L_NEWLINE = ["\r","\n","\r\n"]
  SIGINT_CH = "\u0003"
  EOF_CH = "\u0004"
end

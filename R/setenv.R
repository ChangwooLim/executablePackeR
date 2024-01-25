# Current PATH
current_path <- Sys.getenv("PATH")

# Directory to append
new_path <- "/Users/limcw/.nvm/versions/node/v20.9.0/bin"

# Append new path to the current PATH
Sys.setenv(PATH = paste(current_path, new_path, sep = ":"))

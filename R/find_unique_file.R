find_unique_file <- function(start_dir) {
  current_dir <- start_dir

  # Loop until there are no more subdirectories
  while (TRUE) {
    subdirs <- list.dirs(current_dir, full.names = TRUE, recursive = FALSE)
    if (length(subdirs) == 0) break # Exit loop if no more subdirectories
    current_dir <- subdirs[1] # Move to the next subdirectory
  }

  # Now, list files in the final directory
  files <- list.files(current_dir, full.names = TRUE)

  if (length(files) == 1) {
    return(files[1]) # Return the full path of the unique file
  } else {
    stop("No files or multiple files found in the final directory.")
  }
}

copy_contents <- function(source, destination) {
  # Ensure the destination directory exists
  if (!dir.exists(destination)) {
    dir.create(destination, recursive = TRUE)
  }

  # List all items in the source, excluding the 'shiny' directory
  items <- list.files(source, full.names = TRUE)
  items_to_copy <- items[!items %in% destination]

  # Iterate over each item to copy
  for (item in items_to_copy) {
    dest_path <- file.path(destination, basename(item))

    if (file.info(item)$isdir) {
      # If it's a directory, create it and copy its contents
      new_dir_path <- file.path(destination, basename(item))
      if (!dir.exists(new_dir_path)) dir.create(new_dir_path)
      copy_contents(item, new_dir_path) # Recursive call for directories
    } else {
      # If it's a file, copy it
      file.copy(item, destination)
    }
  }
}

move_to_new_folder <- function() {
  shiny_folder <- file.path(tempdir(), "shiny")

  if (!dir.exists(shiny_folder)) {
    dir.create(shiny_folder)
  }

  copy_contents(".", shiny_folder)
}

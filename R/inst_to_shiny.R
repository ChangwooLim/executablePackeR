#' @name copy_fron_inst_to_myapp
copy_from_inst_to_myapp <- function(files_and_folders, subdirectory = "", overwrite = TRUE, app_name = "myapp") {
  # Get the current working directory
  project_dir <- getwd()

  # Define the destination path
  dest_dir <- file.path(project_dir, subdirectory)

  # Create the destination directory if it doesn't exist
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir)
  }

  # Path to the 'inst' directory in your package
  inst_dir <- system.file(package = "executablePackeR")

  # Copy each specified file/folder
  for (item in files_and_folders) {
    item_path <- file.path(inst_dir, item)
    if (file.exists(item_path)) {
      if (file.info(item_path)$isdir) {
        # If it's a directory, use recursive copying
        dir.create(file.path(dest_dir, basename(item)), recursive = TRUE, showWarnings = FALSE)
        file.copy(item_path, dest_dir, recursive = TRUE, overwrite = overwrite)
      } else {
        # If it's a file, copy directly
        file.copy(item_path, dest_dir, overwrite = overwrite)
      }
    }
  }
}

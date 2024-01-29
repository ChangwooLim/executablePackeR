#' @importFrom utils download.file unzip
get_r_windows <- function() { # Define package name and paths
  R_version <- as.character(getRversion())
  r_installer_url <- paste0("https://cloud.r-project.org/bin/windows/base/old/", R_version, "/R-", R_version, "-win.exe")
  r_dir <- "r-win"
  innoextract_url <- "https://constexpr.org/innoextract/files/innoextract-1.9-windows.zip"
  innoextract_url_mirror <- "https://github.com/dscharrer/innoextract/releases/download/1.9/innoextract-1.9-windows.zip"
  innoextract_filename <- "innoextract.zip"
  innoextract_executable_filename <- "innoextract.exe"
  innoextract_path <- "innoextract"

  # Create download directory
  dir.create(r_dir)

  # Download R installer
  print("Downloading R Installer from r-project.org")
  download.file(r_installer_url, file.path(r_dir, "r_windows.exe"), mode = "wb")
  print("Downloading R Installer Complete")

  download_file(
    primary_url = innoextract_url,
    mirror_urls = c(innoextract_url_mirror),
    dest_file = "innoextract.zip", name = "innoextract"
  )

  unzip(innoextract_filename, exdir = innoextract_path)

  # Construct command to extract the R installer
  cmd_extract <- paste(shQuote(paste(innoextract_path, innoextract_executable_filename, sep = "/")), "-e", shQuote(file.path(r_dir, "r_windows.exe")))

  # Execute the extraction command
  system(cmd_extract, invisible = TRUE)

  # Move files from 'app' directory to 'r-win'
  app_dir <- file.path(getwd(), "app")
  if (dir.exists(app_dir)) {
    files_to_move <- list.files(app_dir, full.names = TRUE)
    sapply(files_to_move, function(file) {
      file.rename(file, file.path("r-win", basename(file)))
    })
    # Remove the 'app' directory
    unlink(app_dir, recursive = TRUE)
  }

  # Remove the installer file
  file.remove(file.path(r_dir, "r_windows.exe"))

  # Remove unnecessary directories: 'doc' and 'tests'
  dirs_to_remove <- c("doc", "tests")
  sapply(dirs_to_remove, function(dir) {
    full_dir_path <- file.path(r_dir, dir)
    if (dir.exists(full_dir_path)) {
      unlink(full_dir_path, recursive = TRUE)
    }
  })
}

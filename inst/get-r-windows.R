# Define package name and paths
your_package_name <- "executablePackeR"
innoextract_path <- system.file("innoextract/innoextract.exe", package = your_package_name)
r_installer_url <- "https://cloud.r-project.org/bin/windows/base/old/4.3.2/R-4.3.2-win.exe"
r_dir <- "r-win"

# Create download directory
dir.create(r_dir)

# Download R installer
download.file(r_installer_url, file.path(r_dir, "r_windows.exe"), mode = "wb")

# Construct command to extract the R installer
cmd_extract <- paste(shQuote(innoextract_path), "-e", shQuote(file.path(r_dir, "r_windows.exe")))

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

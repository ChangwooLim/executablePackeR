#' @importFrom utils download.file
get_r_mac <- function(app_name, options) {
  os <- detect_system()
  # Define URL and directory
  if (as.numeric(os["version"]) >= 11) {
    if (os["architecture"] == "arm64") {
      r_installer_url <- paste0("https://cloud.r-project.org/bin/macosx/big-sur-arm64/base/R-", as.character(getRversion()), "-arm64.pkg")
    } else if (os["architecture"] == "Intel") {
      r_installer_url <- paste0("https://cloud.r-project.org/bin/macosx/big-sur-x86_64/base/R-", as.character(getRversion()), "-x86_64.pkg")
    } else {
      stop("Unknown architecture. Contact Developer.")
    }
  }
  r_dir <- file.path(tempdir(), app_name, "r-mac")

  # Create r-mac directory
  dir.create(file.path(r_dir), recursive = TRUE)

  # Download the R installer package for Mac
  download.file(r_installer_url, file.path(r_dir, "r_mac.pkg"), mode = "wb")

  # Change working directory
  setwd(r_dir)

  # Extract the package using system call
  system2("xar", args = c("-xf", "r_mac.pkg"))

  # Removing unnecessary files and directories
  unnecessary_files <- c("Resources", "tcltk.pkg", "texinfo.pkg", "Distribution", "r_mac.pkg")
  sapply(unnecessary_files, function(x) {
    file_path <- file.path(x)
    if (file.exists(file_path) || dir.exists(file_path)) {
      unlink(file_path, recursive = TRUE)
    }
  })

  # Extract from the Payload
  system("cat R-fw.pkg/Payload | gunzip -dc | cpio -i")

  # Move files from R.framework to the current directory
  framework_dir <- file.path("R.framework", "Versions", "Current", "Resources")
  if (dir.exists(framework_dir)) {
    files_to_move <- list.files(framework_dir, full.names = TRUE)
    sapply(files_to_move, function(file) {
      file.rename(file, file.path(basename(file)))
    })
  }

  # Remove unnecessary directories
  dirs_to_remove <- c("R-fw.pkg", "R.framework", "doc", "tests", "lib/*.dSYM")
  sapply(dirs_to_remove, function(x) {
    file_path <- file.path(x)
    if (file.exists(file_path) || dir.exists(file_path)) {
      unlink(file_path, recursive = TRUE)
    }
  })

  # Patch the main R script
  system("sed -i.bak '/^R_HOME_DIR=/d' bin/R")
  system("sed -i.bak 's;/Library/Frameworks/R.framework/Resources;${R_HOME};g' bin/R")
  system("chmod +x bin/R")
  file.remove("bin/R.bak")

  # Reset working directory -> to tempdir()
  setwd(tempdir())
}

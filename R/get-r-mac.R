get_r_mac <- function(){
  # Define URL and directory
  r_installer_url <- "https://cloud.r-project.org/bin/macosx/big-sur-arm64/base/R-4.3.2-arm64.pkg"
  r_dir <- "r-mac"

  # Create r-mac directory
  dir.create(r_dir, recursive = TRUE)

  # Download the R installer package for Mac
  download.file(r_installer_url, file.path(r_dir, "latest_r.pkg"), mode = "wb")

  # Change working directory
  setwd(r_dir)

  # Extract the package using system call
  system("xar -xf latest_r.pkg")

  # Removing unnecessary files and directories
  unnecessary_files <- c("Resources", "tcltk.pkg", "texinfo.pkg", "Distribution", "latest_r.pkg")
  sapply(unnecessary_files, function(x) {
    file_path <- file.path(getwd(), x)
    if (file.exists(file_path) || dir.exists(file_path)) {
      unlink(file_path, recursive = TRUE)
    }
  })

  # Extract from the Payload
  system("cat R-fw.pkg/Payload | gunzip -dc | cpio -i")

  # Move files from R.framework to the current directory
  framework_dir <- file.path(getwd(), "R.framework", "Versions", "Current", "Resources")
  if (dir.exists(framework_dir)) {
    files_to_move <- list.files(framework_dir, full.names = TRUE)
    sapply(files_to_move, function(file) {
      file.rename(file, file.path(getwd(), basename(file)))
    })
  }

  # Remove unnecessary directories
  dirs_to_remove <- c("R-fw.pkg", "R.framework", "doc", "tests", "lib/*.dSYM")
  sapply(dirs_to_remove, function(x) {
    file_path <- file.path(getwd(), x)
    if (file.exists(file_path) || dir.exists(file_path)) {
      unlink(file_path, recursive = TRUE)
    }
  })

  # Patch the main R script
  system("sed -i.bak '/^R_HOME_DIR=/d' bin/R")
  system("sed -i.bak 's;/Library/Frameworks/R.framework/Resources;${R_HOME};g' bin/R")
  system("chmod +x bin/R")
  file.remove("bin/R.bak")

  # Reset working directory
  setwd("..")

}

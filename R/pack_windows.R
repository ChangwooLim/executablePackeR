#' @name pack_windows
#' @author Changwoo Lim
#' @import automagic
#' @export
#' @examples
#' \dontrun{
#'
#' }
pack_windows <- function(app_name = "myapp") {
  check_dependency()
  print("Checking dependency Complete")
  print(getwd())
  if (app_name == "app") stop("App name cannot be 'app'. Use different name(i. e. 'myapp')")

  move_to_new_folder()
  prepare_electron(platform = "windows")
  # unlink("package.json")
  copy_from_inst_to_myapp(
    files_and_folders = c("package.json", "forge.config.js"),
    subdirectory = "", overwrite = TRUE
  )
  system2("npm", "install")
  print("npm install Complete")
  print("Replacing forge.config.js and package.json complete.")
  system2("electron-forge", args = c("make"))
  print(paste0("Build Complete. See ", app_name, "/out folder."))
}

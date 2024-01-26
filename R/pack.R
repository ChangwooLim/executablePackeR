#' @name pack
#' @author Changwoo Lim
#' @import automagic
#' @export
#' @examples
#' \dontrun{
#'
#' }
pack <- function(app_name = "myapp") {
  check_prerequisites()
  print("Checking dependency Complete")
  # print(getwd())
  if (app_name == "app") stop("App name cannot be 'app'. Use different name(i. e. 'myapp')")

  move_to_new_folder()
  prepare_electron(platform = "macos", app_name = app_name)
  copy_from_inst_to_myapp(
    files_and_folders = c("package.json", "forge.config.js"),
    subdirectory = "", overwrite = TRUE
  )
  print("Replacing forge.config.js and package.json complete.")
  system2("npm", "install")
  print("npm install Complete")
  system2("electron-forge", args = c("make"))
  print(paste0("Build Complete. See ", app_name, "/out folder."))
}

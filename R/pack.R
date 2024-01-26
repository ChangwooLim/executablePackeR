#' @name pack
#' @author Changwoo Lim
#' @import automagic
#' @export
#' @examples
#' \dontrun{
#'
#' }
#' @param electron_settings a list including package.json settings. Including product_name, app_version, app_description, author_name, author_email, repository_url
pack <- function(app_name = "myapp", electron_settings = list()) {
  check_prerequisites()
  print("Checking dependency Complete")
  # print(getwd())
  if (app_name == "app") stop("App name cannot be 'app'. Use different name(i. e. 'myapp')")

  move_to_new_folder()
  prepare_electron(app_name = app_name)
  copy_from_inst_to_myapp(
    files_and_folders = c("package.json", "forge.config.js"),
    subdirectory = app_name, overwrite = TRUE, app_name = app_name
  )
  print("Replacing forge.config.js and package.json complete.")
  setwd(app_name)
  edit_file("package.json", c(list(c("<@app_name>", app_name)), electron_settings))
  system2("npm", "install")
  print("npm install Complete")
  system2("electron-forge", args = c("make"))
  print(paste0("Build Complete. See ", app_name, "/out folder."))
  setwd("..")
}


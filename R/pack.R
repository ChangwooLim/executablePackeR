#' @name pack
#' @title Make Shiny Application to Executable File
#' @author Changwoo Lim
#' @import automagic
#' @export
#' @description
#' This Function make your shiny app to an executable file
#' Go to your project directory(Including app.R), and run this function.
#'
#' @examples
#' \dontrun{
#'   executablePackeR::pack(app_name="myapp",
#'                          electron_settings=list(c("product_name_template",
#'                                                   "my_own_product_name")))
#' }
#' @param app_name Name of your application
#' @param electron_settings a list including package.json settings. Including product_name, app_version, app_description, author_name, author_email, repository_url
pack <- function(app_name = "myapp", electron_settings = list()) {
  check_prerequisites()
  message("Checking dependency Complete")
  # print(getwd())
  if (app_name == "app") stop("App name cannot be 'app'. Use different name(i. e. 'myapp')")

  move_to_new_folder()
  prepare_electron(app_name = app_name)
  copy_from_inst_to_app(
    files_and_folders = c("package.json", "forge.config.js"),
    subdirectory = app_name, overwrite = TRUE, app_name = app_name
  )
  message("Replacing forge.config.js and package.json complete.")
  setwd(app_name)
  edit_file("package.json", c(list(c("<@app_name>", app_name)), electron_settings))
  message("Adjusting package.json content Complete")
  message("Installing npm dependencies(npm i)")
  system2("npm", args = "install", invisible = FALSE)
  message("npm install Complete")
  system2("electron-forge", args = c("make"))
  message(paste0("Build Complete. See ", app_name, "/out folder."))
  setwd("..")
}


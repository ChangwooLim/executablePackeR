#' @name pack
#' @title Make Shiny Application to Executable File
#' @author Changwoo Lim
#' @import automagic
#' @import cli
#' @importFrom utils zip
#' @importFrom rstudioapi selectDirectory
#' @export
#' @description
#' This Function make your shiny app to an executable file
#' Go to your project directory(Including app.R), and run this function.
#' @examples
#' if (interactive()) {
#'   # Needs at least 1 minute.
#'   pack(
#'     app_name = "myapp",
#'     electron_settings = list(
#'       c("product_name_template", "My Own Product Name"),
#'       c("app_description_template", "App Description"),
#'       c("author_name_template", "Author Name"),
#'       c("author_email_template", "Author E-mail"),
#'       c("repository_url_template", "Repository URL")
#'     ),
#'     option = list()
#'   )
#' }
#' @param app_name Name of your application. Default will be "myapp".
#' @param electron_settings A list including package.json settings. Including product_name, app_version, app_description, author_name, author_email, repository_url
#' @param option A list containing option for packing. See option_description.md for details.
#' @return Returns nothing. For generating new files.
pack <- function(app_name = "myapp", electron_settings = list(), option = list()) {
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  cli_h1("Packing your Shiny application to executable file")

  cli_h2("Checking Prerequisites")
  check_prerequisites(option = option)
  cli_alert_success("Checking Prerequisites Succeed")

  if (("is_dev" %in% names(option)) && option$is_dev == TRUE) {
    cli_alert_info("DEV mode detected.")
    DEV <- TRUE
  } else {
    DEV <- FALSE
  }

  cli_alert_success("Checking dependency Complete")

  # Set Export Directory
  cli_alert_info("Select a directory to save executable files.")
  executable_save_directory <- rstudioapi::selectDirectory()
  if (is.null(executable_save_directory)) {
    cli_alert_danger("Select Export Directory")
    stop("You should select export directory")
  } else {
    cli_alert_success(paste0("Saving Executable at: ", executable_save_directory))
  }

  if (app_name == "app") {
    cli_alert_warning("App name cannot be 'app'. Use different name(i. e. 'myapp').")
    user_response <- readline(prompt = "Please provide new name of your application: ")
    if ((user_response != "") && (user_response != "app")) { # Strip해서 공백되지 않아야 함.
      app_name <- user_response
      cli_alert_success(paste0("Your application name has been changed to ", app_name))
    } else {
      cli_alert_danger("Application name cannot be blank or 'app'. Aborting")
      stop("Application name does not fit to standard")
    }
  }

  move_to_new_folder()
  prepare_electron(app_name = app_name, option = option)
  copy_from_inst_to_app(
    files_and_folders = c("package.json", "forge.config.js"),
    subdirectory = app_name, overwrite = TRUE, app_name = app_name
  )
  cli_alert_success("Replacing forge.config.js and package.json complete.")
  setwd(file.path(tempdir(), app_name))
  {
    edit_package_json_reuslt <- edit_file(paste0(tempdir(), "/", app_name, "/package.json"), c(list(c("<@app_name>", app_name)), electron_settings))
    if (edit_package_json_reuslt == TRUE) {
      cli_alert_success("Adjusting package.json content Complete")
    } else {
      stop("File not found")
    }
    setwd(file.path(tempdir(), app_name))
    cli_alert_info("Installing npm dependencies(npm i)")
    system2("npm", args = c("install"), invisible = FALSE)
    cli_alert_success("npm install Complete")

    system2("electron-forge", args = c("make"))
    cli_alert_success(paste0("Build Complete. See ", app_name, "/out folder."))
  }
  setwd("..")

  # Cleaning temp files
  # unlink(file.path(tempdir(), app_name, "out/make"), recursive = TRUE)
  # setwd(file.path(tempdir(), app_name, "out"))
  output_location <- find_unique_file(file.path(tempdir(), app_name, "out/make"))
  file.rename(output_location, file.path(executable_save_directory, basename(output_location)))
  # executable_to_zip <- list.files(path = file.path("."), full.names = TRUE, recursive = TRUE)
  # cli_alert_info("Compressing. Please wait")
  # zip(zipfile = file.path(executable_save_directory, "executable.zip"), files = executable_to_zip, flags = "-q")
  if (DEV == FALSE) {
    unlink(file.path(tempdir(), app_name), recursive = TRUE)
  } else if (DEV == TRUE) {
    cli_alert_info(paste0("tempdir(): ", tempdir()))
  }
}

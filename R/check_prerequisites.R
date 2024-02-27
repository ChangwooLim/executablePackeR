#' @import cli
check_prerequisites <- function(option, test = FALSE) {
  # Check OS is Windows or macOS
  detect_system()

  dependency_list <- c("npx", "electron-forge")
  cli_h3(paste("Checking dependencies are installed."))
  uninstalled_list <- c()

  for (i in seq_along(dependency_list)) {
    if (Sys.which(dependency_list[i]) == "") {
      uninstalled_list <- append(uninstalled_list, dependency_list[i])
    }
  }

  if (!("npx" %in% uninstalled_list) && ("electron-forge" %in% uninstalled_list)) {
    cli_alert_warning("Dependency electron-forge not found.")
    user_response <- readline(prompt = "Do you want to install electron-forge through npm? (yes/no): ")
    if (tolower(user_response) %in% c("yes", "y")) {
      cli_alert_info("Installing @electron-forge/cli through npm.")
      system2("npm", args = c("install", "-g", "@electron-forge/cli"))

      if (Sys.which("electron-forge") != "") {
        uninstalled_list <- uninstalled_list[uninstalled_list != "electron-forge"]
      }
    }
  }

  if (length(uninstalled_list) != 0) {
    cli_alert_danger(paste("Dependency", paste(uninstalled_list, collapse = ", "), "is(are) not installed. Aborting"))
    stop("Essential Dependency not found")
  }

  # 체크필요
  check_electron_forge_installed <- function() {
    # Execute command and capture output
    output <- system2("npm", args = c("list", "-g", "electron-forge", "--depth=0"), stdout = TRUE, stderr = TRUE)

    # Check if electron/forge is in the output
    is_installed <- grepl("electron-forge@", output)

    return(is_installed)
  }
}

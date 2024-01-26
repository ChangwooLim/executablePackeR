#' @name check_prerequisites
#' @export
#' @examples
#' \dontrun{
#'
#' }
#'
check_prerequisites <- function(test = FALSE) {
  # Check OS is Windows or macOS
  detect_system()

  dependency_list <- c("npx")
  uninstalled_list <- c()

  for (i in seq_along(dependency_list)) {
    if (Sys.which(dependency_list[i]) == "") {
      uninstalled_list <- append(uninstalled_list, dependency_list[i])
    }
  }

  if (length(uninstalled_list) != 0) {
    stop(paste("Dependency", paste(uninstalled_list, collapse = ","), "is not installed."))
  }

  # 체크필요
  check_electron_forge_installed <- function() {
    # Command to check if electron/forge is installed
    command <- "npm"
    args <- "list -g electron-forge --depth=0"

    # Execute command and capture output
    output <- system2(command, args, stdout = TRUE, stderr = TRUE)

    # Check if electron/forge is in the output
    is_installed <- grepl("electron-forge@", output)

    return(is_installed)
  }
}

# check_dependency()
# check_electron_forge_cli_installed()

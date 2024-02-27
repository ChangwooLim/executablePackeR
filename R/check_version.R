#' @import cli
#' @importFrom utils old.packages packageVersion
checkForPackageUpdates <- function(packageName) {

  currentVersion <- packageVersion(packageName)

  # Check for updates on CRAN
  updates <- old.packages(lib.loc = .libPaths(), repos = "https://cloud.r-project.org")

  if (!is.null(updates) && packageName %in% rownames(updates)) {
    latestVersion <- updates[packageName, "Version"]
    cli_alert_info(sprintf("A new version of %s is available: %s\nYou are using version: %s\nConsider updating the package using install.packages('%s').",
                    packageName, latestVersion, currentVersion, packageName))
  } else {
    cli_alert_success(sprintf("You are using the latest version of %s.", packageName))
  }
}

#' @importFrom cli cli_alert_success
download_file <- function(primary_url, mirror_urls = c(), dest_file, name) {
  success <- try(download.file(primary_url, destfile = dest_file, mode = "wb"), silent = TRUE)

  # If download from primary URL fails, try the mirror URL
  if (inherits(success, "try-error")) {
    warning("Primary download link failed. Trying mirror link...")

    for (link in mirror_urls) {
      success <- try(download.file(link, destfile = dest_file, mode = "wb"), silent = TRUE)
      if (inherits(success, "try-error")) {
        warning(paste0("Mirror link ", link, " Failed. Trying another mirror if available."))
      } else {
        cli_alert_success("Download Complete")
        return("Download Complete")
      }
    }
  } else {
    cli_alert_success("Download Complete")
    return("Download Complete")
  }
}

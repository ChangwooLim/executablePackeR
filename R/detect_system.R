get_mac_architecture <- function() {
  architecture_info <- system2("uname", args="-m", stdout = TRUE)
  if (architecture_info == "x86_64") {
    # For an Intel processor, it will return "x86_64".
    # Check if this is an Intel Mac running in Rosetta 2
    rosetta_info <- system2("sysctl", args = c("-in", "sysctl.proc_translated"), stdout = TRUE, stderr = NULL)
    if (rosetta_info == "1") {
      return("arm64")
    } else {
      return("Intel")
    }
  } else if (architecture_info == "arm64") {
    # For an Apple M1 processor, it will return "arm64".
    return("arm64")
  } else {
    return("Unknown Architecture")
  }
}

#' @name detect_system
#' @examples
#' \dontrun{
#' os_info <- get_os_info()
#' print(os_info)
#' }
#'
detect_system <- function() {
  os_info <- Sys.info()
  os_name <- os_info["sysname"]

  if (os_name == "Windows") {
    print("Detected Windows.")
    return(list(os = "Windows"))
  } else if (os_name == "Darwin") {
    # Use system command to get macOS version
    mac_version_info <- system2("sw_vers", args = "-productVersion", stdout = TRUE)
    mac_architecture <- get_mac_architecture()
    print(paste("Detect macOS", mac_version_info, mac_architecture))
    return(list(os = "macOS", version = mac_version_info, architecture = mac_architecture))
  } else {
    stop("Operating Systems other than Windows or macOS are currently not supported.")
  }
}

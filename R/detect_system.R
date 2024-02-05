get_mac_architecture <- function() {
  architecture_info <- system2("uname", args = "-m", stdout = TRUE)
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

detect_system <- function() {
  cli_h3("Detecting your Operating System")
  os_info <- Sys.info()
  os_name <- os_info["sysname"]
  if (os_name == "Windows") {
    cli_alert_info("Detected Windows")
    return(list(os = "Windows"))
  } else if (os_name == "Darwin") {
    mac_version_info <- system2("sw_vers", args = "-productVersion", stdout = TRUE)
    mac_architecture <- get_mac_architecture()
    cli_alert_info(paste("Detect macOS", mac_version_info, mac_architecture))
    return(list(os = "macOS", version = mac_version_info, architecture = mac_architecture))
  } else {
    cli_alert_danger("Operating Systems other than Windows or macOS are currently not supported. Aborting.")
    stop("Only Windows and macOS are supported.")
  }
}

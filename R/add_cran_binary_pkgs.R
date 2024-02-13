# Copyright (c) 2018 Dirk Schumacher, Noam Ross, Rich FitzJohn
# Copyright (c) 2023 Jinhwan Kim
# Copyright (c) 2024 Changwoo Lim

# !/usr/bin/env Rscript

# Script to find dependencies of a pkg list, download binaries and put them
# In the standalone R library.

# Code format changed using styler::style_active_file()
# CRAN link updated to el-capitan to big-sur(m1)
#' @import automagic
#' @importFrom utils available.packages download.packages untar
add_cran_binary_pkgs <- function(app_name = "myapp") {
  setwd(file.path(tempdir(), app_name))
  repo_old <- options()$repos
  options(repos = "https://cloud.r-project.org")

  cran_pkgs <- setdiff(unique(c("shiny", automagic::get_dependent_packages("shiny"))), "automagic")

  copy_unavailable_packages <- function(unavailable_pkgs, library_install_path) {
    default_packages <- c("base", "compiler", "datasets", "grDevices", "graphics", "grid", "methods", "parallel", "splines", "stats", "stats4", "tcltk", "tools", "translations", "utils")
    unavailable_pkgs <- unavailable_pkgs[!unavailable_pkgs %in% default_packages]
    library_paths <- .libPaths()

    for (pkg in unavailable_pkgs) {
      pkg_path <- find.package(pkg, lib.loc = library_paths, quiet = TRUE)
      if (nzchar(pkg_path)) {
        dest_dir <- file.path(library_install_path)
        if (!dir.exists(dest_dir)) {
          dir.create(dest_dir, recursive = TRUE)
        }
        file.copy(pkg_path, dest_dir, recursive = TRUE)
        message("Copied ", pkg, " to ", dest_dir)

        if (dir.exists("r-mac")) {
          library_install_path <- file.path("r-mac", "library")
          install_bins(get_local_package_dependencies(pkg), library_install_path, type = "mac.binary.big-sur-arm64", decompress = untar)
        }

        if (dir.exists("r-win")) {
          library_install_path <- file.path("r-win", "library")
          install_bins(get_local_package_dependencies(pkg), library_install_path, type = "win.binary", decompress = unzip)
        }
      } else {
        stop("Package ", pkg, " not found in the user's library paths.")
        # message("Package ", pkg, " not found in the user's library paths.")
      }
    }
  }

  get_local_package_dependencies <- function(package_name) {
    package_path <- find.package(package_name)
    description_path <- file.path(package_path, "DESCRIPTION")

    if (!file.exists(description_path)) {
      stop("DESCRIPTION file not found for the package ", package_name)
    }

    extract_section <- function(section) {
      content <- readLines(description_path)
      start <- grep(paste0("^", section, ":"), content)
      if (length(start) == 0) {
        return(character(0))
      } # Return empty if section not found

      # Determine the end of the section
      next_sections <- grep("^[A-Za-z]+:", content)
      next_section_start <- next_sections[next_sections > start]
      end <- if (length(next_section_start) == 0) {
        length(content)
      } else {
        min(next_section_start[1] - 1, length(content))
      }

      # Extract and clean the section content
      section_lines <- content[start:end]
      section_content <- paste(section_lines, collapse = " ")
      section_content <- gsub(paste0("^", section, ":\\s*"), "", section_content)
      section_content <- gsub("\\([^\\)]+\\)", "", section_content)
      package_names <- unlist(strsplit(section_content, ",\\s*"))
      package_names <- package_names[nzchar(package_names)]
      package_names <- trimws(package_names)
      return(unique(package_names))
    }


    # Extract packages from Imports and Depends sections
    imports <- extract_section("Imports")
    depends <- extract_section("Depends")
    suggests <- extract_section("Suggests")
    linkingto <- extract_section("LinkingTo")

    # Combine and return unique package names
    required_packages <- unique(c(imports, depends))
    required_packages <- required_packages[required_packages != "" &
      !required_packages %in% c("R", "Depends", "Imports", "Suggests", "LinkingTo")]
    return(required_packages)
  }

  install_bins <- function(
      cran_pkgs, library_path, type, decompress,
      remove_dirs = c(
        "help", "doc", "tests", "html",
        "include", "unitTests",
        file.path("libs", "*dSYM")
      )) {
    installed <- list.files(library_path) # check installed packages

    cran_to_install <- sort(setdiff(
      unique(unlist(
        c(
          cran_pkgs,
          tools::package_dependencies(cran_pkgs,
            recursive = TRUE,
            which = c("Depends", "Imports", "LinkingTo")
          )
        )
      )),
      installed
    ))

    available_packages <- rownames(available.packages())
    unavailable_pkgs <- setdiff(cran_to_install, available_packages)
    if (length(unavailable_pkgs) > 0) {
      warning(
        "The following packages are not available at CRAN and copied from your R library: ",
        paste(unavailable_pkgs, collapse = ", ")
      )
    }

    cran_to_install <- intersect(cran_to_install, available_packages)

    if (!length(cran_to_install)) {
      message("No new packages to install.")
      return(invisible(unavailable_pkgs))
    }

    td <- tempdir()
    downloaded <- download.packages(cran_to_install, destdir = td, type = type)
    apply(downloaded, 1, function(x) decompress(x[2], exdir = library_path))
    unlink(downloaded[, 2])

    z <- lapply(
      list.dirs(library_path, full.names = TRUE, recursive = FALSE),
      function(x) {
        unlink(file.path(x, remove_dirs), force = TRUE, recursive = TRUE)
      }
    )

    invisible(unavailable_pkgs)

    copy_unavailable_packages(unavailable_pkgs, library_path)
  }


  if (dir.exists(file.path("r-mac"))) {
    library_install_path <- file.path("r-mac", "library")
    unavailable_packages <- install_bins(
      cran_pkgs = cran_pkgs, library_path = library_install_path,
      type = "mac.binary.big-sur-arm64", decompress = untar
    )
    # copy_unavailable_packages(unavailable_packages, library_install_path)
  }

  if (dir.exists("r-win")) {
    library_install_path <- file.path("r-win", "library")
    unavailable_packages <- install_bins(
      cran_pkgs = cran_pkgs, library_path = library_install_path,
      type = "win.binary", decompress = unzip
    )
    # copy_unavailable_packages(unavailable_packages, library_install_path)
  }

  options(repos = repo_old)
  setwd(tempdir())
}

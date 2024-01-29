# Copyright (c) 2018 Dirk Schumacher, Noam Ross, Rich FitzJohn
# Copyright (c) 2023 Jinhwan Kim

# !/usr/bin/env Rscript

# Script to find dependencies of a pkg list, download binaries and put them
# In the standalone R library.

# Code format changed using styler::style_active_file()
# CRAN link updated to el-capitan to big-sur(m1)

library(automagic)

options(repos = "https://cloud.r-project.org")

cran_pkgs <- setdiff(unique(c("shiny", automagic::get_dependent_packages("shiny"))), "automagic")

copy_unavailable_packages <- function(unavailable_pkgs, library_install_path) {
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
      #message("Package ", pkg, " not found in the user's library paths.")
    }

  }
}

get_local_package_dependencies <- function(package_name) {
  package_path <- find.package(package_name)
  description_path <- file.path(package_path, "DESCRIPTION")

  if (!file.exists(description_path)) {
    stop("DESCRIPTION file not found for the package ", package_name)
  }

  description_content <- readLines(description_path)
  deps_lines <- description_content[grepl("^Imports:|^Depends:|^Suggests:|^LinkingTo:", description_content)]
  deps <- unlist(strsplit(deps_lines, split = "[,:]+"))
  deps <- trimws(deps) # Remove leading/trailing whitespace

  # Remove versioning information and filter
  deps <- sub("\\s+.*$", "", deps)
  deps <- deps[deps != "" &
                 !deps %in% c("R", "Depends", "Imports", "Suggests", "LinkingTo")]

  return(deps)
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
      c(cran_pkgs,
        tools::package_dependencies(cran_pkgs,
                                    recursive = TRUE,
                                    which = c("Depends", "Imports", "LinkingTo")
        ))
    )),
    installed
  ))

  available_packages <- rownames(available.packages())
  unavailable_pkgs <- setdiff(cran_to_install, available_packages)
  if (length(unavailable_pkgs) > 0) {
    warning("The following packages are not available at CRAN and copied from your R library: ",
            paste(unavailable_pkgs, collapse = ", "))
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


if (dir.exists("r-mac")) {
  library_install_path <- file.path("r-mac", "library")
  unavailable_packages <- install_bins(
    cran_pkgs = cran_pkgs, library_path = library_install_path,
    type = "mac.binary.big-sur-arm64", decompress = untar
  )
  copy_unavailable_packages(unavailable_packages, library_install_path)
}

if (dir.exists("r-win")) {
  library_install_path <- file.path("r-win", "library")
  unavailable_packages <- install_bins(cran_pkgs = cran_pkgs, library_path = library_install_path,
                                       type = "win.binary", decompress = unzip
  )
  copy_unavailable_packages(unavailable_packages, library_install_path)
}

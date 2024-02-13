# app_name, product_name, app_version, app_description, author_name, author_email, repository_url
# edit_file("package.json", list(c("<@app_name>", "changwooshiny"), c("<@product_name>", "changwooshiny"), c("<@app_version>", "0.0.1:9000"), c("<@app_description>", "description"), c("author_name", "Changwoo Lim"), c("author_email", "limcw@zarathu.com"), c("repository_url", "https://github.com/zarathucorp/")))
#' @importFrom cli cli_alert_danger
edit_file <- function(file, edit_list = list()) {
  if(file.exists(file) == FALSE) {
    cli_alert_danger(paste0("Adjusting package.json content Failed: ", file, "not found."))
    return(FALSE)
  }
  file_content <- readLines(file.path(file))
  for (edit in edit_list) {
    file_content <- gsub(edit[1], edit[2], file_content, fixed = TRUE)
  }
  writeLines(file_content, file)

  return(TRUE)
}

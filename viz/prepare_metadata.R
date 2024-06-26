library(purrr)

metadata <- fs::dir_ls(
  here::here("model-metadata")
) %>%
  # sort with radix method ensures locale-independent output
  sort(method = "radix") %>%
  map(yaml::read_yaml) %>%
  set_names(map(., ~ pluck(.x, "model_abbr"))) %>%
  map(function(e) {
    e$methods_long <- ifelse(is.null(e$methods_long), e$methods, e$methods_long)
    return(e)
  }) %>%
  map(function(e) {
    e$model_contributors <- glue::glue_collapse(
      purrr::map(e$model_contributors, "name"),
      sep = ", "
    )
    return(e)
  }) %>%
  # delete double spaces in all fields because they don't play nice with json
  rapply(function(x) gsub("\\s+", " ", x), how = "replace")

metadata_json <- metadata %>%
  jsonlite::toJSON(auto_unbox = TRUE, pretty = TRUE)

metadata_json %>%
  write(here::here("viz", "metadata.json"))


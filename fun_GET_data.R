fun_request_content <- function(url,
                         path,
                         query = NULL,
                         verb = "GET",
                         useragent,
                         content_as = "text"){
  url <- httr::modify_url(url = url,
                          path = path,
                          query = query)
  response <- httr::RETRY(verb = verb,
                          url = url,
                          httr::user_agent(useragent),
                          httr::progress())
  content <- httr::content(response,
                           as = content_as)
  content
  }

fun_geojson_sf <- function(geojson,
                           crs = NULL,
                           subset_type = c(NULL,"geo","non_geo"),
                           subset_fun = NULL,
                           subset_col = NULL,
                           subset_val = NULL,
                           dsn = NULL,
                           layer = NULL) {
  if(!is.null(crs)){
    message("Reading GeoJSON from ",geojson,", converting to CRS ",crs)
    sf <- geojsonsf::geojson_sf(geojson) %>%
      sf::st_transform(crs = crs,
                       check = TRUE)
  } else {
    message("Reading GeoJSON from ",geojson)
    sf <- geojsonsf::geojson_sf(geojson)
  }
  
  enquo_subset_col <- enquo(subset_col)
  
  if(!is.null(subset_type)){
    if(subset_type == "geo"){
        message("Selecting data where ",subset_fun," ",enquo(subset_val))
        sf <- sf %>%
          dplyr::filter(lengths(do.call(get(subset_fun,asNamespace("sf")),list(.,subset_val))) > 0)
    } else if(subset_type == "non_geo"){
      message("Selecting data where ",enquo_subset_col," equals ", subset_val)
      sf <- sf %>%
        dplyr::filter(!! enquo_subset_col == subset_val)
    }
  }
  
   else {
    sf
  }
  
  if(!is.null(file)){
    message("Saving file as ",layer," in ",dsn)
    sf::st_write(sf,
                 dsn = dsn,
                 layer = layer)
  } else {
    sf
  }
  sf
}

fun_metadata <- function(url,
                         path,
                         query = NULL,
                         useragent = NULL,
                         verb = "GET",
                         content_as = "text",
                         encoding = NULL,
                         as_html = FALSE,
                         options = "NOBLANKS",
                         save = FALSE,
                         file = NULL){

  txt <- fun_request_content(url = url,
                             path = path,
                             query = query,
                             verb = verb,
                             useragent = ua,
                             content_as = content_as)
  
  xml <- xml2::read_xml(txt,
                        encoding = encoding,
                        as_html = as_html,
                        options = options)
  
  
  
  if(save == TRUE){
    xml2::write_xml(xml,
         file = file)
    xml
  } else {
    xml
  }
}


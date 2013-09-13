#' Geta details on a dataset.
#' 
#' @template all
#' @importFrom httr GET content verbose
#' @importFrom plyr compact
#' @param uuid A dataset UUID.
#' @param callopts Pass on options to GET.
#' @description 
#' You should be able to pass in more than one uuid to this function, but I have
#' not yet found more than the one uuid below in the example that actually has
#' data available.
#' @examples \dontrun{
#' dataset_metrics(uuid='3f8a1297-3259-4700-91fc-acc4170b27ce')
#' }
#' @export
dataset_metrics <- function(uuid, callopts=list())
{
  # Define function to get data
  getdata <- function(x){
    url <- sprintf('http://api.gbif.org/dataset_metrics/%s', x)
    content(GET(url, callopts))
  }
  
  # Get data
  if(length(uuid)==1){ out <- getdata(uuid) } else
    { out <- lapply(uuid, getdata) }
  
  out
}
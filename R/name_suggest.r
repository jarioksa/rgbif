#' A quick and simple autocomplete service that returns up to 20 name usages by 
#' doing prefix matching against the scientific name. Results are ordered by relevance.
#' 
#' @template all
#' @template occ
#' @import httr plyr
#' @export
#' 
#' @param q (character, required) Simple search parameter. The value for this parameter can be a 
#'    simple word or a phrase. Wildcards can be added to the simple word parameters only, 
#'    e.g. q=*puma*
#' @param datasetKey (character) Filters by the checklist dataset key (a uuid, see examples)
#' @param rank (character) A taxonomic rank. One of class, cultivar, cultivar_group, domain, family, 
#'    form, genus, informal, infrageneric_name, infraorder, infraspecific_name, 
#'    infrasubspecific_name, kingdom, order, phylum, section, series, species, strain, subclass, 
#'    subfamily, subform, subgenus, subkingdom, suborder, subphylum, subsection, subseries, 
#'    subspecies, subtribe, subvariety, superclass, superfamily, superorder, superphylum, 
#'    suprageneric_name, tribe, unranked, or variety. 
#' @param fields (character) Fields to return in output data.frame (simply prunes columns off)
#' 
#' @return A data.frame with fields selected by fields arg.
#' 
#' @examples \dontrun{
#' name_suggest(q='Puma concolor')
#' name_suggest(q='Puma')
#' name_suggest(q='Puma', rank="genus")
#' name_suggest(q='Puma', rank="subspecies")
#' name_suggest(q='Puma', rank="species")
#' name_suggest(q='Puma', rank="infraspecific_name")
#' 
#' name_suggest(q='Puma', limit=2)
#' name_suggest(q='Puma', fields=c('key','canonicalName'))
#' name_suggest(q='Puma', fields=c('key','canonicalName','higherClassificationMap'))
#' }

name_suggest <- function(q=NULL, datasetKey=NULL, rank=NULL, fields=NULL, start=NULL, 
                         limit=20, callopts=list())
{
  url = 'http://api.gbif.org/v1/species/suggest'
  args <- rgbif_compact(list(q=q, rank=rank, offset=start, limit=limit))
  temp <- GET(url, query=args, callopts)
  stop_for_status(temp)
  assert_that(temp$headers$`content-type`=='application/json')
  res <- content(temp, as = 'text', encoding = "UTF-8")
  tt <- RJSONIO::fromJSON(res, simplifyWithNames = FALSE)
  
  if(is.null(fields)){
    toget <- c("key","canonicalName","rank")
  } else { toget <- fields }
  matched <- sapply(toget, function(x) x %in% suggestfields())
  if(!any(matched))
    stop(sprintf("the fields %s are not valid", paste0(names(matched[matched == FALSE]),collapse=",")))
  if(any(fields %in% "higherClassificationMap")){
    for(i in seq_along(tt)){  
      temp <- tt[[i]]
      temp <- temp$higherClassificationMap
      tt[[i]][['higherClassificationMap']] <- data.frame(id=names(temp), name=do.call(c, unname(temp)), stringsAsFactors = FALSE)
    }
    out <- lapply(tt, function(x) x[names(x) %in% toget])
    df <- do.call(rbind.fill, lapply(out, function(x){
      data.frame(x[ !names(x) %in% "higherClassificationMap" ], stringsAsFactors = FALSE)
    }))
    hier <- sapply(tt, function(x) x[ names(x) %in% "higherClassificationMap" ])
    hier <- unname(hier)
    names(hier) <- vapply(tt, "[[", numeric(1), "key")
    list(data=df, hierarchy=hier)
  } else {
    out <- lapply(tt, function(x) x[names(x) %in% toget])
    do.call(rbind.fill, lapply(out, data.frame, stringsAsFactors = FALSE))
  }
}

#' Fields available in gbif_suggest function
#' @export
#' @keywords internal
suggestfields <- function(){  
  c("key","datasetTitle","datasetKey","nubKey","parentKey","parent",
    "kingdom","phylum","class","order","family","genus","species",
    "kingdomKey","phylumKey","classKey","orderKey","familyKey","genusKey",
    "speciesKey","species","canonicalName","authorship",
    "accordingTo","nameType","taxonomicStatus","rank","numDescendants",
    "numOccurrences","sourceId","nomenclaturalStatus","threatStatuses",
    "synonym","higherClassificationMap")
}
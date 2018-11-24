# Function to check if population tabel 
# exist in WorldPop FTP
is.populated <- function(x) x %in% c('ABW','AFG','AGO','AIA','ALA','ALB','AND','ARE','ARG',
                                     'ARM','ASM','ATG','AUS','AUT','AZE','BDI','BEL','BEN','BES','BFA','BGD','BGR','BHR','BHS',
                                     'BIH','BLM','BLR','BLZ','BMU','BOL','BRA','BRB','BRN','BTN','BWA','CAF','CAN','CHE','CHL',
                                     'CIV','CMR','COD','COG','COK','COL','COM','CPV','CRI','CUB','CUW','CYM','CZE','DEU','DJI',
                                     'DMA','DNK','DOM','DZA','ECU','EGY','ERI','ESH','ESP','EST','ETH','FIN','FJI','FLK','FRA',
                                     'FRO','FSM','GAB','GBR','GEO','GGY','GHA','GIB','GIN','GLP','GMB','GNB','GNQ','GRC','GRD',
                                     'GRL','GTM','GUF','GUM','GUY','HKG','HND','HRV','HTI','IDN','IMN','IRL','IRN','IRQ','ISL',
                                     'ITA','JAM','JOR','JPN','KAZ','KGZ','KHM','KIR','KNA','KOR','KOS','KWT','LAO','LBN','LBR',
                                     'LBY','LCA','LIE','LKA','LSO','LTU','LUX','LVA','MAC','MAF','MAR','MCO','MDA','MDG','MDV',
                                     'MHL','MKD','MLI','MLT','MMR','MNE','MNG','MNP','MOZ','MRT','MSR','MUS','MYS','MYT','NAM',
                                     'NCL','NER','NFK','NGA','NIC','NIU','NLD','NOR','NPL','NRU','NZL','OMN','PAK','PAN','PCN',
                                     'PER','PHL','PLW','PNG','PRI','PRK','PRT','PRY','PSE','PYF','QAT','REU','ROU','RUS','RWA',
                                     'SAU','SDN','SEN','SGP','SHN','SJM','SLB','SLE','SLV','SMR','SOM','SPM','SPR','SSD','STP',
                                     'SUR','SVN','SWE','SWZ','SXM','SYC','SYR','TCA','TCD','TGO','THA','TJK','TKL','TKM','TLS',
                                     'TON','TTO','TUN','TUR','TUV','TWN','TZA','UGA','UKR','URY','USA','UZB','VAT','VCT','VEN',
                                     'VGB','VIR','VNM','VUT','WLF','WSM','YEM','ZAF','ZMB','ZWE')


# Function to get time difference in human readable format
# Input is start time and end time
# If "frm" is set to "hms" then output will be h:m:s
# otherwise only hours will be returned
tmDiff <- function(start, end, frm="hms") {
  
  dsec <- as.numeric(difftime(end, start, units = c("secs")))
  hours <- floor(dsec / 3600)
  
  if (frm == "hms" ){
    minutes <- floor((dsec - 3600 * hours) / 60)
    seconds <- dsec - 3600*hours - 60*minutes
    
    out=paste0(
      sapply(c(hours, minutes, seconds), function(x) {
        formatC(x, width = 2, format = "d", flag = "0")
      }), collapse = ":")
    
    return(out)
  }else{
    return(hours)
  }
}



# wpgpcheckDatasetSum function to check md5 sum 
# of dataset csv file on  WorldPop ftp server
#
# @rdname wpgpCheckDatasetSum
# @return TRUE or FALSE.
wpgpCheckDatasetSum <- function() {

  wpgpDatasets.md5 <- packageDescription("wpgpDownloadR",fields="DatasetSum")
  
  
  wpgpDatasets.md5.tmp <- paste0(tempdir(),"/wpgpDatasets.md5")
  
  wpgpDownloadFileFromFTP("assets/wpgpDatasets.md5", wpgpDatasets.md5.tmp,  quiet=TRUE)
  
  con <- file(wpgpDatasets.md5.tmp,"r")
  wpgpDatasets.md5.check <- readLines(con,n=1)
  close(con)  
  
  # removing tmp file
  if(file.exists(wpgpDatasets.md5.tmp)){ unlink(wpgpDatasets.md5.tmp, recursive = TRUE, force = FALSE)}
  
  if(wpgpDatasets.md5 == wpgpDatasets.md5.check){
    return(TRUE)
  }else{
    return(FALSE)
  }
}



# Function to download file from ftp server
#
# @param file_path is a path to a remoute file
# @param dest_file is a path where downloaded file will be stored
# @param username ftp username to WorldPop ftp server
# @param password ftp password to WorldPop ftp server
# @param quiet If TRUE, suppress status messages (if any), and the progress bar.
# @param method Method to be used for downloading files.
#  Current download methods are "internal", "wininet" (Windows only) "libcurl",
# "wget" and "curl", and there is a value "auto"
# @rdname wpgpDownloadFileFromFTP
#' @importFrom utils read.csv
wpgpDownloadFileFromFTP <- function(file_path, dest_file, quiet, method="auto") {
  
  wpgpFTP <- "ftp.worldpop.org.uk"
  file_remote <-paste0('ftp://',wpgpFTP,'/',file_path)
  
  tmStartDw  <- Sys.time()
  
  checkStatus <- tryCatch(
    {
      utils::download.file(file_remote, destfile=dest_file,mode="wb",quiet=quiet, method=method)
    },
    error=function(cond){
      message(paste("URL does not seem to exist:", file_remote))
      message("Here's the original error message:")
      message(cond)
    },
    warning=function(cond){
      message(paste("URL caused a warning:", file_remote))
      message("Here's the original warning message:")
      message(cond)
    },
    finally={
      if (!quiet){
        tmEndDw  <- Sys.time()
        #message(paste("Processed URL:", file_remote))
        message(paste("It took ", tmDiff(tmStartDw ,tmEndDw,frm="hms"), "to download" ))
      }
    }
  )
  
  if(inherits(checkStatus, "error") | inherits(checkStatus, "warning")){
    return(NULL)
  } else{
    return(1)
  }
}


# wpgpGetDFDatasets function to download csv
# file from WorldPop ftp server
# containing a list of avalible Covariates. The csv file
# will be stored in a temporary R folder with a temporary
# file name and pattern wpgpAllCovariates. This file will be used
# internally during querying and downloading datasets.
#
# @param quiet If TRUE, suppress status messages (if any), and the progress bar.
# @rdname wpgpGetDFDatasets
# @return Data frame of all covariates.
#' @importFrom utils read.csv
wpgpGetDFDatasets <- function(quiet=TRUE) {
  
  if(wpgpCheckDatasetSum()){
    if (!quiet){ message(paste("Datasets up-to-date." )) }  
    return(wpgpDatasets)
  }
  
  
  wpgpAllCSVFilesPath <- paste0(tempdir(),"/wpgpDatasets.csv")
  
  if(!file.exists(wpgpAllCSVFilesPath)){
    
    if (!quiet){ message(paste("Covariates list will be updated" )) }
    
    file_remote <-paste0('assets/wpgpDatasets.csv')
    
    wpgpDownloadFileFromFTP(file_remote, wpgpAllCSVFilesPath, quiet=TRUE)
  }
  
  df.all.Datasets = utils::read.csv(wpgpAllCSVFilesPath, stringsAsFactors=FALSE)
  
  return(df.all.Datasets)
}


#' wpgpListCountries function will return a list of the country
#' avalible to download
#'
#' @param quiet quiet If TRUE, suppress status messages (if any)
#' @rdname wpgpListCountries
#' @return Dataframe
#' @export
wpgpListCountries <- function(quiet=TRUE) {
  
  df <- wpgpGetDFDatasets(quiet)
  
  return(df[!duplicated(df$ISO3), c("ISO","ISO3","Country")])
}



#' wpgpListCountryCovariates function will return a data frame of
#' avalible covariates for a country
#' @param ISO3 a 3-character country code or vector of country codes
#' @rdname wpgpListCountryDatasets
#' @return Dataframe
#' @export
#' @examples
#' wpgpListCountryDatasets(ISO3="NPL")
#' 
#' wpgpListCountryDatasets(ISO3=c("NPL","BTN") )
wpgpListCountryDatasets <- function(ISO3=NULL,quiet=TRUE) {
  
  if (is.null(ISO3))  stop("Enter country ISO3" )
  
  uISO3 <- toupper(ISO3)
  
  if (any(nchar(uISO3)!=3)){
    stop( paste0("Country codes should be three letters. You entered: ", paste(uISO3, collapse=", ")) )
  }
  
  df <- wpgpGetDFDatasets(quiet)
  
  if(any(!uISO3 %in% df$ISO3)){
    warning( paste0("ISO3 code not found: ", paste(uISO3[which(!uISO3 %in% df$ISO3)])) )
  }
  
  df.filtered <- df[df$ISO3 %in% uISO3,] 
  
  if(nrow(df.filtered)<1){
    stop( paste0("No ISO3 code found: ", paste(uISO3, collapse=", ")))
  }
  

  keeps <- c("ISO", "ISO3",  "Country", "Covariate", "Description")
  return(df.filtered[keeps])

}



#' wpgpGetCountryDataset function will download files and return a path  
#' to downloaded file
#' @param ISO3 a 3-character country code or vector of country codes. Optional if df.user supplied
#' @param covariate Covariate name(s). Optional if df.user supplied
#' @param destDir Path to the folder where you want to save raster file
#' @param quiet Download Without any messages if TRUE
#' @param method Method to be used for downloading files. Current download methods
#' are "internal", "wininet" (Windows only) "libcurl", "wget" and
#' "curl", and there is a value "auto"
#' @rdname wpgpGetCountryDataset
#' @return String of file downloaded, including file paths
#' @export
#' @examples
#' wpgpGetCountryDataset('NPL','ppp_2000','E:/WorldPop/')
wpgpGetCountryDataset <- function(ISO3=NULL,
                                  covariate=NULL,
                                  destDir=tempdir(),
                                  quiet=TRUE,
                                  method="auto") {
  
  if (!dir.exists(destDir)) stop( paste0("Please check destDir exists: ", destDir))
  if (is.null(ISO3))  stop("Error: Enter country ISO3" )
  if (is.null(covariate)) stop("Error: Enter covariate" )  
  
  df <- wpgpGetDFDatasets(quiet)
 
  ISO3 <- toupper(ISO3)
  covariate <- tolower(covariate)
  df.filtered <- df[df$ISO3 == ISO3 & df$Covariate == covariate, ]
  
  if (nrow(df.filtered)<1){
    stop( paste0("Entered Covariates: ", paste(covariate, collapse=", ")," not present in WP. Please check name of the dataset"))
  }
  
  file_remote <-  as.character(df.filtered$PathToRaster)
  file_local <- paste0(destDir,'/', ISO3,"_",covariate,'.tif')
  
  ftpReturn <- wpgpDownloadFileFromFTP(file_remote, file_local, quiet=quiet, method=method)
  
  if(!is.null(ftpReturn)){
    return(file_local)
  } else{
    return(NULL)
  }
  
}




#' wpgpGetPOPTable function will download a population csv
#  files from WorldPop ftp server
#' @param ISO3 a 3-character country code
#' @param year Year of the dataset you would like to download. 
#' @param destDir Path to the folder where you want to save poptable file
#' @param quiet Download Without any messages if TRUE
#' @param overwrite Logical. Overwrite the poptable csv file if it already exists
#' @param method Method to be used for downloading files. Current download methods
#' are "internal", "wininet" (Windows only) "libcurl", "wget" and
#' "curl", and there is a value "auto"
#' @rdname wpgpGetPOPTable
#' @return dataframe
#' @export
#' @examples
#' wpgpGetPOPTable("AGO",2000,"E:/WorldPop/")
wpgpGetPOPTable <- function(ISO3=NULL,
                            year=NULL,
                            destDir=tempdir(),
                            quiet=TRUE,
                            overwrite=TRUE,
                            method="auto") {
  
  if (!dir.exists(destDir)) stop( paste0("Please check destDir exists: ", destDir))
  if (is.null(ISO3))  stop("Error: Enter country ISO3" )
  if (is.null(year)) stop("Error: Enter year" )
  
  
  ISO3 <- toupper(ISO3)
  
  if (!is.populated(ISO3)) stop( paste0("Error: WorldPop FTP server Does not have POP table for: ", ISO3))
  
  file_remote <- paste0('GIS/Population/Global_2000_2020/CensusTables/',tolower(ISO3),'_population_2000_2020.csv')
  file_local <- paste0(destDir,'/', tolower(ISO3),'_population_2000_2020.csv')
  
  if (overwrite){
    if(file.exists(file_local)){ unlink(file_local, recursive = TRUE, force = FALSE)} 
  }     
  
  ftpReturn <- wpgpDownloadFileFromFTP(file_remote, file_local, quiet=quiet, method=method)
  
  if(!is.null(ftpReturn)){
    
    df <- utils::read.csv(file_local, stringsAsFactors=FALSE,header = TRUE)
    df <- df[ c('GID', paste0('P_',year)) ]
    colnames(df) <-  c("ADMINID", "ADMINPOP") 
    return(df)
    
  } else{
    return(NULL)
  }
  
}




#' wpgpGetZonalStats function will download a ZonalStats csv
#  files from WorldPop ftp server
#' @param ISO3 a 3-character country code
#' @param covariate Covariate name.
#' @param stat Either as character: 'mean', 'min', 'max', 'sum'.
#' @param destDir Path to the folder where you want to save ZonalStats file
#' @param quiet Download Without any messages if TRUE
#' @param overwrite Logical. Overwrite the ZonalStats csv file if it already exists
#' @param method Method to be used for downloading files. Current download methods
#' are "internal", "wininet" (Windows only) "libcurl", "wget" and
#' "curl", and there is a value "auto"
#' @rdname wpgpGetZonalStats
#' @return dataframe
#' @export
#' @examples
#' wpgpGetZonalStats(ISO3="ABW", covariate="ccilc_dst011_2000", destDir="E:/WorldPop/", stat="mean")
wpgpGetZonalStats <- function(ISO3=NULL,
                              covariate=NULL,
                              stat='mean',
                              destDir=tempdir(),
                              quiet=TRUE,
                              overwrite=TRUE,
                              method="auto") {
  
  if (!dir.exists(destDir)) stop( paste0("Please check destDir exists: ", destDir))
  if (is.null(ISO3))  stop("Error: Enter country ISO3" )
  if (is.null(covariate)) stop("Error: Enter covariate" )
  
  ISO3="ABW"
  covariate="ccilc_dst011_2000"
  destDir="E:/WorldPop/"
  stat="mean"
  
  ISO3 <- toupper(ISO3)
  covariate <- tolower(covariate)
  stat <- tolower(stat)
  
  if (!stat %in% c('mean','max','min','sum')){
    stop("Error: Enter stat, either: 'mean', 'min', 'max', 'sum'" )
  }
  
  #main WorldPop FTP directory with documentation
  url <- paste0('ftp://ftp.worldpop.org.uk/GIS/ZonalStatistics/Global_2000_2020/',ISO3,'/',stat,'/')

  file_zst <- paste0(tolower(ISO3),'_',covariate,'_ZS_',stat,'.csv')   
  filenames <- RCurl::getURL( url , dirlistonly=T )
  filenames <- strsplit(filenames, "\r\n")[[1]]

  if (!file_zst %in% filenames ){
    stop( paste0("Entered Covariates: ", paste(covariate, collapse=", ")," does not have zonal stats present 
                 in WP or ZonalStats was not calcualted. Please check name of the dataset"))
  }  
  
  file_remote <- paste0('GIS/ZonalStatistics/Global_2000_2020/',
                        ISO3,'/',
                        stat,'/', 
                        tolower(ISO3),'_',
                        covariate,'_ZS_',
                        stat,'.csv'
                        )
  
  file_local <- paste0(destDir,'/', tolower(ISO3),'_',covariate,'_ZS_',stat,'.csv')
  
  if (overwrite){
    if(file.exists(file_local)){ unlink(file_local, recursive = TRUE, force = FALSE)} 
  }     
  
  ftpReturn <- wpgpDownloadFileFromFTP(file_remote, file_local, quiet=quiet, method=method)
  
  if(!is.null(ftpReturn)){
    
    df <- utils::read.csv(file_local, stringsAsFactors=FALSE,header = TRUE)
    colnames(df) <-  c("ADMINID", covariate) 
    #remove all 0 adminID 
    return(df[df$ADMINID != 0, ])
    
  } else{
    return(NULL)
  }
  
}



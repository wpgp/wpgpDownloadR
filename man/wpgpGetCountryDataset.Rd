% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wpgpDownloadR.R
\name{wpgpGetCountryDataset}
\alias{wpgpGetCountryDataset}
\title{wpgpGetCountryDataset function will download files and return a path  
to downloaded file}
\usage{
wpgpGetCountryDataset(ISO3 = NULL, covariate = NULL,
  destDir = tempdir(), quiet = TRUE, method = "auto")
}
\arguments{
\item{ISO3}{a 3-character country code or vector of country codes. Optional if df.user supplied}

\item{covariate}{Covariate name(s). Optional if df.user supplied}

\item{destDir}{Path to the folder where you want to save raster file}

\item{quiet}{Download Without any messages if TRUE}

\item{method}{Method to be used for downloading files. Current download methods
are "internal", "wininet" (Windows only) "libcurl", "wget" and
"curl", and there is a value "auto"}
}
\value{
String of file downloaded, including file paths
}
\description{
wpgpGetCountryDataset function will download files and return a path  
to downloaded file
}
\examples{
wpgpGetCountryDataset('NPL','ppp_2000','E:/WorldPop/')
}

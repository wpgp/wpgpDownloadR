wpgpDownloadR
===================
wpgpCovariates is an R Package interface for downloading raster datasets from [WorldPop](http://www.worldpop.org.uk/) FTP.

What is WorldPop?
High spatial resolution, contemporary data on human population distributions are a prerequisite for the accurate measurement of the impacts of population growth, for monitoring changes and for planning interventions. The WorldPop project aims to meet these needs through the provision of detailed and open access population distribution datasets built using transparent approaches.

Installation
------------

**Installation**
wpgpCovariates isn't available from CRAN yet, but you can get it from github with:

    install.packages("devtools")
    devtools::install_github("wpgp/wpgpDownloadR")
    
    # load package
    library(wpgpDownloadR)
    
**Basic usage**

After installation you should be able to use five main functions from the library:

 - wpgpListCountries
 - wpgpListCountryDatasets
 - wpgpGetCountryDataset
 - wpgpGetPOPTable
 - wpgpGetZonalStats

----------

**wpgpListCountries** will return a dataframe with all ISO3 available on WorldPop ftp server.
```
wpgpListCountries()
      
      
      ISO3 ISOnumber                                  NameEnglish
1      ABW       533                                        Aruba
51     AFG         4                                  Afghanistan
101    AGO        24                                       Angola
151    AIA       660                                     Anguilla
201    ALA       248                                land Islands
251    ALB         8                                      Albania
301    AND        20                                      Andorra
.....
```


----------

**wpgpListCountryDatasets** will return a dataframe of available covariates to download from WorldPop FTP for a country. This function could be used to query the name of the dataset which then could be downloaded for a country.
```
wpgpListCountryDatasets(ISO3="NPL")

ISO3 ISOnumber     CvtName           Year    Description
NPL  524           ccidadminl0       2000    Mastergrid ISO 
NPL  524           ccilc_dst011_2000 2000    Distance to cultivated ..
....
```
----------

**wpgpGetCountryDataset** will download a raster dataset based on ISO and covariate name.

```
> df <- wpgpGetCountryDataset(ISO3 = "NPL",
                                covariate = "ccilc_dst011_2000"
                                destDir ="G:\\WorldPop_Data")
						 
> df
$ISO3
[1] "NPL"

$CvtName
[1] "ccilc_dst011_2000"

$RstName
[1] "npl_grid_100m_ccilc_dst011_2000"

$filepath
[1] "G:\\WorldPop_Data/npl_grid_100m_ccilc_dst011_2000.tif"      

```


**wpgpGetPOPTable** will download a CSV file of population based on ISO and covariate name. Function will return a dataframe with two columes "ADMINID", "ADMINPOP"

```
> df <- wpgpCovariates::wpgpGetPOPTable("AGO",2000,"G:/WorldPop_Data/")
						 
> df
 ADMINID    ADMINPOP
1    241457   34970.426
2    241458  349494.179
3    241459    7977.856
4    241460    2681.160
5    241461   97864.592
6    241462   77712.153
```

----------

**wpgpGetZonalStats** will download a CSV file of ZonalStats based on ISO and covariate name. Function will return a dataframe with two columes "ADMINID", and name of the covariate 

```
> df <- wpgpGetZonalStats("AGO","ccilc_dst011_2000", stat = "mean" ,"G:/WorldPop_Data/")
						 
> df
 ADMINID    ccilc_dst011_2000
1    241457  1.56037065
2    241458  1.56037065
3    241459  1.61910718
4    241460  1.19869991
5    241461  0.85845653
6    241462  2.56389180
```



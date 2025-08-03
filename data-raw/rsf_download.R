## download datasets from RSF website

url <- "https://rsf.org/sites/default/files/import_classement/"

rsf_year <- function(year) {
    rsf_name <- paste0(url, year, ".csv")
    readr::read_delim(rsf_name,
                      delim = ";", escape_double = FALSE, trim_ws = TRUE)
}


my_year <- list(
    "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010",
    # 2011 is missing
    "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020",
    "2021", "2022", "2023", "2024", "2025")

for (i in 1:length(my_year)) {
    my_name <- paste0("rsf", my_year[[i]])
    assign(my_name,  rsf_year(my_year[[i]]))
}

## download unsd-m49 file ############
url_m49 <- "https://github.com/omnika-datastore/unsd-m49-standard-area-codes/raw/refs/heads/main/2022-09-24__CSV_UNSD_M49.csv"

downloader::download(
    url = url_m49,
    destfile = "m49.csv"
)


## create R object ###############
m49 <-
    readr::read_delim(
        file = "m49.csv",
        delim = ";"
    )




usethis::use_data(
    rsf2002, rsf2003, rsf2004, rsf2005, rsf2006, rsf2007, rsf2008,
    rsf2009, rsf2010, rsf2012, rsf2013, rsf2014, rsf2015, rsf2016,
    rsf2017, rsf2018, rsf2019, rsf2020, rsf2021, rsf2022, rsf2023,
    rsf2024, rsf2025, m49, internal = TRUE, compress = "xz"
    )




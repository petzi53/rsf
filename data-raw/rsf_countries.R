## add ISO m49 country codes and regional names to RSF data

###########################################################
## recode m49 for my use case

m49_rec <- m49 |>
    dplyr::select(
        `ISO-alpha3 Code`,
        `Country or Area`,
        `Region Name`,
        `Sub-region Name`,
        `Intermediate Region Name`
    ) |>
    dplyr::filter(`Country or Area` != "Antarctica") |>
    dplyr::mutate(`Intermediate Region Name` =
        base::ifelse(is.na(`Intermediate Region Name`),
             `Sub-region Name`, `Intermediate Region Name`)
    ) |>
    dplyr::rename(
        ISO = `ISO-alpha3 Code`,
        Country = `Country or Area`,
        Region = `Region Name`,
        Subregion = `Sub-region Name`,
        `Intermediate Region` = `Intermediate Region Name`
        )

#############################################################
## left join with cleaned rsf dataset
## take rsf2025_clean as example
rwb2025 <- dplyr::left_join(
    rsf2025_clean, m49_rec, "ISO"
)

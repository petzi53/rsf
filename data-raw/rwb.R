
load("R/sysdata.rda")

###########################################################
## recode m49 for my use case

m49_recoded <- function(df) {
    df |>
        janitor::clean_names() |>
        dplyr::filter(country_or_area != "Antarctica") |>
        dplyr::mutate(intermediate_region_name =
                          base::ifelse(is.na(intermediate_region_name),
                                       sub_region_name, intermediate_region_name)
        ) |>
        dplyr::select(
            iso_alpha3_code,
            country_or_area,
            region_name,
            sub_region_name,
            intermediate_region_name
        ) |>
        dplyr::rename(iso = iso_alpha3_code) |>
        dplyr::rename_with(function(x) {gsub("_name","",x)})
}

## clean rsf data file
## Trailing zeros are not displayed,
##     the score of these values is  therefore  10 times too big
## Some values display one decimal place without comma
##     to distinguish two countries with similar values
##     they are therefore (10 or 100 times) too large
##  PROCEDURE
## 1. Select columns
## 2. Reorder columns
## 3. Recode values
## 4. Clean entries with accents

library(dplyr, warn.conflicts = FALSE)

df_recoded <- function(df, col_name) {
    df |>
        mutate(
            "{{col_name}}" := if_else({{col_name}} < 100, {{col_name}} * 100, {{col_name}}),
            "{{col_name}}" := if_else({{col_name}} < 1000, {{col_name}} * 10, {{col_name}}),
            "{{col_name}}" := if_else({{col_name}} > 10000, round({{col_name}} / 10), {{col_name}}),
            "{{col_name}}" := {{col_name}} / 100,
            "{{col_name}}_situation" := case_when(
                {{col_name}} >= 85 ~ "1. Good",
                {{col_name}} >= 70 & {{col_name}} <= 84.99 ~ "2. Rather Good",
                {{col_name}} >= 55 & {{col_name}} <= 69.99 ~ "3. Problematic",
                {{col_name}} >= 40 & {{col_name}} <= 54.99 ~ "4. Difficult",
                {{col_name}} <= 39.99 ~ "5. Very Serious"
            )
        ) |>
        relocate(last_col(), .after = {{col_name}})
}

rwb_new <- function(df) {
    df |>
        janitor::clean_names() |>
        rename_with(function(x){gsub("_context","", x)}) |>
        left_join(m49_recoded(m49), "iso") |>
        select(-c(country_fr, country_es:country_fa)) |>
        relocate(year_n) |>
        df_recoded(score) |>
        df_recoded(political) |>
        df_recoded(economic) |>
        df_recoded(legal) |>
        df_recoded(social) |>
        df_recoded(safety)
}

rwb_old <- function(df) {
    df |>
        janitor::clean_names() |>
        rename_with(function(x){gsub("_context","", x)}) |>
        left_join(m49_recoded(m49), "iso") |>
        select(-c(fr_country, es_country:fa_country)) |>
        relocate(year_n) |>
        df_recoded(score_n) |>
        rename(country_en = en_country)
}

rwb2021 <- rwb_old(rsf2021)

rwb2021_short <- rwb2021 |>
    select(c(iso, score_n, score_n_situation)) |>
    rename(
        score_n_1 = score_n,
        score_n_1_situation = score_n_situation
        )

rwb2022 <- rwb_new(rsf2022) |>
    left_join(rwb2021_short, "iso") |>
    mutate(
        score_evolution = score - score_n_1
    ) |>
    relocate(score_n_1:score_evolution, .after = rank_evolution)

rwb2023 <- rwb_new(rsf2023) |>
    df_recoded(score_n_1) |>
    mutate(score_evolution =
               as.double(stringr::str_replace(score_evolution, ",", "."))
    )


rwb2024 <- rwb_new(rsf2024) |>
    select(-situation) |>
    df_recoded(score_n_1) |>
    mutate(score_evolution =
               as.double(stringr::str_replace(score_evolution, ",", "."))
    )

rwb2025 <- rsf2025 |>
    rename(Score = `Score 2025`) |>
    rwb_new() |>
    mutate(
        country_en = case_when(
        stringr::str_detect(country_en, "d'Ivoire") ~ "Côte d'Ivoire",
        stringr::str_detect(country_en, "rkiye") ~ "Türkiye",
        .default = country_en
    ),
        zone = if_else(stringr::str_detect(zone, "riques"),
                "Amériques", zone)
    )



## clean 2025 data file
## Trailing zeros are not displayed,  t
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


rsf2025_clean <- rsf2025 |>
    select(-c(Country_FR, Country_ES:Country_FA)) |>
    rename(Score = `Score 2025`) |>
    relocate(Country_EN:`Year (N)`, .after = ISO) |>
    mutate(
        Score = if_else(Score < 1000, Score * 10, Score),
        Score = if_else(Score > 10000, round(Score / 10), Score),
        `Political Context` = case_when(
            `Political Context` == 913 ~ 9130,
            `Political Context` == 857 ~ 8570,
            `Political Context` == 637 ~ 6370,
            `Political Context` == 591 ~ 5910,
            `Political Context` == 485 ~ 4850,
            `Political Context` == 419 ~ 4190,
            `Political Context` == 389 ~ 3890,
            `Political Context` == 361 ~ 3610,
            `Political Context` == 331 ~ 3310,
            `Political Context` == 309 ~ 3090,
            `Political Context` == 274 ~ 2740,
            `Political Context` == 26 ~  2600,
            `Political Context` == 243 ~ 2430,
            `Political Context` == 237 ~ 2370,
            `Political Context` == 145 ~ 1450,
            `Political Context` == 14 ~  1400,
            .default = `Political Context`
        ),
        `Political Context` =
            if_else(`Political Context` > 10000,
                round(`Political Context` / 10),
                `Political Context`
            ),
        `Economic Context` =
            if_else(`Economic Context` < 100,
                    `Economic Context` * 100,
                    `Economic Context`),
        `Economic Context` =
            if_else(`Economic Context` < 1000,
                    `Economic Context` * 10,
                    `Economic Context`),
        `Economic Context` =
            if_else(`Economic Context` > 10000,
                    round(`Economic Context` / 10),
                    `Economic Context`),
        `Legal Context` =
            if_else(`Legal Context` < 100,
                    `Legal Context` * 100,
                    `Legal Context`),
        `Legal Context` =
            if_else(`Legal Context` < 835,
                    `Legal Context` * 10,
                    `Legal Context`),
        `Legal Context` =
            if_else(`Legal Context` > 10000,
                    round(`Legal Context` / 10),
                    `Legal Context`),
        `Social Context` =
            if_else(`Social Context` < 100,
                    `Social Context` * 100,
                    `Social Context`),
        `Social Context` =
            if_else(`Social Context` < 946,
                    `Social Context` * 10,
                    `Social Context`),
        `Social Context` =
            if_else(`Social Context` > 10000,
                    round(`Social Context` / 10),
                    `Social Context`),
        Safety =
            if_else(Safety < 100,
                    Safety * 100,
                    Safety),
        Safety =
            if_else(Safety < 1000,
                    Safety * 10,
                    Safety),
        Safety =
            if_else(Safety > 10000,
                    round(Safety / 10),
                    Safety),
        Country_EN = case_when(
            stringr::str_detect(Country_EN, "d'Ivoire") ~ "Côte d'Ivoire",
            stringr::str_detect(Country_EN, "rkiye") ~ "Türkiye",
            .default = Country_EN
            ),
        Zone =
            if_else(stringr::str_detect(Zone, "riques"),
                    "Amériques", Zone)
    )


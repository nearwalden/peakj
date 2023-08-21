# This has the info about all of the key files for `peakj`

# Note: I don't like how this is coming out, need a database or something

# basepath of the data directories
data_basepath = "/Users/dd/pCloud Drive/data/population/"

# Gates foundation population data
bmgf = Dict(
    "path" => "gatesfoundation/",
    "files" => Dict(
        "pop_data" => "IHME_POP_2017_2100_POP_BOTH_SEX_ALL_AGE_Y2020M05D01.csv"
    ),
    "collections" => Dict(
        "global_pop" => Dict(
            "basepath" => "IHME_POP_2017_2100_GLOBAL_{}.csv",
            "vals" => ["SLOWER", "REFERENCE", "FASTER", "SDG"]
        ),
        "country_pop" => Dict(
            "basepath" => "IHME_POP_2017_2100_COUNTRY_{}.csv",
            "vals" => ["SLOWER", "REFERENCE", "FASTER", "SDG"]
        )
    )
)

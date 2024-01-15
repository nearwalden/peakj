# This has the info about all of the key files for `peakj`

using DataFrames

# Note: I don't like how this is coming out, need a database or something

# basepath of the data directories
data_basepath = "/Users/dd/pCloud Drive/data/population/"

# Gates foundation population data
bmgf = Dict(
    "path" => "gatesfoundation/",
    "basepath" => data_basepath,
    "files" => Dict(
        "pop_data" => "IHME_POP_2017_2100_POP_BOTH_SEX_ALL_AGE_Y2020M05D01.csv"
    ),
    "collections" => Dict(
        "global_pop" => Dict(
            "basepath" => ["IHME_POP_2017_2100_GLOBAL_", ".csv"],
            "vals" => ["SLOWER", "REFERENCE", "FASTER", "SDG"]
        ),
        "country_pop" => Dict(
            "basepath" => ["IHME_POP_2017_2100_COUNTRY_", ".csv"],
            "vals" => ["SLOWER", "REFERENCE", "FASTER", "SDG"]
        )
    )
)



# Wittgenstein Center population data
witt = Dict(
    "path" => "wittgenstein-center/",
    "basepath" => data_basepath,
    "files" => Dict(
        "recode" => "recode file.csv"
    ),
    "collections" => Dict(
        "all_pop" => Dict(
            "basepath" => ["ssp", "epop_wide.csv"],
            "vals" => ["1", "2", "3", "4", "5"]
        ),
         "global_pop" => Dict(
            "basepath" => ["ssp", "epop_global.csv"],
            "vals" => ["1", "2", "3", "4", "5"]
        ),
        "country_pop" => Dict(
            "basepath" => ["ssp", "epop_country.csv"],
            "vals" => ["1", "2", "3", "4", "5"]
        )
    )
)

# UN data 2019
un2019 = Dict(
    "path" => "un-wpp2019/",
    "basepath" => data_basepath,
    "collections" => Dict(
        "all_pop" => Dict(
            "basepath" => ["WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES_", ".csv"],
            "vals" => ["high", "medium", "low"]
        ),
         "global_pop" => Dict(
            "basepath" => ["WPP2019_POP_GLOBAL_", ".csv"],
            "vals" => ["high", "medium", "low"]
        ),
        "country_pop" => Dict(
            "basepath" => ["WPP2019_POP_COUNTRY_", ".csv"],
            "vals" => ["high", "medium", "low"]
        )
    )
)


# UN data 2022
un2022 = Dict(
    "path" => "un-wpp2022/",
    "basepath" => data_basepath,
    "collections" => Dict(
        "all_pop" => Dict(
            "basepath" => ["WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_REV1_POP_", ".csv"],
            "vals" => ["high", "medium", "low"]
        ),
         "global_pop" => Dict(
            "basepath" => ["WPP2022_POP_GLOBAL_", ".csv"],
            "vals" => ["high", "medium", "low"]
        ),
        "country_pop" => Dict(
            "basepath" => ["WPP2022_POP_COUNTRY_", ".csv"],
            "vals" => ["high", "medium", "low"]
        )
    )
)

# place for results
res = Dict(
    "path" => "results/",
    "basepath" => data_basepath
)

# list of all datasets
datasets = Dict(
    "bmgf_population" => bmgf, 
    "witt_population" => witt, 
    "un_population_2019" => un2019,
    "un_population_2022" => un2022,            
    "results" => res
)

# get file path
function getfilepath(dataset, name)
    ds = datasets[dataset]
    datasetpath = ds["basepath"] * ds["path"]
    filepath = ds["files"][name]
    return(datasetpath * filepath)
end

# get collection file path
function getcollfilepath(dataset, coll, val)
    ds = datasets[dataset]
    datasetpath = ds["basepath"] * ds["path"]
    basefilepath = ds["collections"][coll]["basepath"]
    filepath = basefilepath[1] * val * basefilepath[2]
    return(datasetpath * filepath)
end

# get possible values for a collection
function getcollvalues(dataset, coll)
    ds = datasets[dataset]
    return(ds["collections"][coll]["vals"])
end

# similar to above but return DataFrames
function getdf(dataset, name)
    path = getfilepath(dataset, name)
    return(DataFrame(CSV.File(path)))
end

# same for collections
# similar to above but return DataFrames
function getcolldf(dataset, coll, val)
    path = getcollfilepath(dataset, coll, val)
    return(DataFrame(CSV.File(path)))
end
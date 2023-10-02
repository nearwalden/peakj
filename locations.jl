# normalize locations

# from prefect import task, Flow
# from atlas import data
using DataFrames
using CSV
include("files.jl")

worldnames = Dict(
    "bmgf" => "Global",
    "un2019" => "WORLD",
    "un2022" => "WORLD",
    "witt" => "WORLD"
)

# vector of unique locaiotn names
function bmgflocationnames()
    df = DataFrame(CSV.File(getfilepath("bmgf_population", "pop_data")))
    return(unique(df.location_name))
end

# all locations in a DataFrame
function wittlocations()
    df = DataFrame(CSV.File(getfilepath("witt_population", "recode")))
    datadf = DataFrame(CSV.File(getcollfilepath("witt_population", "all_pop", "1")))
    dfl = subset(df, :dim => d -> d .== "isono")
    outdf = DataFrame(name=String[], code=Int[])
    for row in eachrow(dfl)
        count = nrow(subset(datadf, :isono => d -> d .== row.code))
        if count > 0
            push!(outdf, (row.name, row.code))
        end
    end
    return outdf
end

# all locations in a DataFrame
function un2019locations()
    df = DataFrame(CSV.File(getcollfilepath("un_population_2019", "all_pop", "high")))
    dfg = groupby(df, :Region)
    outdf = combine(dfg, first)
    return outdf   
end

# country names in a vector
function un2019countrynames()
    df = un2019locations()
    countries = subset(df, :Type => t -> t .== "Country/Area")
    return unique(countries.Region)
end

# locations for un2022
function un2022locations()
    df = DataFrame(CSV.File(getcollfilepath("un_population_2022", "all_pop", "high")))
    dfg = groupby(df, :Region)
    outdf = combine(dfg, first)
    return outdf   
end

# un2022 country names
function un2022countrynames()
    df = un2022locations()
    countries = subset(df, :Type => t -> t .== "Country/Area")
    return unique(countries.Region)
end

function comparenames(names, dataset, un)
    not1 = []
    only1 = []
    both = []
    unlist = un.Region
    for item in names
        if item in unlist
            push!(both, item)
        else
            push!(only1, item)
        end
    end
    for item in unlist
        if item ∉ names   # not in
            push!(not1, item)
        end
    end
    out = Dict(dataset => only1,
            "un" => not1,
            "both" => both
    )
    return out
end


function compareallnames(b, w, u)
    bu = comparenames(b, "bmgf", u)
    wu = comparenames(w.name, "witt", u)
    print("BU = " * repr(length(bu["both"])) * ", WU = " * repr(length(wu["both"]))) 
    alllen = 0
    for item in bu["both"]
        if item in wu["both"]
            alllen += 1
        end
    end
    print(", All = " * repr(alllen))
end


function comparenumbers(witt, un)
    not1 = []
    only1 = []
    both = []
    un_list = un."Country code"
    witt_list = witt.code
    for item in witt_list
        if item in un_list
            push!(both, item)
        else
            push!(only1, item)
        end
    end
    for item in un."Country code"
        if item ∉ witt.code
            push!(not1, item)
        end
    end
    out = Dict("witt" => only1,
            "un" => not1,
            "both" => both
    )
    return out
end


# returns a list of common countries
function countries()
    uc2019 = un2019countrynames()
    uc2022 = un2022countrynames()
    b = bmgflocationnames()
    w = wittlocations().name
    common = intersect(uc2019, uc2022, b, w)
    return common
end
    
# returns a list of common countries
function uncountries()
    uc2019 = un2019countrynames()
    uc2022 = un2022countrynames()
    common = intersect(uc2019, uc2022)
    return common
end


# get UN isono from country name
function countrycode(country)
    df = DataFrame(CSV.File(getfilepath("witt_population", "recode")))
    row = df[findfirst(==(country), df.name), :]
    return row.code
end


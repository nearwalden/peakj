# Make clean files

using DataFrames
using CSV
using Interpolations

include("locations.jl")
include("files.jl")

# All

GLOBALCOLS = ["scenario", "year", "population"]

# # BMFG data cleaning

BMGFSCENARIOS = Dict(
    "SLOWER" => -1,
    "REFERENCE" => 0,
    "FASTER" => 1,
    "SDG" => 2
)

BMGFMAP = Dict(
    "scenario" => "scenario_id",
    "year_id" => "year",
    "val" => "population",
    "location_name" => "location_name"
)


function bmgfglobal()
    ds = "bmgf_population"
    orig = getdf(ds, "pop_data")
    # get global
    origg = orig[orig.location_id .== 1, :]
    # start with 2020
    origg = origg[origg.year_id .> 2019, :]
    # get right columns
    norm = rename(origg, BMGFMAP)
    # do scenarios in order
    for scenario in keys(BMGFSCENARIOS)
        outpath = getcollfilepath(ds, "global_pop", scenario)
        # pick out scenario
        norms = norm[norm.scenario_id .== BMGFSCENARIOS[scenario], :]
        norms.scenario .= scenario
        # norms.population = norm.population
        CSV.write(outpath, norms)
        print("Wrote " * string(nrow(norms)) * " records for " * scenario * "\n")
    end
    return(true)
end

# cleaned up version of BMGF, can have it drop some columns
function bmgfcountries()
    ds = "bmgf_population"
    commoncountries = countries()
    orig = getdf(ds, "pop_data")
    # start with 2020
    orig = orig[orig.year_id .> 2019, :]
    # get right columns
    norm = rename(orig, BMGFMAP)
    # do scenarios in order
    for scenario in keys(BMGFSCENARIOS)
        outpath = getcollfilepath(ds, "country_pop", scenario)
        # pick out scenario
        norms = norm[norm.scenario_id .== BMGFSCENARIOS[scenario], :]
        # norms = norms.set_index('year')
        outdf = DataFrame()
        for country in commoncountries
            normc = norms[norms.location_name .== country, :]
            for row in eachrow(normc)
                push!(outdf, row)
            end
        end
        CSV.write(outpath, outdf)
        print("Wrote " * string(nrow(outdf)) * " records for " * scenario * "\n")
    end
    return(true)
end


# UN data cleaning

UNSCENARIOS = ["high", "medium", "low"]

UN2019DROPS = ["Variant", "Notes", "Country code", "Type", "Parent code"]

UN2022DROPS = ["Variant", "Notes", "Location code", "Type"]

# function to cleanup population data for UN
function unpopcleanup(val)
    # print(val * "\n")
    newstr = replace(val, " " => "")
    return(parse.(Int, newstr) * 1000)
end

# clean up the 2019 version
function un2019global()
    ds = "un_population_2019"
    scenarios = getcollvalues(ds, "all_pop")
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "global_pop", scenario)
        # get global
        select!(orig, Not(UN2019DROPS))
        world = orig[orig.Region .== "WORLD", :]
        # select!(world, Not(:Region))
        new = permutedims(world, :Region, :year)
        rename!(new, :WORLD => :population)
        transform!(new, :population => ByRow(x -> unpopcleanup(x)) => :population)
        new.scenario .= scenario
        CSV.write(outpath, new)
        print("Wrote " * string(nrow(new)) * " records for " * scenario * "\n")
    end
    return(true)
end

function un2019countries()
    ds = "un_population_2019"
    commoncountries = countries()    
    scenarios = getcollvalues(ds, "all_pop")
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "country_pop", scenario)
        # get global
        select!(orig, Not(UN2019DROPS))
        origcountries = filter(:Region => c -> c in commoncountries, orig)
        new = permutedims(origcountries, :Region, :year)
        for country in commoncountries
            transform!(new, country => ByRow(x -> unpopcleanup(x)) => country)
        end
        new.scenario .= scenario
        CSV.write(outpath, new)
        print("Wrote " * string(nrow(new)) * " records for " * scenario * "\n")
    end
    return(true)
end

# clean up the 2022 version


function un2022global()
    ds = "un_population_2022"
    scenarios = getcollvalues(ds, "all_pop")
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "global_pop", scenario)
        # get global
        new = orig[orig.Region .== "WORLD", :]
        transform!(new, :population => ByRow(x -> unpopcleanup(x)) => :population)
        new.sceenario .= scenario
        CSV.write(outpath, new)
        print("Wrote " * string(nrow(new)) * " records for " * scenario * "\n")
    end
    return(true)
end


function un2022countries()
    ds = "un_population_2022"
    commoncountries = countries()    
    scenarios = getcollvalues(ds, "all_pop")
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "country_pop", scenario)
        # setup new dataframe
        new = DataFrame()
        new.year = orig[orig.Region .== "WORLD", :].year
        new.scenario .= scenario       
        for country in commoncountries
            countrydf = orig[orig.Region .== country, :]
            # fix all of the population values
            transform!(countrydf, :population => ByRow(x -> unpopcleanup(x)) => :population)
            new[:, country] = countrydf.population
        end
        CSV.write(outpath, new)
        print("Wrote " * string(nrow(new)) * " records for " * scenario * "\n")
    end
    return(true)
end


# # Witt data cleaning

WITTDROPS = ["Variant", "Notes", "Country code", "Type", "Parent code"]

# This currently won't run because I lost the origina source file....
function wittglobal()
    ds = "witt_population"
    scenarios = getcollvalues(ds, "all_pop")
    agedrops = []
    # create list of ages
    for i in range(1, 21)
        push!(agedrops, "ageno_" * string(i))
    end
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "global_pop", scenario)
        # get global
        select!(orig, Not(agedrops))
        world = orig[(orig.eduno .== 0) .& (orig.sexno .== 0) .& (orig.isono .== 900), :]
        interp = linear_interpolation(world.year, world.ageno_0)
        out = DataFrame(year=Int[], scenario=Int[], population=Int[])
        for year in range(2020, 2100)
            pop = interp(year) * 1000
            push!(out, [year, parse(Int, scenario), convert(Int, round(pop))])
        end
        CSV.write(outpath, out)
        print("Wrote " * string(nrow(out)) * " records for " * string(scenario) * "\n")
    end
    return(true)
end

# this won't run because I don't have the original source file on my laptop
function witt_countries()
    ds = "witt_population"
    countries = countries()
    scenarios = getcollvalues(ds, "all_pop")
    agedrops = []
    for i in range(1, 21)
        push!(agedrops, "ageno_" * string(i))
    end
    for scenario in scenarios
        orig = getcolldf(ds, "all_pop", scenario)
        outpath = getcollfilepath(ds, "country_pop", scenario)
        # get global
        select!(orig, agedrops)
        outdf = DataFrame()
        outdf.year = 2020:2100
        # print (outdf)
        for country in countries
            code = countrycode(country)
            countrypop = orig[(orig.eduno .== 0) .& (orig.sexno .== 0) .& (orig.isono .== code)]
            interp = linear_interpolation(countrypop.year, countrypop.ageno_0)
            for year in range(2020, 2100)
                pop = interp(year) * 1000
                push!(out, pop)
            end
            outdf.country = out
        end
        CVS.write(outpath, outdf)
        print("Wrote " * string(nrows(out)) * " records for " + string(scenario) * "\n")
    end
    return(true)
end

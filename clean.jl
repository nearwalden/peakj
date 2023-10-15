# Make clean files

using DataFrames
using CSV

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


# clean up the 2019 version
function un2019global()
    ds = "un_population_2019"
    scenarios = getcollvals(ds, "all_pop")
    for scenario in scenarios:
        orig = getcolldf(ds, "all_pop", scenario))
        outpath = getcollfilepath(ds, "global_pop", scenario)
        # get global
        orig = orig.drop(UN2019DROPS, 1)
        world = orig[orig.Region == "WORLD"]
        new = world.drop('Region', 1).T
        new = new.reset_index()
        out = DataFrame()
        out.population = new[0].map(lambda x: int(x.replace(' ','')) * 1000)
        out.year = new['index']
        out.scenario = scenario
        out.to_csv(out_path)
        print("Wrote " + str(len(out)) + " records for " + scenario)
    return True

# def un2019_countries():
#     ds = 'un_population_2019'
#     countries = locations.countries()    
#     scenarios = files.get_coll_vals(ds, 'all_pop')
#     for scenario in scenarios:
#         orig = p.read_csv(files.get_coll_file_path(ds, 'all_pop', scenario))
#         out_path = files.get_coll_file_path(ds, 'country_pop', scenario)
#         # get global
#         orig = orig.drop(UN2019_DROPS, axis=1)
#         out = p.DataFrame()
#         first_country = True
#         for country in countries:
#             countrydf = orig[orig.Region == country].copy()
#             new = countrydf.drop('Region', axis=1).T
#             country_code = new.columns[0]
#             new = new.reset_index()
#             out[country] = new[country_code].map(lambda x: int(x.replace(' ','')) * 1000)
#             if first_country:
#                 out['year'] = new['index']
#             first_country = False
#             out = out.copy()
#         out['scenario'] = scenario
#         out.to_csv(out_path)
#         print("Wrote " + str(len(out)) + " records for " + scenario)
#     return True

# # clean up the 2022 version


# def un2022_global():
#     ds = 'un_population_2022'
#     scenarios = files.get_coll_vals(ds, 'all_pop')
#     for scenario in scenarios:
#         orig = p.read_csv(files.get_coll_file_path(ds, 'all_pop', scenario))
#         out_path = files.get_coll_file_path(ds, 'global_pop', scenario)
#         # get global
#         world = orig[orig.Region == 'WORLD']
#         out = p.DataFrame()
#         out['population'] = world['population'].map(lambda x: int(x.replace(' ','')) * 1000)
#         out['year'] = world['year']
#         out['scenario'] = scenario
#         out.to_csv(out_path)
#         print("Wrote " + str(len(out)) + " records for " + scenario)
#     return True


# def un2022_countries():
#     ds = 'un_population_2022'
#     countries = locations.countries()    
#     scenarios = files.get_coll_vals(ds, 'all_pop')
#     for scenario in scenarios:
#         orig = p.read_csv(files.get_coll_file_path(ds, 'all_pop', scenario))
#         out_path = files.get_coll_file_path(ds, 'country_pop', scenario)
#         out = p.DataFrame()
#         first_country = True
#         for country in countries:
#             countrydf = orig[orig.Region == country].copy()
#             out[country] = countrydf['population'].map(lambda x: int(x.replace(' ','')) * 1000).values
#             if first_country:
#                 out['year'] = orig['year']
#             first_country = False
#             out = out.copy()
#         out['scenario'] = scenario
#         out.to_csv(out_path)
#         print("Wrote " + str(len(out)) + " records for " + scenario)
#     return True

# # Witt data cleaning

# WITT_DROPS = ['Variant', 'Notes', 'Country code', 'Type', 'Parent code']


# def witt_global():
#     ds = 'witt_population'
#     scenarios = files.get_coll_vals(ds, 'all_pop')
#     age_drops = []
#     for i in range(1, 22):
#         age_drops.append('ageno_' + str(i))
#     for scenario in scenarios:
#         orig = p.read_csv(files.get_coll_file_path(ds, 'all_pop', scenario))
#         out_path = files.get_coll_file_path(ds, 'global_pop', scenario)
#         # get global
#         orig = orig.drop(age_drops, 1)
#         world = orig[(orig.eduno == 0) & (orig.sexno == 0) & (orig.isono == 900)]
#         fit = np.polyfit(world.year, world.ageno_0, 2)
#         out = []
#         for year in range(2020, 2101):
#             pop = (fit[0] * np.square(year) + fit[1] * year + fit[2]) * 1000
#             out.append({
#                 'year': year,
#                 'scenario': scenario,
#                 'population': pop})
#         outdf = p.DataFrame(out)
#         outdf.to_csv(out_path)
#         print("Wrote " + str(len(out)) + " records for " +str(scenario))
#     return True


# def witt_countries():
#     ds = 'witt_population'
#     countries = locations.countries()
#     scenarios = files.get_coll_vals(ds, 'all_pop')
#     age_drops = []
#     for i in range(1, 22):
#         age_drops.append('ageno_' + str(i))
#     for scenario in scenarios:
#         orig = p.read_csv(files.get_coll_file_path(ds, 'all_pop', scenario))
#         out_path = files.get_coll_file_path(ds, 'country_pop', scenario)
#         # get global
#         orig = orig.drop(age_drops, 1)
#         outdf = p.DataFrame()
#         outdf['year'] = np.arange(2020, 2101, 1)
#         # print (outdf)
#         for country in countries:
#             code = locations.country_code(country)
#             country_pop = orig[(orig.eduno == 0) & (orig.sexno == 0) & (orig.isono == code)]
#             fit = np.polyfit(country_pop.year, country_pop.ageno_0, 2)
#             out = []
#             for year in range(2020, 2101):
#                 pop = (fit[0] * np.square(year) + fit[1] * year + fit[2]) * 1000
#                 out.append(pop)
#             outdf[country] = out
#         outdf.to_csv(out_path)
#         print("Wrote " + str(len(out)) + " records for " +str(scenario))
#     return True

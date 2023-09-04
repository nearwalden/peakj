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

# all region names
function un2019regionnames()
    df = un2019_locations()
    return subset(df, :Type => t -> t .== "Region").Region
end


# def un2019_subregion_names():
#     df = un2019_locations()
#     return df[df.Type == 'Subregion']['Region'].to_list()


# def un2022_locations():
#     df = p.read_csv(files.get_coll_file_path('un_population_2022', 'all_pop', 'high'))
#     dfg = df.groupby('Region')
#     outdf = p.DataFrame()
#     outdf = dfg.first()
#     outdf = outdf.reset_index()
#     return outdf   #  outdf[outdf['Type'] == 'Country/Area'].copy()


# def un2022_country_names():
#     df = un2022_locations()
#     return df[df.Type == 'Country/Area']['Region'].to_list()


# def un2022_region_names():
#     df = un2022_locations()
#     return df[df.Type == 'Region']['Region'].to_list()


# def un2022_subregion_names():
#     df = un2022_locations()
#     return df[df.Type == 'Subregion']['Region'].to_list()


# def compare_names(names, dataset, un2019):
#     not1 = []
#     un2019_list = un2019['Region'].to_list()
#     for item in names:
#         if item in un2019_list:
#             both.append(item)
#         else:
#             only1.append(item)
#     for item in un_list:
#         if item not in names:
#             not1.append(item)
#     out = {dataset: only1,
#             'un': not1,
#             'both': both
#         }
#     return out


# def compare_all_names(b, w, u):
#     bu = compare_names(b, 'bmgf', u)
#     wu = compare_names(w['name'].to_list(), 'witt', u)
#     print("BU = " + str(len(bu['both'])) + ", WU = " + str(len(wu['both'])))
#     all_len = 0
#     for item in bu['both']:
#         if item in wu['both']:
#             all_len += 1
#     print("All = " + str(all_len))


# def compare_numbers(witt, un):
#     not1 = []
#     only1 = []
#     both = []
#     un_list = un['Country code'].to_list()
#     witt_list = witt['code'].to_list()
#     for item in witt_list:
#         if item in un_list:
#             both.append(item)
#         else:
#             only1.append(item)
#     for item in un['Country code']:
#         if item not in witt['code']:
#             not1.append(item)
#     out = {'witt': only1,
#             'un': not1,
#             'both': both
#     }
#     return out


# # returns a list of common countries
# def countries():
#     uc2019 = un2019_country_names()
#     uc2022 = un2022_country_names()
#     b = bmgf_location_names()
#     w = witt_locations()['name'].to_list()
#     common = list(set(uc2019).intersection(set(uc2022), set(b), set(w)))
#     return common
    
# # returns a list of common countries
# def un_countries():
#     uc2019 = un2019_country_names()
#     uc2022 = un2022_country_names()
#     common = list(set(uc2019).intersection(set(uc2022)))
#     return common



# # get UN isono from country name
# def country_code(country):
#     df = p.read_csv(files.get_file_path('witt_population', 'recode'))
#     df = df.set_index('name')
#     return df.loc[country]['code']


# # retunrs a list of common regions (none!)
# def regions():
#     uc = un_region_names()
#     b = bmgf_location_names()
#     w = witt_locations()['name'].to_list()
#     common = set(uc).intersection(set(b), set(w))
#     return list(common)


# # returns a list of common subregions (only a couple!)
# def subregions():
#     uc = un_subregion_names()
#     b = bmgf_location_names()
#     w = witt_locations()['name'].to_list()
#     common = set(uc).intersection(set(b), set(w))
#     return list(common)


# # analyze datasets

using DataFrames
using Statistics
using CSV
include("files.jl")

# make the years consistent
function pickyears(df, first, last)
    years = df.year
    if minimum(years) > first
        error("First year in dataset is greater than the first year")
    elseif maximum(years) < last
        error("Last year in dataset is greater than the last year")
    else
        return(df[(df.year .>= first) .& (df.year .<= last), :])
    end
end

# merge all global
function mergeall(first=2022, last=2100)
    out = DataFrame(year=first:last)
    bmgfds = "bmgf_population" 
    bmgfcoll = "global_pop"
    for val in getcollvalues(bmgfds, bmgfcoll)
        df = getcolldf(bmgfds, bmgfcoll, val)
        df = pickyears(df, first, last)
        out[!, "BMGF-" * val] = df.population
    end
    un2019ds = "un_population_2019"
    un2019coll = "global_pop"
    for val in getcollvalues(un2019ds, un2019coll)
        df = getcolldf(un2019ds, un2019coll, val)
        df = pickyears(df, first, last)
        out[!, "UN2019-" * val] = df.population
    end
    un2022_ds = "un_population_2022"
    un2022_coll = "global_pop"
    for val in getcollvalues(un2022_ds, un2022_coll)
        df = getcolldf(un2022_ds, un2022_coll, val)
        df = pickyears(df, first, last)
        out[!, "UN2022-" * val] = df.population
    end
    witt_ds = "witt_population"
    witt_coll = "global_pop"
    for val in getcollvalues(witt_ds, witt_coll)
        df = getcolldf(witt_ds, witt_coll, val)
        df = pickyears(df, first, last)
        out[!, "Witt-:" * string(val)] = df.population
    end
    return out
end


# compare global
function compareall(first=2022, last=2100)
    df = mergeall(first, last)
    out = DataFrame(name=String[], peak=Float64[], peakyear=Int[], bilmanyears=Float64[], mean=Float64[])
    years = df[:, "year"]
    select!(df, Not("year"))
    for col in names(df)
        row = Dict()
        max = findmax(df[:, col])
        row["name"] = col
        row["peak"] = max[1]
        row["peakyear"] = years[max[2]]
        row["bilmanyears"] = sum(df[:, col])/1000000000
        row["mean"] = mean(df[:, col])
        push!(out, row)
    end
    return(out)
end


# # country versions
# def merge_all_country(country):
#     out = p.DataFrame()
#     bmgf_ds = 'bmgf_population'
#     bmgf_coll = 'country_pop'
#     for val in files.get_coll_vals(bmgf_ds, bmgf_coll):
#         df = p.read_csv(files.get_coll_file_path(bmgf_ds, bmgf_coll, val))
#         df = df.set_index('year')
#         out['BMGF-' + val] = df[country]
#     un2019_ds = 'un_population_2019'
#     un2019_coll = 'country_pop'
#     for val in files.get_coll_vals(un2019_ds, un2019_coll):
#         df = p.read_csv(files.get_coll_file_path(un2019_ds, un2019_coll, val))
#         df = df.set_index('year')
#         out['UN2019-' + val] = df[country]
#     un2022_ds = 'un_population_2022'
#     un2022_coll = 'country_pop'
#     for val in files.get_coll_vals(un2022_ds, un2022_coll):
#         df = p.read_csv(files.get_coll_file_path(un2022_ds, un2022_coll, val))
#         df = df.set_index('year')
#         out['UN2022-' + val] = df[country]
#     witt_ds = 'witt_population'
#     witt_coll = 'country_pop'
#     for val in files.get_coll_vals(witt_ds, witt_coll):
#         df = p.read_csv(files.get_coll_file_path(witt_ds, witt_coll, val))
#         df = df.set_index('year')
#         out['Witt-' + str(val)] = df[country]
#     return out


# # compare
# def compare_all_country(country, start=2020, end=2100):
#     df = merge_all_country(country)
#     df = df[(df.index >= start) & (df.index <= end)]
#     out = p.DataFrame()
#     out['peak'] = df.max()
#     out['peak_year'] = df.idxmax()
#     out['man-years'] = df.sum()/1000000000
#     out['mean'] = df.mean()
#     return out

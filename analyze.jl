# # analyze datasets

using DataFrames
using CSV
include("files.jl")

# make the years consistent
function pickyears(df, first, last, name)
    years = df.year
    if min(years) > first
        error("First year in dataset " * name * " is greater than the first year")
    elseif max(years) < last
        error("Last year in dataset " * name * " is greater than the last year")
    else
        return(df[(first .>= df.year .<= last), :])
    end
end

# merge all global
function mergeall(first=2020, last=2100)
    out = DataFrame(year=first:last)
    bmgfds = "bmgf_population" 
    bmgfcoll = "global_pop"
    for val in files.getcollvals(bmgfds, bmgfcoll)
        df = DataFrame(CSV.File(getcollfilepath(bmgfds, bmgfcoll, val)))
        out["BMGF-" + val] = df.population
    end
#     un2019_ds = 'un_population_2019'
#     un2019_coll = 'global_pop'
#     for val in files.get_coll_vals(un2019_ds, un2019_coll):
#         df = p.read_csv(files.get_coll_file_path(un2019_ds, un2019_coll, val))
#         df = df.set_index('year')
#         out['UN2019-' + val] = df['population']
#     un2022_ds = 'un_population_2022'
#     un2022_coll = 'global_pop'
#     for val in files.get_coll_vals(un2022_ds, un2022_coll):
#         df = p.read_csv(files.get_coll_file_path(un2022_ds, un2022_coll, val))
#         df = df.set_index('year')
#         out['UN2022-' + val] = df['population']
#     witt_ds = 'witt_population'
#     witt_coll = 'global_pop'
#     for val in files.get_coll_vals(witt_ds, witt_coll):
#         df = p.read_csv(files.get_coll_file_path(witt_ds, witt_coll, val))
#         df = df.set_index('year')
#         out['Witt-' + str(val)] = df['population']
#     return out
end


# # compare global
# def compare_all(start=2020, end=2100):
#     df = merge_all()
#     df = df[(df.index >= start) & (df.index <= end)]
#     out = p.DataFrame()
#     out['peak'] = df.max()
#     out['peak_year'] = df.idxmax()
#     out['manyears'] = df.sum()/1000000000
#     out['mean'] = df.mean()
#     return out


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

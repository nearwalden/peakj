# This has the info about all of the key files for `peakj`

# Note: I don't like how this is coming out, need a database or something

# basepath of the data directories
data_basepath = "/Users/dd/pCloud Drive/data/population/"

# files
struct Files
    pop_data
end

# Pop_Collection
struct PopCollection
    basepath
    vals
end

# collections
struct Collections
    global_pop::PopCollection
    all_pop::PopCollection
    country_pop::PopCollection
end

# types of data
struct DataTypes
    files
    collections
end

# basic struct for describing a DataSource
struct DataSource
    path
    bsaepath
    data::DataTypes
end






# Gates foundation population data
# BMGF = {'path': 'gatesfoundation/',
#         'basepath': DATA_BASEPATH,
#         'data': 
#             {'files': 
#                 {'pop_data': 'IHME_POP_2017_2100_POP_BOTH_SEX_ALL_AGE_Y2020M05D01.csv'
#                 },
#             'collections':
#                 {'global_pop': {
#                     'basepath': 'IHME_POP_2017_2100_GLOBAL_{}.csv',
#                     'vals': ['SLOWER', 'REFERENCE', 'FASTER', 'SDG']
#                     },
#                 'country_pop': {
#                     'basepath': 'IHME_POP_2017_2100_COUNTRY_{}.csv',
#                     'vals': ['SLOWER', 'REFERENCE', 'FASTER', 'SDG']
#                     }
#                 }
#             }
# }
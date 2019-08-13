library(MATSS)
library(drake)

options(drake_make_menu = FALSE)
expose_imports(MATSS)

pipeline <- drake_plan(
    lizards = get_cowley_lizards(), 
    snakes = get_cowley_snakes(), 
    mtquad = get_mtquad_data(file_in(!!file.path(get_default_data_path(), "mapped-plant-quads-mt"))), 
)

pipeline$trigger <- rlang::expr("trigger(command = FALSE)")

db <- DBI::dbConnect(RSQLite::SQLite(), here::here("drake-cache.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)

config <- drake_config(pipeline, cache = cache)
vis_drake_graph(config, build_times = "none")

make(pipeline, 
     cache = cache, 
     parallelism = "future", 
     cache_log_file = here::here("drake-cache-log.csv"), 
     jobs = 2)

simulate_data = function(n_obs) {
  tibble::tibble(unit_type  = rep(c('comply', 'always', 'never'),
                                  length.out = n_obs),
                 inst = sim_instrument(n_obs),
                 tmt  = sim_tmt(unit_type, inst),
                 y    = sim_outcome(unit_type, tmt))
}

sim_outcome = function(unit_type, treatment) {
  
  mu = purrr::map2_dbl(unit_type, treatment,
                       ~switch(.x,
                               comply   = 0.5 * .y,
                               always   = 1.0 * .y,
                               never    = 0))
  
}

sim_tmt = function(unit_type, instrument) {
  
  purrr::map2_dbl(unit_type, instrument,
                  ~switch(.x,
                          comply   = .y * runif(1, max = 2),
                          always   = runif(1, max = 2),
                          never    = 0.0))
}

sim_instrument = function(n_obs) { rbinom(n_obs, 1, 0.5) }

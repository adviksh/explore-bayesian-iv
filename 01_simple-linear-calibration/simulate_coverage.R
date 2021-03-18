# Seed --------------------------------------------------------------------
set.seed(267340)


# Timing ------------------------------------------------------------------
tictoc::tic()


# Libraries ---------------------------------------------------------------
library(here)
library(rstan)
library(purrr)
library(future)
library(furrr)


# Helpers -----------------------------------------------------------------
simulate_data = function(n = 5000, k_w = 1, k_x = 1) {
  w = matrix(rnorm(n * k_w), nrow = n, ncol = k_w) # exogenous instruments
  x = matrix(rnorm(n * k_x), nrow = n, ncol = k_x) # covariates
  v = rnorm(n) # noise in treatment assignment
  u = rnorm(n) # noise in outcome
  
  b_wd = rep(1, k_w)
  b_xd = rep(1, k_x)
  b_xy = rep(1, k_x)
  
  d = w %*% b_wd + x %*% b_xd + v # endogenous treatment
  y = d + x + u # outcome
  
  d = as.numeric(d)
  y = as.numeric(y)
  
  # return
  list(N = n,
       K_w = k_w,
       K_x = k_x,
       W = w,
       X = x,
       d = d,
       y = y)
}

model_coverage = function(model, data) {
  samp = sampling(model,
                  data    = data,
                  chains  = 8,
                  iter    = 4000,
                  pars    = 'tau',
                  include = TRUE)
  tau = extract(samp, 'tau')$tau
  tau = as.numeric(tau)
  
  right_tail = mean(tau > 1)
  left_tail  = mean(tau < 1)
  
  # smallest posterior interval that will cover truth:
  small_tail = min(right_tail, left_tail)
  1 - (2 * small_tail)
}

simulate_coverage = function(model) {
  data = simulate_data()
  model_coverage(model, data)
}

study_coverage = function(n_sims, model) {
  future_map_dbl(1:n_sims, ~simulate_coverage(model))
}


# Stan Setup --------------------------------------------------------------
stan_mod = stan_model(file = here('linear_iv.stan'))


# Simulation Study --------------------------------------------------------
plan(multicore, workers = 10)
coverage = study_coverage(n_sims = 1000, model = stan_mod)


# Save ---------------------------------------------------------------------
write_rds(coverage, here('temp', 'coverage.rds'))


# Done ---------------------------------------------------------------------
message('Done.')
tictoc::toc()



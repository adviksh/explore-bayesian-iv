data {
  int<lower=0> N;   // number of data items
  int<lower=0> K_w; // number of instruments
  int<lower=0> K_x; // number of covariates
  
  matrix[N, K_w] W;   // instrument matrix
  matrix[N, K_x] X;   // predictor matrix
  vector[N] d;        // endogenous treatment
  vector[N] y;        // outcome vector
}
parameters {
  // intercepts
  real a_d;
  real a_y;
  
  // coefficients
  vector[K_w] b_wd;
  vector[K_x] b_xd;
  vector[K_x] b_xy;
  
  // causal effect
  real tau;
  
  // error scales
  real<lower=0> sigma_d;
  real<lower=0> sigma_y;
}
transformed parameters {
  vector[N] d_hat;
  vector[N] y_hat;
  
  d_hat = a_d + X * b_xd + W * b_wd;
  y_hat = a_y + X * b_xy + d_hat * tau;
}
model {
  d ~ normal(d_hat, sigma_d);
  y ~ normal(y_hat, sigma_y);
  
  a_d  ~ normal(0,3);
  a_y  ~ normal(0,3);
  b_wd ~ normal(0,3);
  b_xd ~ normal(0,3);
  b_xy ~ normal(0,3);
  tau  ~ normal(0,3);
  sigma_d ~ normal(0, 3);
  sigma_y ~ normal(0, 3);
}
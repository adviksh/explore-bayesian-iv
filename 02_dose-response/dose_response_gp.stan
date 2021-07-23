data {
  int<lower=0> N_obs;
  vector[N_obs] Y;
  // vector[N_obs] Z;
  real T[N_obs];
  
  // int<lower=0> N_pred;
  // vector[N_pred] T_pred;
}

transformed data {
  vector[N_obs] mu = rep_vector(0, N_obs);
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real<lower=0> rho;
  real<lower=0> alpha;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  matrix[N_obs, N_obs] L_K;
  matrix[N_obs, N_obs] K = cov_exp_quad(T, alpha, rho);
  real sq_sigma = square(sigma);
  
  for (n in 1:N_obs)
    K[n, n] = K[n, n] + sq_sigma;
    
  L_K = cholesky_decompose(K);
  
  rho ~ inv_gamma(5, 5);
  alpha ~ std_normal();
  sigma ~ std_normal();
  
  Y ~ multi_normal_cholesky(mu, L_K);
}

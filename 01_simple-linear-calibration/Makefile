all: temp log
all: rstan-container.sif
all: temp/coverage.rds

temp log:
	mkdir -p $@
	
rstan-container.sif: rstan-container.def
	singularity build --remote --force $@ $<
	
temp/coverage.rds: simulate_coverage.R linear_iv.stan
	singularity exec rstan-container.sif Rscript --vanilla --verbose $< > log/simulate_coverage.log 2>&1
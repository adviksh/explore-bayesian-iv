sing: container.sif

# Singularity Image ------------------------------------------------------------
container.sif: sing/container.def
	singularity build --remote --force --notest $@ $<

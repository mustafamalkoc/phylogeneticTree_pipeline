# phylogeneticTree_pipeline/Snakefile

configfile: "config.yaml"

# Include rules
include: "workflows/rules/blast.smk"
include: "workflows/rules/mafft_fftns.smk"
include: "workflows/rules/trim_msa.smk"
include: "workflows/rules/iqtree.smk"

rule all:
    input:
        # Final output files
        expand("results/{protein}/msa/{protein}_trimmed_fftns.fasta", protein=config["proteins"]),

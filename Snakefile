# phylogeneticTree_pipeline/Snakefile

configfile: "config/config.yaml"

# Include rules
include: "workflows/rules/blast.smk"
include: "workflows/rules/mafft_fftns.smk"
include: "workflows/rules/trim_msa.smk"
include: "workflows/rules/iqtree.smk"
include: "workflows/rules/tree_processing.smk"

rule all:
    input:
        # Final output files
        expand("results/{protein}/iqtree/{protein}_mid_lineage_dup.nwk", protein=config["proteins"]),

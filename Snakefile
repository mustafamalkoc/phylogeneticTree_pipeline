# phylogeneticTree_pipeline/Snakefile

configfile: "config/config.yaml"

# Include rules
include: "workflows/rules/psiblast.smk"
include: "workflows/rules/hmmscan.smk"
include: "workflows/rules/mafft_fftns.smk"
include: "workflows/rules/trim_msa.smk"
include: "workflows/rules/iqtree.smk"
include: "workflows/rules/tree_processing.smk"
include: "workflows/rules/generate_CSVs.smk"
include: "workflows/rules/visualize.smk"

rule all:
    input:
        # Final output files
        expand("results/{protein}/figures/{protein}_domains_onTree.pdf", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_lineage_onTree.pdf", protein=config["proteins"]),
        expand("results/{protein}/iqtree/{protein}_fftns_mid_lineage.nwk", protein=config["proteins"]),
        expand("results/{protein}/iqtree/{protein}_fftns_mid_lineage_dup.nwk", protein=config["proteins"]),


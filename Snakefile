# phylogeneticTree_pipeline/Snakefile

configfile: "config/config.yaml"

# Include rules
include: "workflows/rules/prepare_databases.smk"
include: "workflows/rules/psiblast.smk"
include: "workflows/rules/hmmscan.smk"
include: "workflows/rules/mafft_fftns.smk"
include: "workflows/rules/trim_msa.smk"
include: "workflows/rules/iqtree.smk"
include: "workflows/rules/tree_processing.smk"
include: "workflows/rules/generate_CSVs.smk"
include: "workflows/rules/visualize.smk"
include: "workflows/rules/generate_report.smk"

rule all:
    input:
        expand("resources/pfamDB/Pfam-A.hmm"),
        expand("resources/pfamDB/Pfam-A.hmm.h3f"),
        expand("resources/pfamDB/Pfam-A.hmm.h3i"),
        expand("resources/pfamDB/Pfam-A.hmm.h3m"),
        expand("resources/pfamDB/Pfam-A.hmm.h3p"),
        expand("resources/blastDB/blastDB.pin"),
        expand("results/{protein}/psiblast/{protein}_targetSpecies_prot_list.txt", protein=config["proteins"]),
        expand("results/{protein}/psiblast/{protein}_blasthits.fasta", protein=config["proteins"]),
        expand("results/{protein}/iqtree/{protein}_fftns_mid_lineage.nwk", protein=config["proteins"]),
        expand("results/{protein}/iqtree/{protein}_fftns_mid_lineage_dup.nwk", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_domains_onTree.png", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_lineage_onTree.png", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_Combined_Tree_Figure.png", protein=config["proteins"]),
        "report/final_report.zip"

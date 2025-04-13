# phylogeneticTree_pipeline/Snakefile

configfile: "config.yaml"

# Include the BLAST rule file (you can include more rule files later)
include: "workflows/rules/blast.smk"

rule all:
    input:
        # The final BLAST .txt for each protein:
        expand("results/{protein}/psiblast/{protein}_blastOutput.txt", protein=config["proteins"]),
        # The parsed FASTA for each protein:
        expand("results/{protein}/psiblast/{protein}_blasthits.fasta", protein=config["proteins"]),

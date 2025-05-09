rule generate_report:
    input:
        expand("results/{protein}/iqtree/{protein}_fftns_mid.nwk", protein=config["proteins"]),
        expand("results/{protein}/iqtree/{protein}_fftns_mid_lineage_dup.nwk", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_domains_onTree.png", protein=config["proteins"]),
        expand("results/{protein}/figures/{protein}_lineage_onTree.png", protein=config["proteins"]),
        expand("results/{protein}/psiblast/{protein}_blasthits.fasta", protein=config["proteins"]),
        expand("results/{protein}/psiblast/{protein}_blastOutput.txt", protein=config["proteins"]),
        expand("results/{protein}/psiblast/{protein}_targetSpecies_prot_list.txt", protein=config["proteins"])
    output:
        "report/final_report.zip"
    log:
        "logs/report/report_generation.log"
    conda:
        "../envs/snakemake.yaml"
    shell:
        """
        (
        echo "`date -R`: {rule} started..." &&
          snakemake --report {output} &&
          echo "`date -R`: {rule} ended successfully!" ||
        {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
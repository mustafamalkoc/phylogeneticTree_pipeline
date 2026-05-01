rule mafft_einsi:
    input:
        fasta_file = "results/{protein}/psiblast/{protein}_blasthits.fasta"
    output:
        msa_file = "results/{protein}/msa/{protein}_mafft_einsi.fasta"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/msa/msa_mafft_einsi.log"
    benchmark:
        "logs/{protein}/msa/msa_mafft_einsi.benchmark"
    conda:
        "../envs/msa.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          mafft --genafpair --maxiterate 1000 --thread {resources.cpus} {input.fasta_file} > {output.msa_file} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

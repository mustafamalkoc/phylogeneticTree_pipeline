rule clipkit:
    input:
        msa_file = "results/{protein}/msa/{protein}_mafft_linsi.fasta"
    output:
        trimmed_msa = "results/{protein}/msa/{protein}_trimmed_clipkit_linsi.fasta"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/msa/clipkit_mafft_linsi.log"
    conda:
        "../envs/msa.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
           clipkit \
            {input.msa_file} \
            -m kpic-smart-gap \
            -o {output.trimmed_msa} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
rule clipkit_fftns:
    input:
        msa_file = rules.mafft_fftns.output.msa_file
    output:
        trimmed_msa = "results/{protein}/msa/{protein}_trimmed_fftns.fasta"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/msa/clipkit_fftns.log"
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

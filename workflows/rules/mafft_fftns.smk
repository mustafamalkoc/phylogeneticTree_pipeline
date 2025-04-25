rule mafft_fftns:
    input:
        fasta_file = rules.parse_psiblast.output.fasta
    output:
        msa_file = "results/{protein}/msa/{protein}_fftns.fasta"
    log:
        "logs/{protein}/msa/msa_fftns.log"
    benchmark:
        "logs/{protein}/msa/msa_fftns.benchmark"
    conda:
        "../envs/msa.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          mafft \
            --retree 2 \
            --maxiterate 1000 \
            --thread {resources.cpus} \
            {input.fasta_file} > {output.msa_file} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """

rule mafft_fftns:
    input:
        fasta_file = rules.parse_psiblast.output.fasta
    output:
        msa_file = "results/{protein}/msa/{protein}_fftns.fasta"
    log:
        "logs/{protein}/msa/{protein}_fftns.log",
    benchmark:
        "logs/{protein}/msa/{protein}_fftns.benchmark",
    conda:
        "../envs/msa.yaml"
    shell:
        """
        (
          echo "`date -R`: mafft_fftns started..." &&
          mafft \
            --retree 2 \
            --maxiterate 1000 \
            --thread {resources.cpus} \
            {input.fasta_file} > {output.msa_file} &&
          echo "`date -R`: mafft_fftns ended successfully!"
        ) || (
          echo "`date -R`: mafft_fftns failed..."
          exit 1
        ) > {log} 2>&1
        """

rule trim_msa:
    input:
        msa_file = rules.mafft_fftns.output.msa_file
    output:
        trimmed_msa = "results/{protein}/msa/{protein}_trimmed_fftns.fasta"
    log:
        "logs/{protein}/msa/{protein}_clipkit.log"
    conda:
        "../envs/msa.yaml"
    shell:
        """
        (
          echo "`date -R`: trimming_fftns started..." &&
          clipkit \
            {input.msa_file} \
            -m kpic-smart-gap \
            -o {output.trimmed_msa} &&
          echo "`date -R`: trimming_fftns ended successfully!"
          
        ) || (
          echo "`date -R`: trimming_fftns failed..."
          exit 1
        ) > {log} 2>&1
        """

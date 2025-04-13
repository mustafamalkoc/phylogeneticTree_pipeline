rule psiblast:
    input:
        query_protein = "resources/proteins/{protein}_withNewHeader.fasta"
    output:
        txt = "results/{protein}/psiblast/{protein}_blastOutput.txt"
    threads: 4
    # Optional: track runtime / resources used
    benchmark:
        "logs/{protein}/psiblast/{protein}_psiblast.benchmark.txt"
    # Log file capturing all stdout/stderr
    log:
        "logs/{protein}/psiblast/{protein}_psiblast.log"
    # If you have a dedicated conda env for BLAST, specify it here
    conda:
        "../envs/blast.yaml"
    shell:
        """
        (
          echo "`date -R`: psiblast started..." &&
          psiblast \
            -query {input.query_protein} \
            -db {config[blast_database]} \
            -out {output.txt} \
            -num_iterations 3 \
            -max_target_seqs 6000 \
            -num_threads {threads} \
            -outfmt 0 &&
          echo "`date -R`: psiblast ended successfully!"
        ) || (
          echo "`date -R`: psiblast failed..."
          exit 1
        ) > {log} 2>&1
        """


rule parse_psiblast:
    input:
        blastOutput = "results/{protein}/psiblast/{protein}_blastOutput.txt",
        blastdb = lambda wildcards: config["blastdb_fasta"],
        query_fasta = "resources/proteins/{protein}_withNewHeader.fasta"
    output:
        fasta = "results/{protein}/psiblast/{protein}_blasthits.fasta"
    threads: 1
    benchmark:
        "logs/{protein}/psiblast/{protein}_parse_psiblast.benchmark.txt"
    log:
        "logs/{protein}/psiblast/{protein}_parse_psiblast.log"
    # If you have a conda env for parsing:
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: parse_psiblast started..." &&
          python workflows/scripts/parse_psiblast.py\
            {input.blastOutput} \
            {input.blastdb} \
            {input.query_fasta} \
            {config[given_taxid]} \
            {config[paralog_count]} \
            > {output.fasta} &&
          echo "`date -R`: parse_psiblast ended successfully!"
        ) || (
          echo "`date -R`: parse_psiblast failed..."
          exit 1
        ) > {log} 2>&1
        """

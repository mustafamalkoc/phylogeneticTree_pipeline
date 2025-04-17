rule psiblast:
    input:
        query_protein = "resources/proteinSeqs/{protein}.fasta"
    output:
        txt = "results/{protein}/psiblast/{protein}_blastOutput.txt"
    log:
        "logs/{protein}/psiblast/{protein}_psiblast.log"
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
            -num_threads {resources.cpus} \
            -outfmt 7 &&
          echo "`date -R`: psiblast ended successfully!"
        ) || (
          echo "`date -R`: psiblast failed..."
          exit 1
        ) > {log} 2>&1
        """

rule parse_psiblast:
    input:
        blastOutput = rules.psiblast.output.txt,
        blastdb = lambda wildcards: config["blastdb_fasta"],
        query_fasta = rules.psiblast.input.query_protein
    output:
        fasta = "results/{protein}/psiblast/{protein}_blasthits.fasta"
    log:
        "logs/{protein}/psiblast/{protein}_parse_psiblast.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: parse_psiblast started..." &&
          python workflows/scripts/parse_psiblast.py\
            {input.blastOutput} \
            {input.blastdb} \
            {output.fasta} \
            {config[given_taxid]} &&
          echo "`date -R`: parse_psiblast ended successfully!"
        ) || (
          echo "`date -R`: parse_psiblast failed..."
          exit 1
        ) > {log} 2>&1
        """

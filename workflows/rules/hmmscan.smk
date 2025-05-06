rule hmmscan:
    input:
        fasta_file = rules.parse_psiblast.output.fasta,
    output:
        domtblout = "results/{protein}/hmmscan/{protein}_domtblout.txt"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/hmmscan/hmmscan.log"
    conda:
        "../envs/hmmer.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          hmmscan \
            --cpu {resources.cpus} \
            --noali \
            --cut_ga \
            --domtblout {output.domtblout} \
            resources/pfamDB/Pfam-A.hmm \
            {input.fasta_file} && 
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
rule parse_hmmscan:
    input:
        domtblout = rules.hmmscan.output.domtblout        
    output:
        parsed_hmmscan = "results/{protein}/hmmscan/{protein}_parsed_domtbl.json"
    resources:
        protein_name = lambda wildcards: wildcards.protein
    log:
        "logs/{protein}/hmmscan/parse_hmmscan.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: {rule} started..." &&
          python workflows/scripts/parse_hmmscan_domtblout.py \
            {input.domtblout} \
            {output.parsed_hmmscan} &&
          echo "`date -R`: {rule} ended successfully!" ||
          {{ echo "`date -R`: {rule} failed..."; exit 1; }}  )  >> {log} 2>&1
        """
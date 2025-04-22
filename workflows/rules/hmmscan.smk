rule hmmscan:
    input:
        fasta_file = rules.parse_psiblast.output.fasta,
    output:
        domtblout = "results/{protein}/hmmscan/{protein}_hmmscan_domtblout.txt",
    log:
        "logs/cluster/{protein}/hmmscan/{protein}_hmmscan.log"
    conda:
        "../envs/hmmer.yaml"
    shell:
        """
        (
          echo "`date -R`: hmmscan started..." &&
          hmmscan \
            --cpu {resources.cpus} \
            --noali \
            --cut_ga \
            --domtblout {output.domtblout} \
            {config[pfamDB]}\
            {input.fasta_file} && 
          echo "`date -R`: hmmscan ended successfully!"
        ) || (
          echo "`date -R`: hmmscan failed..."
          exit 1
        ) > {log} 2>&1
        """
rule parse_hmmscan:
    input:
        domtblout = rules.hmmscan.output.domtblout,        
    output:
        parsed_hmmscan = "results/{protein}/hmmscan/{protein}_hmmscan_parsed.json",
    log:
        "logs/cluster/{protein}/hmmscan/{protein}_parse_hmmscan.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: parse_hmmscan started..." &&
          python workflows/scripts/parse_hmmscan_domtblout.py \
            {input.domtblout} \
            {output.parsed_hmmscan} && 
          echo "`date -R`: parse_hmmscan ended successfully!"
        ) || (
          echo "`date -R`: parse_hmmscan failed..."
          exit 1
        ) > {log} 2>&1
        """
rule make_domain_csv:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        hmmscan = rules.parse_hmmscan.output.parsed_hmmscan,
    output:
        domain_csv = "results/{protein}/hmmscan/{protein}_domains.csv",
    log:
        "logs/cluster/{protein}/hmmscan/{protein}_make_domain_csv.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: make_domain_csv started..." &&
          python workflows/scripts/make_domain_csv.py \
            {input.treeFile} \
            {input.hmmscan} \
            {output.domain_csv} && 
          echo "`date -R`: make_domain_csv ended successfully!"
        ) || (
          echo "`date -R`: make_domain_csv failed..."
          exit 1
        ) > {log} 2>&1
        """
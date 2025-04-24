rule make_lineage_csv:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
    output:
        lineage_csv = "results/{protein}/lineage/{protein}_lineage.csv",
    log:
        "logs/{protein}/lineage/{protein}_make_lineage_csv.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: make lineage csv started..." &&
          python workflows/scripts/make_lineage_csv.py \
            {input.treeFile} \
            {output.lineage_csv} && 
          echo "`date -R`: make lineage csv ended successfully!" ||
          {{ echo "`date -R`: make lineage csv failed..."; exit 1; }}  )  > {log} 2>&1
        """
rule make_domain_csv:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        hmmscan = rules.parse_hmmscan.output.parsed_hmmscan,
    output:
        domain_csv = "results/{protein}/hmmscan/{protein}_domains.csv",
    log:
        "logs/{protein}/hmmscan/{protein}_make_domain_csv.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (echo "`date -R`: make_domain_csv started..." &&
          python workflows/scripts/make_domain_csv.py \
            {input.treeFile} \
            {input.hmmscan} \
            {output.domain_csv} && 
          echo "`date -R`: make_domain_csv ended successfully!" ||
          {{ echo "`date -R`: make_domain_csv failed..."; exit 1; }}  )  > {log} 2>&1
        """
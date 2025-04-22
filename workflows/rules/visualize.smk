rule domain_visualization:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        domain_csv = rules.make_domain_csv.output.domain_csv,
    output:
        domain_figure = "results/{protein}/figures/{protein}_domains_onTree.pdf",
    log:
        "logs/cluster/{protein}/figures/{protein}_domain_visualization.log"
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (
          echo "`date -R`: domain visualization started..." &&
          Rscript ~/scripts/domain_visualization.R \
            {input.domain_csv} \
            {input.treeFile} \
            {output.domain_figure} && 
          echo "`date -R`: domain visualization ended successfully!"
        ) || (
          echo "`date -R`: domain visualization failed..."
          exit 1
        ) > {log} 2>&1
        """
rule make_lineage_csv:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
    output:
        lineage_csv = "results/{protein}/lineage/{protein}_lineage.csv",
    log:
        "logs/cluster/{protein}/lineage/{protein}_make_lineage_csv.log"
    conda:
        "../envs/python.yaml"
    shell:
        """
        (
          echo "`date -R`: make lineage csv started..." &&
          python workflows/scripts/make_lineage_csv.py \
            {input.treeFile} \
            {output.lineage_csv} && 
          echo "`date -R`: make lineage csv ended successfully!"
        ) || (
          echo "`date -R`: make lineage csv failed..."
          exit 1
        ) > {log} 2>&1
        """
   
rule lineage_visualization:
    input:
        treeFile = rules.midpoint_rooting.output.rootedTree,
        lineage_csv = rules.make_lineage_csv.output.lineage_csv,
    output:
        lineage_figure = "results/{protein}/figures/{protein}_lineage_onTree.pdf",
    log:
        "logs/cluster/{protein}/figures/{protein}_lineage_visualization.log"
    conda:
        "../envs/visualize.yaml"
    shell:
        """
        (
          echo "`date -R`: lineage visualization started..." &&
          Rscript ~/scripts/lineage_visualization.R \
            {input.lineage_csv} \
            {input.treeFile} \
            {output.lineage_figure} && 
          echo "`date -R`: lineage visualization ended successfully!"
        ) || (
          echo "`date -R`: lineage visualization failed..."
          exit 1
        ) > {log} 2>&1
        """